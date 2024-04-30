---
layout: post
title:  "building arcade linux"
date:  2024-04-28 09:43:16-0700
categories:
  - tech
  - games
---

I'm teaming up with [DSM Arcade](https://dsmarcade.com/) by way of [Meshoff studios](https://messhof.com/) to build an update to their arcade cabinet software management system. Not quite as glorious as being a game developer but just as necessary. Here's a rundown of the problem.

## Background

One afternoon while visiting my friends at Meshoff studios they gave me a tour of all the new stuff going on. While I've seen a Nidhogg II arcade cabinet in the wild (shout out to [Jupiter in Seattle](https://www.jupiterbarseattle.com/)) I hadn't thought about all the work that goes into making something like this happen. It's one thing to release a game on Steam but it's an entirely different thing to release a game into a custom built retro-future video arcade cabinet built by hand. After some beers and conversation, I discovered that a big problem with a DIY build is getting game updates onto the cabinets host PC. Another one is managing customer units and reporting game play telemetry back to the developers.

## But It's Just Linux

When I found out the cabinets are running Ubuntu desktops, my initial reaction was it's just Linux, how hard can it be? The answer is...not too hard but considerably more customized than installing Steam and clicking an install button. The basic requirements are the following

* Before shipping a cabinet, install a standard Ubuntu desktop on the internal PC. Version info in a following chapter.
* Run a script as root to install/configure system boot and package dependencies.
* Run a script as the game user to customize the Gnome desktop settings for an always-on video game display.
* Register the host to a centralized server to get game updates.
* Install game through centralized server.
* Apply game configuration profile.

## How do Linux Games Work?

I did not really know the answer before this project other than Steam and Proton are great, they sure did make Linux gaming better! I can run Elden Ring on my Ubuntu desktop at home! The real answer is there's more than one way to do it. Let's see what we're working with.

[GameMaker Studio](https://gamemaker.io/en) is "The Ultimate 2D Game Engine." All right! I'm not a game developer myself but I'm real good at getting software to work on Linux. So here we go! [It looks like Game Maker has a complex, branching set of instructions](https://help.gamemaker.io/hc/en-us/articles/235186168-Setting-Up-For-Ubuntu) and procedures to build, package and install games on Ubuntu. Their version requirements are very particular...more TBD. Our goal is to make a single AppImage installer, install the game on our new host and load the game at system boot and/or user login.

Other game build systems and runtimes are TBD when those games are delivered. I expect they will have something to do with Unity.

## Registering To A Server

Each host should have some kind of internet connection. With that, it is possible to use [Canonical's Landscape](https://ubuntu.com/landscape) service to register each host to a central server. More on the details of this server build in a following chapter. Once registered, a server admin must approve the new host, which prevents shipping passwords onto the hosts themselves. From there the server has full remote control of the host. It can run shell scripts, install and update packages and apply configuration profiles.

It is possible to register the new cabinet host to a configuration server rather than running shell scripts manually. This limits base OS provisioning to image install, and user login. Then the operator only has to manage the new cabinet through the server GUI. This is a bit more set up on the server side and would require the server to execute a shell script remotely as root for the first stage. Is this an improvement or a distraction?

## That's It!

I plan to keep a log here as the project progresses. I'll have chapters with technical details and notes on the bring-up process.
