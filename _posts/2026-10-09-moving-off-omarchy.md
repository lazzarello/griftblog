---
layout: post
title: "Moving Off Omarchy"
date: 2026-10-09 15:49:16-0700
categories:
  - tech
  - politics
---

# I fell for a fascist Linux distro. Here's how I got out before it was too late.

I've been using Linux on the desktop for a while. My last special-purpose distro was
Ubuntu Studio, which I like for the curation of audio and video applications. It used the
KDE Plasma desktop environment, which was basically like running Windows. I used Arch
Linux on some shared desktops at the Noisebridge hackerspace, but I never got into it
myself because I thought I had grown out of customizing my laptop computer.

It was around last winter when a co-worker of mine, who isn't particularly Linux-savvy,
mentioned that DHH (David Heinemeier Hansson) had a new Linux distro. I hadn't heard that
name since Ruby on Rails, which was the first MVC framework that I used professionally. It
is called Omarchy. I ran Omarchy and I liked it. That's the uncomfortable place to start.

It's a genuinely good distribution. The installer hands you a finished tiling desktop in
minutes. The defaults are coherent in a way that almost nothing else in Linux manages —
the bar matches the terminal matches the notifications, the keybindings make sense, the
action menus for screenshots and recording and hardware toggles are the kind of thing you
normally spend a weekend assembling yourself. I had a working, beautiful desktop with
almost no effort. I recommended it to friends and colleagues. Others recommended it to me.

I picked it partly _because_ it was opinionated. DHH has spent twenty years arguing that
opinionated software is better software — Rails is built on it. Omarchy is basically a
curated Arch Linux. DHH calls it _omakase_: chef's choice. I don't want to assemble a
desktop from parts; I have done this, and I feel like I've earned the right to have
someone with taste make the calls.

A few months in, I didn't realize what this public figure stood for. I thought it was cool
that someone from open source software who I hadn't heard from in a while had a fun Linux
distro. I remembered him for a fun web application framework and some subscription
productivity tools. But word started to get out about what he stands for to those like me
who hadn't been paying attention.

## Why I'm never using Omarchy again

