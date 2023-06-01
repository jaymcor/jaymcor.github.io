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

### Installing MySQL

As root, quickie unsafe install:

```
# dnf install -y community-mysql-server
# systemctl start mysqld
```

Connect to the insecure database like so:

```
# mysql -u root -p
```

### Test setup

```
mysql> CREATE DATABASE test;
mysql> USE test;
mysql> CREATE TABLE doctor (name VARCHAR(20), oncall BOOLEAN) ENGINE=InnoDB;
mysql> INSERT INTO doctor (name, oncall) VALUES ("Andy", TRUE);
Query OK, 1 row affected (0.00 sec)

mysql> INSERT INTO doctor (name, oncall) VALUES ("Brad", TRUE);
Query OK, 1 row affected (0.01 sec)

mysql> EXIT
```

### The Actual Test

InnoDB defaults to RR, but we'll specify it manually just to be sure.

Terminal 1: Andy is checking whether it's safe for him to take some time off:

```
# mysql -u root -p
mysql> USE test;
mysql> SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
mysql> START TRANSACTION;
mysql> SELECT name FROM doctor WHERE oncall=TRUE AND name<>"Andy";
+------+
| name |
+------+
| Brad |
+------+
1 row in set (0.00 sec)

```

Good.  There's another doctor on call.  Speaking of which...

Terminal 2: Brad, the other doctor, has the same plan:

```
# mysql -u root -p
mysql> USE test;
mysql> SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
mysql> START TRANSACTION;
mysql> SELECT name FROM doctor WHERE oncall=TRUE AND name<>"Brad";
+------+
| name |
+------+
| Andy |
+------+
1 row in set (0.00 sec)

mysql> UPDATE doctor SET oncall=FALSE WHERE name="Brad";
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> COMMIT;
Query OK, 0 rows affected (0.00 sec)
```

Cool, Brad is all set.

Back at terminal 1: Andy thinks "quick let's get in before anything changes":

```
mysql> UPDATE doctor SET oncall=FALSE WHERE name="Andy";
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

So far so good. Andy is a careful boy and takes a moment to double check:

```
mysql> SELECT name FROM doctor WHERE oncall=TRUE;
+------+
| name |
+------+
| Brad |
+------+
1 row in set (0.00 sec)

mysql> COMMIT;
Query OK, 0 rows affected (0.00 sec)
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
mysql> SELECT * FROM doctor;
+------+--------+
| name | oncall |
+------+--------+
| Brad |      0 |
| Andy |      0 |
+------+--------+
2 rows in set (0.00 sec)
```

WHAT!!!!!  How did this happen?

### Epilogue

Andy was bitten by the infamous write skew anomaly, which is not allowed
under RR, but is allowed under SI.

Simply put, Andy and Brad were operating from the same snapshotted read view,
against which their writes were individually valid, but the two transactions
overlap in a non-serializable way, and the combination of overlapping writes
lead to an unacceptable outcome--there is nobody oncall.  Write skew can
ruin your day.  Phantom protection seems fine in this example though--which
is again consistent with SI.

What does this tell us about MySQL's `Repeatable Read` isolation?  It looks
technically more like `Snapshot Isolation` based on these experiments, though
it's probably not purely either one.  Perhaps the developers were reticent to
depart from the ANSI standard otherwise they would call it Snapshot.
Regardless, people don't always define terms the same way even when they think
they do, and practice often diverges from theory.  This is especially so in the
world of database isolation levels.

The article [Comprehensive Understanding of Transaction Isolation Levels](https://alibaba-cloud.medium.com/comprehensive-understanding-of-transaction-isolation-levels-212460572176) has more details comparing the nuances of some popular implementations.
