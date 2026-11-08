---
layout: post
title:  "Screen Recording"
date:  2026-11-08 11:14:50-0800
categories: [linux, nixos] 
---
## Screenshots, Video, mobile sharing

*Part 3 of a series on leaving Omarchy for NixOS. [Part 0](https://blog.griftmarket.com/tech/politics/2026/10/09/moving-off-omarchy.html) is the why,
[Part 1](https://blog.griftmarket.com/tech/nixos/2026/10/28/desktop-parts-to-whole.html) is the desktop environment, [Part 2](https://blog.griftmarket.com/linux/transcription/2026/11/07/voxtype-for-transcription.html) is
speech-to-text dictation. This one is screen capture and file sharing — the utilities that are boring until you don't have them.*

These are the tools I use without thinking, which is exactly why losing them
hurts more than losing something flashy. This is something that I like about both macOS and Windows defaults. Graphical screen sharing is business-as-usual.

Three things in this post: screenshots (already worked, for a reason I had wrong),
screen recording (broken, and the failure is a good example of the pattern running
through this whole series), and LocalSend for mobile to desktop file/clipboard sharing (worked first try)!

## Screenshots: already working, and I was wrong about why

They worked on the first boot after the desktop came up, so I nearly didn't look
into it. When I did, I found I'd assumed the wrong mechanism.

I'd assumed `grim` and `slurp` — the standard wlroots screenshot pair, which is
what I'd have reached for and what most guides tell you to install. They aren't
what's running. Screenshots are a **Niri built-in action**:

```kdl
Print       { screenshot; }
Ctrl+Print  { screenshot-screen; }
Alt+Print   { screenshot-window; }
```

Niri has its own screenshot UI with region select, and it writes to both the
clipboard and a file. No external tool, no portal dance, nothing for me to
configure or keep working.

This is a small thing but it's the second time in this series I've been wrong
about which component owned a behaviour, and the correction was free both times
because the answer was in a config file.

## Recording: the config was fine, the driver was not installed

Recording is separate from screenshots, and it was broken. Here's the whole
diagnosis:

```
$ ls /run/opengl-driver/lib/dri/*_drv_video.so
nouveau  radeonsi  r600  virtio_gpu  d3d12
```

Drivers for every vendor except the one in this laptop.

`wl-screenrec` encodes on the GPU by default via VAAPI. Coffee Lake needs the
`iHD` driver from `intel-media-driver`, and `hardware.graphics.extraPackages` was
never set, so there was no Intel VAAPI driver installed.

```nix
hardware.graphics.extraPackages = with pkgs; [
  intel-media-driver
  libva-utils      # so vainfo can prove the encode entrypoints exist
];
```

I added `libva-utils` deliberately. `vainfo` turns "recording is broken" into a
list of supported profiles and entrypoints, which is the difference between
guessing and knowing. Worth having installed before you need it.

Recording works after that. Full screen, region select, at whatever framerate is
on screen.

This is the same problem as the cursor theme in Part
1: **nothing was misconfigured, a thing wasn't there.** But that's not a claim
about what every NixOS installation is missing. I chose "No Desktop" in the
installer because the exercise was to build my own desktop environment from the
ground up, rather than start with one assembled for me. Many of these missing
pieces are consequences of that choice. I'm used to debugging systems where a
desktop environment has already supplied the tools and only the settings vary.
Here, I'm also responsible for supplying those tools, so before checking a
setting I need to ask: "have I installed the thing that uses it?"

## One key that has to toggle

Screenshots are one-shot: press, done. Recording needs an explicit stop, so one
key has to start and stop it.

And *how* you stop matters more than I expected. `SIGINT` lets the muxer write the
container trailer; `SIGKILL` leaves a file that no player will open. Which means
the toggle can't just be `pkill -9`, and I lost my first version because of ending the process like this.

So it's a small wrapper with a PID file, packaged as a real derivation with
`writeShellApplication` rather than a loose script in `~/bin`:

| Key | Action |
|---|---|
| `Print` / `Ctrl+Print` / `Alt+Print` | Screenshot region / screen / window |
| `Mod+Print` | Record screen — toggle |
| `Mod+Shift+Print` | Record region — toggle |

`Mod+R` would have been the obvious mnemonic, but it's `switch-preset-column-width`
in Niri, which is a nice feature. The whole `Mod+Print` family was free, and it
keeps every capture binding on one key.

Two things the build caught that I would otherwise have committed:

**ShellCheck is a build-time gate.** ShellCheck is a static analyser for shell
scripts: it reads the code without running it and flags likely bugs, such as
unsafe quoting and fragile ways of handling filenames. Nix's
`writeShellApplication` runs it while building the script's package. A finding
fails that build rather than just printing advice I can ignore, so the script
has to pass before I can deploy it as part of my system.

It rejected my `ls -t | head -1` for finding the newest recording with SC2012:
don't parse `ls` output. That output is meant for people, not reliable filename
handling. The replacement in my script is significantly longer:

```sh
last=$(find "$DIR" -maxdepth 1 -type f -name '*.mp4' -printf '%T@\t%p\n' 2>/dev/null |
  sort -rn | head -1 | cut -f2-)
```

`find` lists recording files with their modification timestamps, `sort -rn`
puts the newest first, `head` keeps that entry, and `cut` removes the timestamp.
More explicit, but hardly less machinery. It handles spaces in filenames, though
it's still a line-based pipeline, so embedded newlines would break it. My script
generates timestamp-only filenames, which keeps that limitation out of the normal
recording path.

**With flakes, `git add` is part of the build loop.** First build after adding the
script:

```
error: ... 1 dependency failed.
       git -C "/home/lee/nixos" add "screenrec.sh"
```

Flakes only see git-tracked files, so a new untracked file is invisible to the
build which usually means the build fails.

## LocalSend, in the "first try" column

```nix
programs.localsend = {
  enable = true;
  openFirewall = true;
};
```

There's a module. It installs the package and opens TCP **and** UDP 53317.

Both halves matter: LocalSend uses UDP for peer discovery and TCP for transfer,
and opening only TCP gets you an app that launches, looks healthy, and never
finds another device. That's a genuinely annoying failure to debug from the UI,
because nothing is obviously wrong — there's just an empty list of peers.

I set `openFirewall = true` explicitly even though it's the default, so the
firewall hole is visible in my configuration rather than implied by a default I'd
have to go read in six months.

Worked first try. Phone found the laptop, files moved both directions.

## Status

Screenshots, screen recording (full and region), and LocalSend: working and in
the flake. One open question I'm deferring: audio device selection for recording.
`--audio-device` takes one device, the right one depends on which sink is
currently active, and that's exactly the kind of thing I'll get wrong in six
months if I don't write it down properly.

## Next

Part 4 is Windows in a container that isn't a container, which I expected to
be the hardest thing in this series and wasn't.
