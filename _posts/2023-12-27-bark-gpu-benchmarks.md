---
layout: post
title:  "GPU Benchmarks with Bark"
date:  2023-12-27 14:11:32-0800
categories: me
---

## What is Bark?

It's an open source pre-trained model for generating audio samples from text. The results are natural sounding human speech with numourous presets. The model is available for free on Hugging Face and inference can be done from it using the Transformers library from the same group.

## How does it perform?

On a `my laptop GPU` I can generate three samples of speech from the following inputs in 26 seconds. the samples are output into an array but it still takes the full amount of time to get the first byte of samples from the first item in the list.

On a `NVIDIA H100 PCIe` leased in the South Africa (ZA) availability zone the same notebook returns the first byte in 16 seconds.

[A blog named Balacoon](https://balacoon.com/blog/dissecting_bark/) published some performance results.

## Other results

Someone else says they are getting realtime performance [how?] from published benchmarks. *link to results*

I think I understand how people are publishing these benchmarks and claiming "realtime". I'm typing up my results now.
tl;dr is the H100 generates three audio arrays (files) in 18 seconds and the inference function call returns in 16 seconds, which means for the total sample output, it's "faster than real time."

## Streaming output

Given that the H100 *technically performs at 1.4x realtime, if it can get the audio samples out as they are *streaming into the array* it seems reasonable it could output samples faster than realtime with a ~400 ms buffer.
