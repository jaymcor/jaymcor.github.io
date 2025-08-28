# Matrix / Element Intro

---------------------------------------------------------------------------

## Quickstart

It's pretty quick.

### 1. Install Element X (client app) or use your browser

Choose one (or more) of the following:

* [Browser app](https://app.element.io/)
* [iPhone app](https://apps.apple.com/app/vector/id1083446067)
* [Android app](https://play.google.com/store/apps/details?id=im.vector.app)
* [Desktop app](https://element.io/download)

### 2. Create your Matrix identity

1. Open Element and click **Create Account**
2. Pick a **homeserver** (just use `matrix.org` for our purposes)
3. Specify (**username**, **password**, and **recovery email**)
4. Verify your email if required

### 3. Join the space (using your invite)

1. **Open** your invite link or paste into Element
2. **Accept** to join the space
3. Explore the space, in particular the General channel
4. Configure notifications (at least @mentions, assuming your phone has DND)

### 4. Lost or missing your invite?

No problem, do this instead:

1. Enter the name of the space or room into the **search bar**
2. Click **Join**
3. Wait for **approval**
4. Explore and config as described above

---------------------------------------------------------------------------

## What are we even talking about?

Matrix is an *open*, *decentralized*, end-to-end *encrypted*, messaging system.

It has gateways for IRC, Slack, Discord, Google Chat, Signal, and Whatsapp.

It supports file sharing, audio/video conferencing, spaces, rooms, threads.

It is used by hackerspaces, open source projects, public enterprises, and
government agencies in Europe and elsewhere, instead of proprietary systems
like Signal (it's run by a public foundation, and the design, protocol, and
source code are fully open, and you can run your own trusted servers if you
need to).

---------------------------------------------------------------------------

## Which is it, Matrix or Element?

#### Servers

**Matrix** is the protocol used by the underlying servers.  Analogous to SMTP
for email servers.  There are many different server code implementations, and
you can run your own server on your own hardware.

`matrix.org` has one of the major homeservers, usable by the public.  At time
of writing it was running a codebase called Synapse, but that will probably
change.

#### Links

`matrix.to` is for universal link representation for users, rooms, and events,
until such time as `matrix:` URI formats have consistent browser support.

Think of it as a redirector.  It makes it easier for new people to sign up, and
to use one's preferred client without the server having to track that.

#### Clients

**Element** is the flagship client, with web, desktop, and phone versions.
You should use `Element X`, the faster and better latest version.  Element
Classic will be phased out soon.  There is also Element Pro for organizations.

There are many *other clients*: Cinny, Schildichat, FluffyChat, NeoChat, Nheko,
Fractal, Hydrogen Web, Gomuks, Syphon, and so many more.

There are also *plugins* for several general purpose chat clients like WeeChat,
Pidgin, Finch, Thunderbird, and more.

You can also think of *gateways* (e.g. with IRC or Discord) to be a form of client, if you prefer to use these as your daily user interface.

#### Beeper

Here's a cool hack: if you are using Beeper (a chat aggregator app supporting
discord, whatsapp, signal, linkedin, googlechat, slack, etc) then you are
already using matrix under the hood, and you already have a matrix client in
the form of Beeper, and a matrix user address, which is `@you:beeper.com`.
This user address can be invited into any matrix chat room, and it just works.
So you can use Beeper as both your client and your user address.

#### Why so many choices?

Because it's an open system.  Some components will be better, some worse,
but the point is you get to choose.

A helpful mindset: pretend you're still in proprietary jail, go with the
defaults, and then explore your options later if/when the need arises.

------------------------------------------------------------------

## Further information

* [Element, the official client](https://element.io/)
* [Wikipedia: Element](https://en.wikipedia.org/wiki/Element_(software))
* [Matrix.org Foundation](https://matrix.org/)
* [Wikipedia: Matrix](https://en.wikipedia.org/wiki/Matrix_(protocol))
