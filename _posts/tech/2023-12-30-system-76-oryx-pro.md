---
layout: post
title:  "System 76 Oryx Pro"
date:  2023-12-30 20:03:34-0800
categories:
  - tech
  - computer
  - linux
---
# System76 Oryx Pro

My employer bought me a [System76 Oryx Pro](https://system76.com/laptops/oryx) which I customized with a Nvidia 4070, 32 GB of RAM and 2TB of extra NVMe storage. It came out to almost $3000 including tax and shipping.

My intended use is for software development, audio engineering and AI research and development. So far so good! It's a great computer. I removed the Pop!_OS distribution created by the vendor and replaced it with Ubuntu Studio 23.10. All the hardware does what I expect. The GPU has decent specs. Here's the output of `nvidia-smi`

```
Sat Dec 30 20:29:41 2023
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.129.03             Driver Version: 535.129.03   CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA GeForce RTX 4070 ...    Off | 00000000:01:00.0 Off |                  N/A |
| N/A   51C    P8               3W / 115W |     31MiB /  8188MiB |      0%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+
```

In the office it can drive two 27" displays connected via DisplayPort to a Thunderblot 3 dock. This was non-trivial to set up. More on that later. It runs with the built-in screen, which means the GPU can power three screens. I keep the lid closed when it's on the desk. I'm using it more like a desktop workstation. It's pretty heavy and with the GPU has about 2 hours of battery life.

The vendor is very good with their hardware specs. [They publish](https://tech-docs.system76.com/models/oryp6/repairs.html) detailed technical documentation for all hardware components. While all the hardware works as I expected, that doesn't mean I think it's perfect. Here's some notes.

## REALLY LOUD FANS! HOLY SHIT. 

This computer is not acceptable to have in a meeting room. It's quite embarassing when the fans kick in.

## Oversized built in keyboard and off-center trackpad 

Why is there a number pad on a laptop? No one has ever asked for a keyboard like this. I constantly press the up arrow or the number 4 when trying to use the left shift and enter keys. It feels like it was designed by someone who never used a keyboard before.

The trackpad is offset to the left of center. No idea why, I guess to "free up space" for the number pad that I don't want to use?

## Ambiguous USB-C connectors 

It has two USB-C connectors, one on the rear and one on the right. Only one of these supports Thunderbolt 3. The one on the right side with the electric spark icon, which is very small and easy to miss. The rear USB-C connector is just USB-C and has a normal USB icon. This can be confusing when connecting a Thunderbolt display or adapter to the rear, as it will appear broken.

## Short radio range
 
The Bluetooth and Wifi chips are on the same module and each antenna connection has a shorter range compared to other devices. 

The bluetooth radio with airpods pro drops out at about 20 feet compared to the same headphones paired with an iPad Pro, which has no drop outs for 25 to 30 feet.

The wifi radio 2.4 GHz has about half the of my iPad Pro from the same location.

## Kernel drivers crash intermittently

The bluetooth driver just like, crashes sometimes. The icon disapears from the KDE toolbar.

The Thunderbolt driver crashes when my docking station is disconnected and reconnected...sometimes. After a memory dump to `dmesg` the dock continues to work for the displays but not as a USB hub or Ethernet adapter. A restart is required.

* kernel has some weird thunderbolt bug that's intermittent. It supported dual Thunderbolt to DisplayPort displays on the first try, when the StarTech adapter was trusted but after a disconnect, the second display failed. See NOTES-.txt for debugging information.
* It appears the problem is in the docking station not the kernel driver. it only supports dual displays when the hardware is connected in a specific order with a cable that's rated for 


*** Thunderbolt dock problem ***

I have a [StarTech tb3cdk2dp](https://www.startech.com/en-us/universal-laptop-docking-stations/tb3cdk2dp) which when both DP displays are connected outputs the following error. Only one display is detected.

```
[  132.442842] thunderbolt 0000:00:0d.2: 1:11: DP tunnel activation failed, aborting
```

The solution is kind of random. I started with a cable that is rated for "100W at 10gb/s". Not all USB-C cables are the same. There's a neat video by Adam Savage's Tested [which explains why Apple's retail price is $130](https://www.youtube.com/watch?v=AD5aAd8Oy84) for a USB-C cable. You can get them cheaper but the data/power rating does matter for driving multiple displays.

The dock seems to have some weird bug which depends on the ports connecting in order. Here's what consistently works.

1. Connect thunderbolt 3 cable to right side of laptop computer (the only thunderbolt
2. Connect DP port 2 going to upper right display
3. Boot computer
4. Connect DP port 1 going to upper left display *after logged in*
