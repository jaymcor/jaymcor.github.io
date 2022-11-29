# More Mastadon Tips & Trivia

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

## Mobile apps

### Android

There are a bunch, here's what I've tried:

* Tusky

I'm currently using Tusky because I'm happy that the developer pissed off the
fascists by being so eager to quelch them on his app at the drop of the hat, so
now they seem to be angrily pushing FUD against Tusky.  If the fascists are
unhappy, that's a sign of doing something right.

### Iphone

There are a bunch, haven't tried them.

* MetaText is apparently quite popular

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
<a rel="me" href="https://mas.to/@jaymcor">Mastodon</a>
```

However, sometimes you don't have access to raw HTML, or it gets modified
by the system you're linking to.

#### LinkedIn

I have not yet found a way to make it work.

DM me at `@jaymcor@mas.to` if you figure out how.

#### Facebook

I have not yet found a way to make it work.

Surprisingly frustrating, navigating the labyrinth hoping for a way to just
update my profile to show a simple external contact URL.  DM me at
`@jaymcor@mas.to` if you figure out how.

#### GitHub

Mostly github wants to remove the `rel="me"` part, but there is a way.

Create a user repo, e.g. `jaymcor.github.io` and add your own raw `index.html`...

### Fediverse

It just works, linking to other fediverse accounts.
