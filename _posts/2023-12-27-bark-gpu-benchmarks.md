--- layout: post
title:  "GPU Benchmarks with Bark"
date:  2023-12-27 14:11:32-0800
categories: me
---

## What is Bark?

It's an open source pre-trained model for generating audio samples from text. The results are natural sounding human speech with numourous presets. The model is available for free on Hugging Face and inference can be done from it using the Transformers library from the same group.

## How does it perform?

On a `NVIDIA 4070 Laptop` I can generate three 6 second arrays of speech from the following inputs in 26 seconds.

```python
input = ["",
         "",
	 ""]
```

The samples are output into an array but it still takes the full amount of time to get the first byte of samples from the first item in the list. This would imply that if there is a way to either run some of the stages in parallel or determine when the first sample of audio is written into the array, it could be possible to stream the output. Especially considering the results from running on a `NVIDIA H100 PCIe` leased in the South Africa (ZA) availability zone. The same notebook returns the first byte in 16 seconds.

I think I understand how people are publishing their own benchmarks and claiming "realtime". The H100 generates three audio files in 18 seconds. The inference function call returns in 16 seconds, which means for the total sample output, it's "faster than real time."

[A blog named Balacoon](https://balacoon.com/blog/dissecting_bark/) published an interesting break down of the different stages with some of their own benchmarks of each stage. It's nice to see I'm not the only one asking these questions.

## Streaming output

Given that the H100 *technically performs at 1.4x realtime, if it can get the audio samples out as they are *streaming into the array* it seems reasonable it could output samples faster than realtime with a ~400 ms buffer.

The next challenge is to figure out how to do it.
