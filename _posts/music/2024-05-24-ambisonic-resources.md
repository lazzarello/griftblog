---
layout: post
title:  "Academic and Open Source Ambisonic Resources"
date:  2024-05-24 13:17:16-0700
categories: 
  - audio
  - tech
---

Spatial Audio is hot! There is a bunch of academic research and open source software implementing higher order Ambisonics. These are my notes, with some comparisons of DSP + programming platforms I have evaluated.

## [ChucK](https://github.com/ccrma/chuck)

A strongly timed strongly typed language built upon the RtAudio C++ library. All code executes in a virtual machine and is sample accurate.

### Pros

* Small C++ codebase
* Compiles quickly and easily on Linux
* Runs in a web browser
* Runs on mobile devices
* Has plugin system
* Runs in video game engines
* AI Stuff!

### Cons

* Ambisonic plugins are slim to none
* C++ codebase
* The virtual machine is 4400 lines of C++, written in 2002

## [SuperCollider](https://github.com/supercollider/supercollider)

A DSP engine and object oriented programming language for sound synthesis.

### Pros

* Has [IEM encoder/decoder up to 3rd order!](https://github.com/supercollider-quarks/AmbIEM)
* Has an [Ambisonic Tool Kit](https://www.ambisonictoolkit.net/documentation/supercollider/)
* Huge international user community
* Supports higher order and single order Ambisonics
* Built in Binaural decoding with measured and synthetic HRTFs
* Packaged in Ubuntu Studio through the sc3-plugins package
* There is [a whole class online with a week dedicated to Ambisonics](https://www.youtube.com/watch?v=VvI56TnY8tA)

### Cons

* Deep roots in academic language
* Complex architecture
* New jargon beyond yaw/pitch/roll, i.e. incidence, quality, gain. Yikes!
* [HRTF data for IEM plugins is pretty old](https://sound.media.mit.edu/resources/KEMAR.html)

## [Pyo](https://github.com/belangeo/pyo)

A framework for DSP implemented in Python. It has a [Binaural generator that looks pretty simple](https://belangeo.github.io/pyo/api/classes/pan.html#pyo.Binaural). Has an advantage of being implemented in the same language as the GenAI text-to-speech I'm looking to use.

### Pros

* The Binuaral encoder/decoder does all the HRTF stuff internally
* The example code works first try
* Integrates with the TTS stuff I already know
* Built in GUI classes
* Could integrate something in TouchDesigner to do OSC for x/y/z + distance

### Cons

* JACK audio output not built into wheel, requires a custom build
* Python isn't gonna run on a phone or a watch
* Pyo uses wxPython which is...interesting
