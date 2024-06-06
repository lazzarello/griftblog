---
layout: post
title:  "building arcade linux"
date:  2024-04-28 09:43:16-0700
categories:
  - tech
  - games
---

I'm teaming up with [DSM Arcade](https://dsmarcade.com/) by way of [Meshoff studios](https://messhof.com/) to build an arcade cabinet software management system. Not quite as glorious as being a game developer but just as necessary. Here's a rundown of the problem.

## Background

One afternoon while visiting my friends at Meshoff studios they gave me a tour of all the new stuff going on. While I've seen a Nidhogg II arcade cabinet in the wild (shout out to [Jupiter in Seattle](https://www.jupiterbarseattle.com/)) I hadn't thought about all the work that goes into making something like this happen. It's one thing to release a game on Steam but it's an entirely different thing to release a game into a custom built retro-future video arcade cabinet built by hand. After some beers and conversation, I discovered that a big problem with a DIY build is getting game updates onto the cabinets host PC. Another one is managing customer units and reporting game play telemetry back to the developers.

## But It's Just Linux

When I found out the cabinets are running Ubuntu desktops, I figured it's just Linux, how hard can it be to customize the startup sequence? The answer is...not too hard but considerably more than I expected. Here are the basic requirements.

* Before shipping a cabinet, install an LTS Ubuntu desktop on the internal PC
* Run a script as root to install/configure system boot and package dependencies
* Run a script as the game user to customize the Gnome desktop settings for an always-on video game display
* Register the host to a centralized server to get game updates
* Install a game through centralized server
* Apply game configuration profile to start on boot
* Reboot and test if the startup sequence happens as expected

## How do Linux Games Work?

I did not really know the answer before this project other than Steam and Proton are great. I can run Elden Ring on my Ubuntu desktop at home! The games I'm working with are built exclusively in special IDEs. Let's see what we're working with.

[GameMaker Studio](https://gamemaker.io/en) is "The Ultimate 2D Game Engine." All right! I don't have much game development experience but I'm good at getting software to work on Linux. Here we go! [It looks like Game Maker has a complex, branching set of instructions](https://help.gamemaker.io/hc/en-us/articles/235186168-Setting-Up-For-Ubuntu) and procedures to build, package and install games on Ubuntu. I first tried the AppImage installer option but that introduced bugs in a game that was already released. Rather than debug a new thing, I looked for ways to package the existing binary releases, which are ZIP archives in a Google Drive account. The only version management is the filename and a string output in the game's boot screen.

Another IDE for DSM arcade titles is Unity 3D. Unity is "the world’s most popular development platform for creating 2D and 3D multiplatform games and interactive experiences." It is considerably more complicated than GameMaker and boasts a single platform that can built the same game for 20 targets, including popular consoles. It also is free for personal use and has [first-class IDE support on Linux](https://unity.com/download).

I choose the [Canonical Snapcraft](https://snapcraft.io/) system for packaging software on Ubuntu. That will be a future post. It's not trivial to set up but allows for remote updates, version channels, rollbacks, and custom dependencies apart from the host OS.

## Registering To A Server

Each host should have some kind of internet connection. With that, it is possible to use [Canonical's Landscape](https://ubuntu.com/landscape) service to register each host to a central server. Once registered, a server admin must approve the new host, which prevents shipping passwords onto the hosts themselves. From there the server has full remote control of the host. It can run shell scripts, install and update packages and apply configuration profiles.

It is possible to register the new cabinet host to a configuration server rather than running shell scripts manually. This limits base OS provisioning to image install, and user login. Then the operator only has to manage the new cabinet through the server GUI. This is a bit more set up on the server side and would require the server to execute a shell script remotely as root for the first stage. Is this an improvement or a distraction?
