# More Mastodon Tips & Trivia

----------------------------------------------------------------------------

## Narrow mode

If you have your monitor vertically oriented, it seems to automatically
switch into a "mobile" style layout where the left column is dropped.
Looks much better in my opinion.

### What about searching?

But where did the search box go?

You don't need it, you can click on *Explore* on the right column and search
from there.

----------------------------------------------------------------------------

## Following a hashtag

Be aware that some of the popular hashtags can have quite a few posts, and
it might be more than you'd want to wade through on a daily basis.  That said,
you just need to search for the hashtag (e.g. under the Explore window),
select the hashtag to view it, and then click the little + box in the upper
right hand corner.

![Pictorial steps](../images/hashfollowsteps.png)

Not every phone app knows how to follow hashtags.  Tusky supports it.  At time
of writing, the official Mastodon app didn't seem to support it.  However it
works with the Mastodon PWA (see below for instructions).

----------------------------------------------------------------------------

## Mobile apps

### Any phone

There's a PWA, so you get an experience similar to the browser one.
It's pretty good on mobile devices, definitely worth installing.  You
can have it installed simultaneously with whatever other app.

Just use your phone's web browser to open your server's home page (in my case
https://mastodon.acm.org/home) like you would on the desktop, then tell it to
install the PWA on the phone, which will provide yet another "app" icon for
accessing Mastodon on your phone.

### Android

There are a bunch of options, here's what I've tried:

* The Official Mastodon App
* Tusky
* Fedilab
* Megalodon
* Tooot

I'm currently using Tusky because I'm happy that the developer pissed off the
fascists by being so eager to quelch them on his app at the drop of the hat, so
now they seem to be angrily pushing FUD against Tusky.  If the fascists are
unhappy, that's a sign of doing something right.

### Iphone

There are a bunch, haven't tried them.

* MetaText is apparently quite popular
* Toot!
* Ice Cubes
* Ivora
* Mona

----------------------------------------------------------------------------

## Mastodon Status

Please keep in mind that *Mastodon is fundamentally a distributed service*
with each instance run by a different team.  So it's hard to say anything
about the status of the entire ecosystem.  Usually it makes more sense to
talk about the status of a particular instance.

### Internal Server Status Pages

Not every server has one (and if it does, it might not be available), but
often you can just prepend "status" on the hostname of a given server.

For example:

* [https://status.mastodon.social/](status.mastodon.social)
* [https://status.universeodon.com/](status.universeodon.com)
* [https://status.mastodon.online/](status.mastodon.online)
* [https://status.mstdn.social/](status.mstdn.social)
* [https://status.masto.ai/](status.masto.ai)
* [https://status.mastodon.world](status.mastodon.world)
* [https://status.ohai.social](status.ohai.social)
* [https://status.newsie.social](status.newsie.social)
* [https://status.techhub.social](status.techhub.social)
* [https://status.fosstodon.org](status.fosstodon.org)
* [https://status.infosec.exchange](status.infosec.exchange)
* [https://status.ioc.exchange](status.ioc.exchange)
* [https://status.hachyderm.io](status.hachyderm.io)

### External Server Status Pages

A better way is to check something out-of-band, neither burdening
nor depending upon the servers in question...

* [https://mastodonstatus.com/](mastodonstatus.com)

### User Counts

* https://mastodon.social/@mastodonusercount

----------------------------------------------------------------------------

## Verified Links

### Why

Because accounts can be easily impersonated.

### Embedded Link

Under your preferences/profile, link to some well known sites that people
independently know as you.  If that site has an appropriate link leading back
to your Mastodon profile, then the link will be highlighted in green and given
a checkmark.

In theory, it's as simple as embedding the following code in an external
link that you control:

```
<a rel="me" href="https://mastodon.acm.org/@jaymcor">Mastodon</a>
```

However, sometimes you don't have access to raw HTML, or it gets modified
by the system you're linking to.

#### LinkedIn

I have not yet found a way to make it work.

DM me at `@jaymcor@mastodon.acm.org` if you figure out how.

#### Facebook

I have not yet found a way to make it work.

Surprisingly frustrating, navigating the labyrinth hoping for a way to just
update my profile to show a simple external contact URL.  DM me at
`@jaymcor@mastodon.acm.org` if you figure out how.

#### GitHub

Originally the best way was to create a user repo, e.g. `jaymcor.github.io` and
add your own raw `index.html` to it, containing the `rel="me"` link.

However, it is now easier, you can just directly link to the URL form of your
mastodon address in your github user profile, and then the link from mastodon
profile will verify correctly.

### Fediverse

It just works, linking to other fediverse accounts.

----------------------------------------------------------------------------

## Moving from one server to another

### Why

* new server is more fitting
* old server has a problem
* to taste the freedom

### What happens?

You move most of your data including past posts, the list of things
you follow, local filters, bookmarks, etc.

**You get to choose** whether followers of your old address will automatically
be switched to point at your new address (in most cases you should do it).

### How

There's a process, it has to be done in a particular order.

* On old server, export your data
  * Note that your "Archive" includes:
    * your liked posts
    * your own posts
    * your media (e.g. images you posted)
  * You'll want to separately download the CSV for follows, blocks, mutes, etc
  * Your bookmarks are available as separate CSV but also included in archive
    * Best to grab the CSV as well just for good measure
* On new server, create the new account
  * Make the new account profile page look the way you want now
  * Pretend you're a counterfeiter--duplicate the following
    * profile avatar pic
    * profile header pic
    * bio
    * verified links
  * Basic preferences e.g. "slow mode", themes, etc
  * Don't try to duplicate your followers, that will be done below
* On new server, goto Prefs/Account/MovingFrom and set old address as alias to new
* Consider posting your intro on the new server now
  * This way, it goes out on the new server before your old followers migrate
  * Users on the new server: may be interested
  * Users that already followed: won't need to see it again
* The next step officially migrates you, snatching your followers to the new server
  * Your old account will be mostly disabled
  * If you want to grab any other info from it, do it now
  * If you want to catch up reading or anything else, do it now
  * See note at end of this section
* On old server, goto Prefs/Account/MovingTo, put new address, old password
  * It is done, you are migrated
* On new server, restore data as needed
  * all those CSV files--bookmarks, follows, blocks, mutes, etc

Check [the official docs](https://docs.joinmastodon.org/user/moving/) for an authoritative guide.

See also [fedi.tips guide](https://fedi.tips/transferring-your-mastodon-account-to-another-server/).

See also [Josh Justice's guide](https://codingitwrong.com/2022/10/10/migrating-a-mastodon-account.html).

### Cautions and provisos

#### Past posts

Your past posts are not migrated.

#### Manual config of new account

At time of writing (2022-12-26) you still need to manually recreate the details
in your profile, e.g. profile pic, bio, etc, as described above.

#### Be ready before touching the trigger

When you start the `MovingTo` process, the old account will be dimmed/disabled
and will refer people to the new one, so best to finish exporting data, copying
profile, and anything else you need with the old account, before you begin the
`MovingTo` step.

#### Follows from new account might get stuck on manual approval

While followers will automatically update to point at your new address
(supposing you initiate this with the `MovingTo` step), the converse
process--the import of your follow list (people you follow)--can have some
hickups.

Some of the entries in your follow list may require manual approval.  When that
person sees the follow request from your new account, it's not obviously
different than a regular request.  If that person recognizes your name and
remembers that you mentioned you were going to migrate, fine, otherwise they
may wonder what is going on, and may not be sure it is you (unfortunately
there's currently no cryptographically signed linkage to your prior
address--they just have to exercise prudence).  Or they might be too busy to
notice the new follow request.  The main effect is that there might be a lag
for people who require manual approval of follow requests (an option under
profile config).

#### Some people have experienced errors during migration

I did not personally experience this, but apparently what can happen
is that, if the new server is slow, some of the constituent requests
can fail and you might need to restart/retry the migration, which could
be a pain.

#### If old server can't communicate, then what?

This is the Achilles' Heel.  You can not migrate unless the old server is up.
Be forewarned.
