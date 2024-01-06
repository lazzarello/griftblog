---
layout: post
title:  "Cloud GPU For Speech Synthesis"
date:  2024-01-06 12:00:13-0800
categories:
  - speech
  - generative
---
There are so many cloud GPU services! In the landscape of hooking up some Nvidia hardware to a server and exposing a virtual machine via SSH, there are many options based all over the world. They are not cheap but some could be considered affordable to an upper class American or a small corporation.

My current fascination with GPUs is for speech synthesis. There is a nacent open source community publishing pre-trained models, default configurations and python libraries to generate very realistic audio samples from text input. AKA Text To Speech (TTS). There are also open source training interfaces to make unique speech models but that's for another journal entry. I'd like to focus on a quick and easy web API to do realtime (or faster) TTS.

I'm working with [my own fork of the TTS project by Coqui](https://github.com/lazzarello/TTS) which has about three years of development and is still active. The organization Coqui shut down around December of 2023 and there are 2800 forks of this code. I haven't made enough changes to submit a PR yet.

Their XTTS pre-trained model is ~ 2 GB and is loaded into GPU memory on server startup. It has [a non-commercial license](https://coqui.ai/cpml) with an option to pay a fee for commercial use. I'm not sure how that would happen now that the licensing corporation is gone. For evaluation and research we're fine for now. I suspect this license might only intend to cover their pre-trained model, so it could be possible to train your own for commercial purposes.

In an unusual turn of events, there is a [static method in the module's code](https://github.com/lazzarello/TTS/blob/dev/TTS/utils/manage.py#L310) which requires an interactive agreement of this license. It is easily circumvented by downloading the model yourself and writing a text file to that path.

I'll only be working with this XTTS model but in the future exploration of loading other TTS models into this library sounds like fun! Alright, here we go!

## Getting a GPU

### A laptop computer

[A previous post](/tech/computer/linux/2023/12/31/system-76-oryx-pro.html) has the specs on the highest end GPU I can access with mine own hands. It's quite good! Running the server and client in the [fastapi-server directory](https://github.com/lazzarello/TTS/tree/merge-fastapi-server/fastapi-server) on this laptop gets about 1.4x realtime performance! The fans are loud but the performance is good!

Now that we have this benchmark, let's check out some cloud GPU services. The goal is to get equivilent or better performance for the same price. 

### Runpod

Runpod advertises as "The Cloud Built for AI." They have data centers in many regions. I'm concerned about those in the United States. In their "community cloud" region (which happens to be two facilities in Kansas City, but they don't tell you that at first) there is a $0.25 per hour server with a Nvidia RTX 4080 Ti. That comes out to about $6 a day for on-demand GPU. Not bad.

Deploying a server is pretty easy through their GUI and connecting via SSH is also quick. Their default machine image has PyTorch and all the Nvidia + CUDA bits installed at boot time. Downloading and installing the TTS code and models was quick and simple.

Booting up the XTTS server was simple. That's it! Now I have what looks like the equivilent GPU or maybe better to my laptop. Let's test it out.

To my surprise, the same requests for the same text to speech input with the same model took three times as long as on the laptop! Monitoring the GPU usage via `nvtop` provided some hints as to why. This is all speculation, Runpod is a black box. They could be using Kubernetes behind the scenes for all I know, though the server *feels like* a virtual machine.

Requests to this server never exceeded 25% GPU usage, while the same requests to my laptop exceeded 75% GPU while generating audio. While all speculation, I shut down this deployment to look elsewhere.

## Amazon Web Services (AWS) or The Ubiquitus API for Cloud Stuff

I'm no fan of AWS in this current timeline. I mean, it was exciting when the EBS storage came out in EC2. I guess it's alright. Regardless of what I feel, I've built a pretty good career deciphering their marketing materials, service names with duplicate functionality, documentation and pricing policies. I sell these skills to corporations who want to decide To Cloud or Not To Cloud. The "ops" side of the "DevOps" profession. So I guess I am a fan? IDK, they just are like the most ubiquitour public cloud platform.

Let's see what GPU stuff they have in the us-west-2 region, which is located in the state of Oregon. Here's a table!

| Instance | Product Type | Product Series | Product   |
|----------|--------------|----------------|-----------|
| G2       | GRID         | GRID Series    | GRID K520 |
| G3       | Tesla        | M-Class        | M60       |
| G4dn     | Tesla        | T-Series       | T4        |
| G5       | Tesla        | A-Series       | A10       |
| G5g      | Tesla        | T-Series       | NVIDIA T4G|
| P2       | Tesla        | K-Series       | K80       |
| P3       | Tesla        | V-Series       | V100      |
| P4d      | Tesla        | A-Series       | A100      |
| P4de     | Tesla        | A-Series       | A100      |
| P5       | Tesla        | H-Series       | H100      |

Whew! If you want [to melt your brain like I did read their docs yourself](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#public-nvidia-driver) though I don't recommend it. I have so many opinions about this misleading and confusing document. But hey, maybe there's a better way? Like, some AMI that "just works"?

We're only doing compute stuff so we only care about the "Tesla drivers." I don't really know what that means. My laptop is running Ubuntu Studio with version 23.10 and I installed Nvidia drivers from the distro's own package repository. Worked first try. I've never paid for an AMI that "enabled Nvidia drivers." It looks like they charge quite a lot for these proprietary AMIs. Maybe there's some free ones?

I found something in the Quickstart AMIs category in EC2 for a "Deep Learning Base OSS Nvidia Driver GPU AMI (Ubuntu 20.04) 20240101". That might be helpful.

Fired up one of those with a G5 instance type. The Nvidia and CUDA stuff is already installed. The login message says there's a conda virtual env outside the system python to access the GPU. It's running an older version of Ubuntu.I try and install PyTorch via conda and it hangs there for about 10 minutes...doing...something?

Shutting this one down and creating a new one with the "Deep Learning OSS Nvidia Driver AMI GPU PyTorch 2.1.0 (Ubuntu 20.04) 20240102" AMI claims to have PyTorch installed at boot through a special conda environment. I run python in a REPL from there and `import torch` but it says it does not have access to the GPU.

Am I being scammed? Perhaps. This is probably what I get for trying to take vendor advice but hey, I'm getting paid by an employer to discover all this stuff! I know I can just like...build an AMI myself. That's what I'll have to do.

## Custom AMI in EC2 with Nvidia, CUDA and PyTorch

Booted up a G4dn.xlarge instance which is an Nvidia Tesla T4 GPU. I used the latest Ubuntu Server 22.04 release. Installing all the Nvidia stuff was this easy. It takes about 10 minutes.

### Install Nvidia kernel drivers

```
sudo apt-get install $(nvidia-detector)
sudo modprobe nvidia
sudo apt-get install nvidia-cuda-toolkit
```

Here's the output of `nvidia-smi` after the install is completed. Looks like we got it!

```
Sat Jan  6 22:26:57 2024       
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.129.03             Driver Version: 535.129.03   CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  Tesla T4                       Off | 00000000:00:1E.0 Off |                    0 |
| N/A   26C    P0              26W /  70W |   2905MiB / 15360MiB |      0%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+
                                                                                         
+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
|    0   N/A  N/A       446      C   /home/ubuntu/TTS/.venv/bin/python          2900MiB |
+---------------------------------------------------------------------------------------+
```

Ignore the Processes for your experiment if you're following along. That is my TTS server on the running instance.

### Install PyTorch

The following takes about 5 minutes and downloads some pretty big python wheels which sum to ~ 6 GB in the virtual environment.

```
sudo apt install python-is-python3 python3.10-venv libpython3.10-dev
python -m venv .venv
source ./venv/bin/activate
pip install torch torchvision torchaudio
```

Let's see if torch sees the GPU.

```
(.venv) ubuntu@ip-172-31-2-106:~/$ python
Python 3.10.12 (main, Nov 20 2023, 15:14:05) [GCC 11.4.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import torch
>>> torch.__version__
'2.1.2+cu121'
>>> torch.cuda.get_device_name(0)
'Tesla T4'
```

After I got the rest of the things to run, my text-to-speech server performed **even better than my laptop!** Yea! The GPU was being fully utilized and results were about 2x realtime. Whew! Looks like making a custom AMI is the only way to go.

### EC2 Pricing (is as complex as cloud computing)

This is not a post about pricing in AWS. These nice people at Vantage made [a good interface to EC2 instance pricing](https://instances.vantage.sh/aws/ec2/g4dn.xlarge?selected=g4dn.xlarge) so I'm just gonna use that.

As we can see, this single instance is a little less money per-month than a poorer performing GPU at Runpod. Though I'd imagine with the storage volumes needed for models and all the GPU software it'll end up costing a bit more in aggregate.

## Conclusion

If you're read this far, thanks. My conclusion is that as of this writing, it's worth it to build your own AMI and just do GPU stuff in EC2. More flexable and cheaper than the other "best for AI" platforms.

Deployment can be a bit tricky, which is why I'm using Terraform. That's also for another post.
