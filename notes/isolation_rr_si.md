# Repeatable Read vs Snapshot Isolation

Here's a question: when you choose `Repeatable Read` isolation level in
MySQL, does it actually give you `Snapshot Isolation` semantics instead?
How different are they and why does it matter?

## Theory

### ANSI Standard Isolation Levels

PostgreSQL, MySQL, SAP, and many other databases implement the four common isolation levels which are defined in
[SQL-92](https://www.contrib.andrew.cmu.edu/~shadow/sql/sql1992.txt) based on
anomaly protection:

| Isolation        | Summary         |  A1 |  A2 |  A3 |
| ---------------- | --------------- | --- | --- | --- |
| READ UNCOMMITTED | weakest         | Yes | Yes | Yes |
| READ COMMITTED   | basic atomicity |  no | Yes | Yes |
| REPEATABLE READ  | basic isolation |  no |  no | Yes |
| SERIALIZABLE     | strongest       |  no |  no |  no |

Anomaly A1 is "dirty reads" (T1 sees the data T2 wrote before it commits,
and indeed T1 might even see it if T2 is rolled back).

Anomaly A2 is "inconsistent reads" (T1 reads a row, T2 does something to it
and commits, and T1 reads it again but gets a different value).

Anomaly A3 is "phantoms" (T1 reads some rows via a select predicate, T2
changes the set of rows matching that predicate, e.g. by adding a new row,
and commits, and T1 reads again but this time the select results are
slightly different due to the actions of T2, so they still aren't
perfectly isolated).

### Theoretical Relation to Locking

A bit of an oversimplification, but in traditional theory, these levels were
implemented by different locking regimes for phantom prevention, read sets, and
write sets, e.g. none, short (only during the operation), or long (hold till
the end of the transaction):

| Isolation        | Phantom Locks | Read Locks | Write Locks |
| ---------------- | ------------- | ---------- | ----------- |
| READ UNCOMMITTED | no            | no         | long        |
| READ COMMITTED   | no            | short      | long        |
| REPEATABLE READ  | short         | long       | long        |
| SERIALIZABLE     | long          | long       | long        |

Note that the phantom prevention locks can take many forms, e.g. predicate
locks, precision locks, gap locks, range locks, index locks, etc, but the
basic goal is to make sure the matched set of a predicate does not vary,
e.g. between repeated SELECTs in a transaction.

### But in Reality

Modern databases don't necessarily provide exactly these isolation semantics
or implement them using the above simple locking regimes.

MVCC systems that can read at a specific timestamp are such a convenient tool
and intuitive concept, they are widely used to achieve read set isolation and
phantom prevention with less locking, higher performance, and higher
concurrency.  The practice is now quite prevalent.

Thus, PostgreSQL uses snapshot isolation internally, even in its default
isolation level of `Read Committed`.  MySQL also acquires a read snapshot as of
the first select in a transaction, and uses the same snapshot during subsequent
selects, in its default isolation level of `Repeatable Read`.

According to [A Critique of ANSI SQL Isolation Levels (SIGMOD 1995) by
Berenson, Bernstein, Gray et al](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/tr-95-51.pdf), the ANSI standard isolation levels suffer from
a number of shortcomings, such as failure to address "write skew" anomalies
(e.g. the history sequence T1:read[x], T2:read[y], T1:write[y], T2:write[x],
T1:commit, T2:commit) which clearly contains a non-serializable overlap between
T1 and T2.

The paper [Generalized Isolation Level Definitions (ICDE 2000) by Adya, Liskov, et al](https://pmg.csail.mit.edu/papers/icde00.pdf) further elaborates on the theoretical shortcomings of the ANSI standard, and provides more abstract, general, and flexible definitions.

A careful review of the literature shows that `Snapshot Isolation` (SI) is very similar to `Repeatable Read` (RR), but they aren't exactly the same.  They are both stronger than `Read Committed` but weaker than `Serializable`.  The best summary of their difference is that SI allows write skew but blocks phantoms, whereas RR blocks write skew but allows phantoms.

Microsoft extends SQL to distinguish between RR and SI.

Infamously, one large database vender (rhymes with Auracle) sold SI to their customers as `Serializable`.

Recent versions of PostgreSQL provide an improvement on SI called Serializable Snapshot Isolation (SSI).  For the sake of this document, we will borrow a great example of write skew anomalies from the paper [Serializable Snapshot Isolation in PostgreSQL (VLDB 2012) by Dan Ports et al](https://drkp.net/papers/ssi-vldb12.pdf).

## Let's Experiment

### MySQL

#### Installing

As root, quickie unsafe install:

```
# dnf install -y community-mysql-server
# systemctl start mysqld
```

#### Creating a Test Database

```
# mysql -u root -e 'CREATE DATABASE test'
```

#### Connecting to Command Line Prompt

Connect to the insecure database like so:

```
# mysql -u root -D test
```

#### Selecting Isolation Level

InnoDB defaults to RR, but we'll specify it manually just to be sure.

```
mysql> SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

#### Write Skew Test Setup

MySQL will likely default to InnoDB, but we'll specify it just to be sure.

```
CREATE TABLE doctor (name VARCHAR(20), oncall BOOLEAN) ENGINE=InnoDB;
INSERT INTO doctor (name, oncall) VALUES ('Andy', TRUE);
INSERT INTO doctor (name, oncall) VALUES ('Brad', TRUE);
EXIT
```

### PostgreSQL

#### Installing

As root:
```
# dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/F-37-x86_64/pgdg-fedora-repo-latest.noarch.rpm
# dnf install -y postgresql14-server postgresql14
# /usr/pgsql-14/bin/postgresql-14-setup initdb
# systemctl start postgresql-14
```

#### Creating a Test Database

```
# su -c 'createdb test' - postgres
```

#### Connecting to Command Line Prompt

```
# su -c 'psql -d test' - postgres
```

#### Selecting Isolation Level

```
test=# SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

#### Write Skew Test Setup

Looks just like with MySQL, except, instead of `ENGINE=InnoDB` we would say
`USING someAccessMethod` if we wanted to override the default internal
table access method.

```
CREATE TABLE doctor (name VARCHAR(20), oncall BOOLEAN);
INSERT INTO doctor (name, oncall) VALUES ('Andy', TRUE);
INSERT INTO doctor (name, oncall) VALUES ('Brad', TRUE);
EXIT
```

### The Actual Write Skew Test

Happily, one version suffices for both MySQL and PostgreSQL.

Terminal 1: Andy is checking whether it's safe for him to take some time off:

```
BEGIN;
SELECT name FROM doctor WHERE oncall=TRUE AND name<>'Andy';
+------+
| name |
+------+
| Brad |
+------+
```

Good.  There's another doctor on call.  Speaking of which...

Terminal 2: Brad, the other doctor, has the same plan:

```
BEGIN;
SELECT name FROM doctor WHERE oncall=TRUE AND name<>'Brad';
+------+
| name |
+------+
| Andy |
+------+

UPDATE doctor SET oncall=FALSE WHERE name='Brad';
COMMIT;
```

Cool, Brad is all set.

Back at terminal 1: Andy thinks "quick let's get in before anything changes":

```
UPDATE doctor SET oncall=FALSE WHERE name='Andy';
```

So far so good. Andy is a careful boy and takes a moment to double check
before he commits:

```
SELECT name FROM doctor WHERE oncall=TRUE;
+------+
| name |
+------+
| Brad |
+------+

COMMIT;
```

The latter SELECT result seems to make sense--roughly speaking RR says we see
a consistent view of the world, untainted by changes wrought by any other
transaction... a stable read set, except we do see changes wrought by our own
transaction (i.e. Andy is no longer on call).

Excellent!  All's well that ends well. Andy's name is not in the result set,
because he's taking time off, but there is at least one name in the result set.
Andy reflects on how awesome SQL is.

However... it didn't actually end well.  Imagine Andy's surpise when
Charlie shows him this:

```
SELECT * FROM doctor;
+------+--------+
| name | oncall |
+------+--------+
| Brad |      0 |
| Andy |      0 |
+------+--------+
```

WHAT!!!!!  How did this happen?

### Epilogue

Andy was bitten by the infamous write skew anomaly, which is not allowed
under RR, but is allowed under SI.  By the way, this happens in both MySQL
RR and PostgreSQL RR.

Simply put, Andy and Brad were operating from the same snapshotted read view,
against which their writes were individually valid, but the two transactions
overlap in a non-serializable way, and the combination of overlapping writes
lead to an unacceptable outcome--there is nobody oncall.  Write skew can
ruin your day.  Phantom protection seems fine in this example though--which
is again consistent with SI.

What does this tell us about MySQL and PostgreSQL `Repeatable Read` isolation?  It looks
technically more like `Snapshot Isolation` based on these experiments, though
it's probably not purely either one.  Perhaps the developers were reticent to
depart from the ANSI standard otherwise they would call it Snapshot.

## Minor Plot Twist

It's not exactly an unexpected plot twist, but it turns out RR in MySQL is
weirder than you think.  It is not really SI either, if you consider the lost
updates anomaly, which should not be allowed in either RR or SI.

The aforementioned critique of ANSI isolation levels seems convinced that lost
updates are not allowed in RR, and notes that "... the anomaly P4 is useful in
distinguishing isolation levels intermediate in strength between READ COMMITTED
and REPEATABLE READ."  In other words, RC may exhibit lost updates, but RR does
not.

And yet, according to the following test, in MySQL, lost updates happen even in
RR.  On the other hand, the same test in PostgreSQL does not exhibit the lost
update anomaly in RR, though it does in RC, which conforms better to what the
literature says for these isolation levels.

### Lost Update Test Setup

We just need one row for this...

```
CREATE TABLE account (id INT, cash INT);
INSERT INTO account (id, cash) VALUES (1, 100);
```

### Lost Update Test

Terminal 1 (seeking to deposit $20):

```
BEGIN;
SELECT cash FROM account WHERE id=1;
+------+
| cash |
+------+
|  100 |
+------+

```

While this is going on, in terminal 2 (seeking to deposit $30):

```
BEGIN;
SELECT cash FROM account WHERE id=1;
+------+
| cash |
+------+
|  100 |
+------+

UPDATE account SET cash=130 WHERE id=1;
COMMIT;
```

Back to terminal 1, which saw a balance of $100:

```
UPDATE account SET cash=120 WHERE id=1;
COMMIT;
SELECT cash FROM account WHERE id=1;
+------+
| cash |
+------+
|  120 |
+------+

```

This is bad, it means the $30 deposit was overwritten.  From the user's
perspective, either the total should be $150, or one of the transactions
should have failed.  This is a thing that can happen to you in RR isolation
level on MySQL.

### Some Advice re Lost Update

Although `Serializable` isolation level would prevented this problem in
MySQL, if you are doing this type of transaction pattern, consider making the
database aware of your intent by using `SELECT ... FOR UPDATE`.

## Summary

People don't always define terms in the same way (even when they think they do),
and practice often diverges from theory.  This is especially so in the world of
database isolation levels.

The article [Comprehensive Understanding of Transaction Isolation Levels](https://alibaba-cloud.medium.com/comprehensive-understanding-of-transaction-isolation-levels-212460572176) has more details comparing the nuances of some popular implementations.
