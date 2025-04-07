---
layout: post
title:  "pipewire inside container"
date:  2025-04-04 11:13:09-0700
categories: [tech, music]
---

I'm working on a [speech transcriber and translator built](https://github.com/lazzarello/transcriber?tab=readme-ov-file) on the Whisper v3 large LLM. My goal is to have a long-running node in my laptop's pipewire graph that can accept any source to connect to its sink and if the input is speech, transcribe that into text. I've found this built into many individual apps and mobile devices but haven't yet found a general purpose transcriber that runs without a GUI and just takes sound as input.

A nice person posted some details about [how to get sound into a container from a pipewire server on the host.](https://github.com/lazzarello/transcriber?tab=readme-ov-file) This worked first try, which means I can use my laptop microphone or any other Pipewire source as input to this transcription engine running inside the container.

This is particularly helpful for doing audio LLM stuff within a container with all the CUDA and container toolkit stuff installed as to try to make things a bit more portable.