[I read the Omarchy Doctrine](https://omarchy.us/doctrine/). It's on their website, it's
signed, it's not a leak or a screenshot of a deleted tweet. It is the project describing
itself in public.

Here's what it says about the community it wants:

> The original hacker cred was all about the code. It didn't care who you were, what your
> background was... Omarchy is bringing that ethos back, and dropping the
> **Code-of-Conduct struggle sessions and identity-overload nonsense** that has plagued
> open source for far too long. We're done with all of it.

"Struggle sessions" is not a neutral phrase. It's a Maoist reference, used deliberately,
to describe codes of conduct — the documents that exist partly so that people who get
harassed at conferences have somewhere to go. You can think CoCs are badly implemented.
That's a different claim than _the entire category is nonsense and we're done with it_.

Here's what it says about governance:

> Omarchy is **not a democracy**. It's a **benevolent dictatorship** in the grand
> tradition of Linux, Ruby, and Rails. The dictator's job is to listen to everyone, but
> make the call according to their intuition, vision, and experience... the buck will
> always have a place to stop.

The model has a name and a pedigree, and the Doctrine is invoking both. **BDFL** —
Benevolent Dictator For Life — was coined in the Python community for Guido van Rossum in
the mid-90s, and the title has since been worn by Linus Torvalds for Linux, Yukihiro
Matsumoto for Ruby, and DHH himself for Rails. One person holds final say on contested
calls. I think it's a strange choice to take pride in being a dictator. I guess it can
move fast and produce singular designs. Linux ran on it for years. But I think one of
these quotes contradicts the other. The original hacker cred was deeply rooted in
identity. Don't get me started on comparing Maoist communism to "a democracy."

In every project the Doctrine names, the dictator operates **inside** a structure that
constrains them. Linux has a code of conduct and a Code of Conduct Committee, adopted in
2018 — alongside Torvalds stepping back from the project specifically to address his own
conduct. Ruby has community conduct guidelines. Rails has a code of conduct, which it
inherits from Ruby's, and which is published on DHH's own project's website today. Python
has one, and a Steering Council that replaced the BDFL entirely when van Rossum resigned
in 2018.

Omarchy takes the first half and explicitly discards the second. "Not a democracy" in the
same document that declares codes of conduct "nonsense" we're "done with" is not the Linux
model, or the Ruby model, or even the Rails model. It's the dictator without the
constraint — which is precisely the part of "benevolent dictator" that was doing the work.

And read together, the two quotes describe something specific: a project that has removed
the mechanism by which people report mistreatment, and located all remaining authority in
one person, who is the same person writing the articles I'll get to shortly. I think DHH's
writing all leads to his support of an "anti-woke" Linux distribution, which sounds insane
to me.

And the aspirational reach of these software tools:

> From billionaires to **anons on X**. From China to Malibu.

That's the constituency. I believe being a billionaire is a treatable condition like many
who have mental illness. These people can heal, and a successful recovery ends with them
no longer being billionaires. Until then, they can run any computer operating system they
like, though I don't think they are particularly underserved on this front today. Anons on
Twitter is wild. Who are these people? Who cares if they need Linux? Why are billionaires
important? I have so many questions.

None of these are quotes I had to dig for or interpret charitably. They're the project's
own summary of its values, and they were there the whole time I was happily running it. I
just hadn't read them.

## It's the Money

This is the part that moved me from "I don't love this" to "I'm leaving."

Omarchy's own front page, today:

> **DigitalOcean joins as a Founding Corporate Patron with $3 million**

Three million dollars, from one cloud provider, to a distribution that is a well-curated
set of Arch config files.

The total is larger. DHH's own announcement of the Omacom Foundation puts it at
[**approximately $23.5 million** in pledges and donations](https://omarchy.us/news/2026/08/omacom-foundation-launches-with-8-million/).
Earlier reports gave smaller figures because the total kept growing:
[Jürgen Geuter (tante) writes](https://tante.cc/2026/09/11/power-grab/) that DHH has
collected **"above 18 million dollars,"** and the article he cites, by Brennan Kenneth
Brown, is titled
[_"Normalized Fascism in Open Source: $12 Million Given to DHH."_](https://brennan.day/normalized-fascism-in-open-source-12-million-given-to-dhh/)
That's a nice fund for developer salaries and probably nice work if you can get it. The
Alibaba Qwen Book has a
[partnership to bring Omarchy to China](https://omarchy.us/news/2026/09/alibaba-cloud-joins-as-founding-corporate-patron/)
through state-controlled content delivery networks. Looks like big business!

tante's argument is that this is best understood as a power grab. Not because corporate
money in open source is new or inherently bad, but because this particular pile of money
is under a fascist's control, and it buys the ability to decide which projects live. His
sharpest observation is about the pressure that creates:

> What kind of pressure can that exert on projects who have to decide to either die due to
> lack of funding or kill their code of conduct?

**My own conclusion**

The Doctrine, the funding structure, and the governance model add up to a fascist project,
and one I want no part of.

## It's the Money and the Power

Is DHH a fascist? The definition I find most useful is Roger Griffin's: fascism as
**palingenetic ultranationalism** — the myth of a fallen people, corrupted by internal
enemies, who must be purified and reborn under a leader who embodies the national will.
Not a policy platform. A structure.

Now read the Doctrine against that structure, remembering it's the project's own
self-description:

**A fallen golden age to restore.** The Doctrine's account is that open source had a pure
ethos that has been "plagued" — their word — and that Omarchy is "bringing that ethos
back." Rebirth of something corrupted. That is the palingenetic move, in their own
sentence.

**Named internal enemies.** What plagued it? "Code-of-Conduct struggle sessions and
identity-overload nonsense." The corrupting agents are, specifically, the people asking to
be treated decently and the documents that let them. "We're done with all of it."
Purification of the movement by excluding them.

**The leader principle.** "Omarchy is not a democracy. It's a benevolent dictatorship...
the buck will always have a place to stop." Authority is personal, not procedural, and
explicitly anti-democratic by its own account.

**Unity as the summons.** A "rallying cry to unite that talent," gathering the scattered
into a single movement behind one goal. Set against an out-group whose concerns are
"nonsense."

That's the structure, not a vibe: mythic restoration, internal enemies to be purged, unity
under a leader whose word is final. Put it next to a man who has written that London
suffered
["demographic replacement"](https://world.hey.com/dhh/as-i-remember-london-e7d38e64)
because it's "no longer full of native Brits"
([archived](https://web.archive.org/web/20250925050154/https://world.hey.com/dhh/as-i-remember-london-e7d38e64)),
and who wrote of Roma people in Copenhagen,
["When wolves get out of control, you shoot them. When gypsies take over public spaces, you deport them."](https://world.hey.com/dhh/wolves-sheep-and-gypsies-ba44af6a)
([archived](https://web.archive.org/web/20260721200429/https://world.hey.com/dhh/wolves-sheep-and-gypsies-ba44af6a)).
The reading is not a stretch. It's the obvious one.

Now add the fundraising figures. Fascism is not merely an aesthetic; it's a bid for power.
A movement with this structure and no money is a forum post. A movement with this
structure and control over one of the larger funding pools in the Linux desktop can make
projects choose between their code of conduct and their survival. That's the part that
converts an objectionable worldview into a political force, and it's why tante's framing —
a power grab — is the right one.

## Too late for what?

The distribution was doing exactly what it was built to do to me, and it was working. I
liked the software, so I recommended it — to friends, in threads, to people asking what to
run. Every one of those recommendations was a small transfer of legitimacy to a project
whose fundraising pitch is precisely its enthusiastic user base. Omarchy's front page is a
wall of influencer clips for a reason: adoption is the asset, and I was quietly working
for free.

The longer that goes, the harder it gets to stop. Not because of lock-in — it's Arch with
config files, you can leave any time — but because you accumulate sunk investment in
tooling, muscle memory, and having publicly vouched for it. People talk themselves out of
noticing things when noticing is expensive. I've watched it happen to others and I have no
reason to think I'm immune. That's the same drift a commenter under tante's essay
describes: you make room for it, the room grows, and reason leaves last.

So: too late to have not spent months recommending a fascist's project to people who
trusted my judgment. I got out at the cost of one week and one blog series.

## Separate the artist from the art

The strongest objection, and worth taking seriously: it's config files. Using them isn't
an endorsement. You can run Omarchy and despise DHH's politics and those facts don't touch
each other.

I believed that for a while. Three things changed my mind.

**The money flows the other way.** Omarchy's value to DHH isn't license fees; it's
legitimacy and reach, which converted into $23.5 million in pledges under his personal
control. Users are the asset. Being one, and recommending it to others — which I did — is
materially useful to the project in a way that running a random GitHub project isn't.

**The Doctrine is the product.** It's not an unrelated blog post by a maintainer. It's
linked from the front page as the thing "behind it all" — ten principles for what this
project is. The politics aren't adjacent to the software; they're the stated design
philosophy of the software.

**It shapes downstream.** The funding decides which compositors and tools get developer
time. That's not a distro choice, it's an ecosystem intervention, and it affects people
who never install Omarchy.

Reasonable people land elsewhere on this. Separating art from artist is a real position
with real arguments behind it. I just don't think it holds when the artist's stated
politics are the product's stated design philosophy and your usage is the fundraising
pitch.

## Moving was easy!

I moved to NixOS with Niri and the DMS desktop shell on a ThinkPad P1 with a spare SSD. At
least it's not fascist on the surface, which is nice. It's also niche enough that I feel
like fewer people are interested. But what I discovered is that it solves the problem that
made Omarchy appealing in the first place in a different way. And it's really cool.

NixOS solves the same problem from the opposite end. The entire system is one description,
in files, in git. When I wanted to replace the login stack — an invasive change, the sort
of thing I'd normally schedule for a weekend — it was a 56-line diff in one file, and a
rollback was one boot-menu selection away.

In this case, the taste I was going for was the initial curation of Omarchy. A week later,
with an AI coding harness and SSH access to NixOS, I had a desktop system with the same
features. It was also educational!

The rest of this series is that build, in detail. GPU handling on a dual-GPU ThinkPad, an
invisible mouse pointer on a greeter screen that took four attempts and taught me more
about NixOS than anything to that point, suspend and power management, and the desktop
pieces I actually cared about keeping, like screen recording, content sharing with my
phone, and a Windows VM as a Docker container. It's a tutorial series on how to get the
same results as Omarchy's curation without following its leader.
