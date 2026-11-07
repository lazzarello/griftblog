---
layout: post
title:  "Voxtype For Transcription"
date:  2026-11-07 10:28:59-0800
categories: [linux, transcription]
---

## The call is coming from inside the house

*Part 2 of a series on leaving Omarchy for NixOS. [Part 0](https://blog.griftmarket.com/tech/politics/2026/10/09/moving-off-omarchy.html) is the why,
[Part 1](https://blog.griftmarket.com/tech/nixos/2026/10/28/desktop-parts-to-whole.html) is the desktop environment. This one is dictation,
the feature I was most worried about losing.*

Voxtype is a push-to-talk voice-to-text tool. It has a background meeting feature with chunked transcription of arbitrary length and speaker diarization, which puts it in the same class as commercial products like Granola. It is the
single piece of software I was most anxious about moving. Dictation is the
feature I'd actually miss, and unlike a bar or a launcher there's no obvious
substitute I already know that runs with local models and integrates the UI into the desktop shell.

The good news came first: **Voxtype ships an
official NixOS flake.** Six package variants, a NixOS module, a Home Manager
module. I'm not set up with Home Manager. I'd budgeted an evening for writing a derivation and instead spent
twenty minutes adding a flake input.

Then I spent considerably longer than an evening on the fact that transcription
worked perfectly but the transcribed text disappeared.

## Where it came from

Worth noting what I was migrating *from*, because it reframes the whole exercise:

```
$ pacman -Qo /usr/bin/voxtype
error: No package owns /usr/bin/voxtype
```

My working, beloved dictation setup was a hand-installed binary tree in
`/usr/lib/voxtype/` that no package manager knew about. Omarchy strikes again!

So the NixOS version is not merely equivalent, it's the first time this tool has
been *described* outside of the Omarchy curation.

## Loose the robots

I decided to prompt the Pi coding agent to install Voxtype rather than follow the upstream project's documentation for NixOS myself. It worked...eventually. Each of the three failures had the same structure, and it's the same structure as
the cursor bug from last time:

> **A thing was installed and working. The consumer couldn't see it. The error
> message pointed somewhere else.**

Let's go in order

### 1. The OSD that was "not installed"

One of Voxtype's cool UI features is there isn't one. It's built into the desktop environment via a On Screen Display (OSD) that overlays a waveform and level meter during push-to-talk. The daemon came up, loaded a model, and then:

```
WARN  preferred frontend 'voxtype-osd-gtk4' not installed; using 'voxtype-osd-quickshell' instead
voxtype-osd-quickshell: could not find 'shell.qml' for the Quickshell OSD.
ERROR OSD child exited 3 times within 5s. Giving up
```

The first line was true when I read it — the main voxtype package ships only a
launcher, `voxtype-osd`, which execs into a *separate* frontend package. The
flake publishes `osd-gtk4` and `osd-native` as distinct outputs and I'd installed
neither. One line of Nix fixed that.

Except the warning didn't go away. The binary was on my PATH:

```
$ command -v voxtype-osd-gtk4
/run/current-system/sw/bin/voxtype-osd-gtk4
```

...and the daemon still said "not installed." Because the daemon's PATH is not
my PATH:

```
$ tr '\0' '\n' < /proc/$(pgrep -f 'voxtype daemon')/environ | grep ^PATH
PATH=/nix/store/...-wtype-0.4/bin:/nix/store/...-dotool-1.6/bin:...
```

Two things combined. Upstream's wrapper does `--prefix PATH` with only its own
runtime dependencies. And a **systemd user unit gets a minimal PATH that
excludes `/run/current-system/sw/bin`**. So `environment.systemPackages` put the
OSD on my interactive PATH and nowhere near the daemon.

The fix is to put it on the unit's path explicitly:

```nix
systemd.user.services.voxtype.path = [ osdPackage ];
```

### 2. The stale unit that outranked the declarative one

I made that change, rebuilt, restarted, and the OSD still failed.

```
$ systemctl --user show voxtype -p FragmentPath --value
/home/lee/.config/systemd/user/voxtype.service
```

Not `/etc/systemd/user/voxtype.service`. There were two unit files:

```
~/.config/systemd/user/voxtype.service  -> /nix/store/rliqszql...  (stale)
/etc/systemd/user/voxtype.service       -> /nix/store/zld27sx9...  (current)
```

A unit in `~/.config/systemd/user/` **shadows** the system one. That file was
left over from an earlier `voxtype setup systemd`, and it pointed at a store path
from before my fix. My declarative change was real but had no effect .

This is the sharpest NixOS lesson of the whole exercise, and it's a mirror image
of the `sudoers` surprise from last time. There, I edited a file by hand and
activation silently reverted it. Here, a *leftover* hand-made file silently
overrode activation. The generalisation:

> **Declarative configuration only wins where it's actually consulted.** In
> `/etc`, NixOS regenerates and your edits lose. In `~/.config/systemd/user/`,
> your old edits win and the declaration loses.

Anything set up by a `setup systemd` helper before you declared it in Nix is a
footgun. `systemctl --user show <unit> -p FragmentPath` is how to get an answer.

### 3. The one I caused myself

With the OSD finally running, transcription worked but text output failed:

```
INFO  Transcribed: "Hello and hello, this is Transcribing."
ERROR Output failed: All output methods failed. Ensure wtype, dotool, ydotool, wl-copy, or xclip is available.
```

`wtype` was installed and worked from a shell. So did `wl-copy`.

I turned on `RUST_LOG=debug`, and there it was:

```
DEBUG Running pre_output hook: swaymsg mode voxtype_suppress
WARN  pre_output hook failed to execute: No such file or directory (os error 2)
DEBUG wtype not available, trying next
DEBUG dotool not available, trying next
...
ERROR Output failed: All output methods failed.
```

`swaymsg`. On a machine that is not running Sway.

Earlier, wanting to know how upstream handles a keyboard problem, I'd run
`voxtype setup compositor sway` — purely to *look* at what it generated. But that wrote three lines into my running config:

```toml
pre_recording_command = "swaymsg mode voxtype_recording"
pre_output_command    = "swaymsg mode voxtype_suppress"
post_output_command   = "swaymsg mode default"
```

I had even checked whether it modified my config, grepped for `compositor`,
found nothing, and declared no harm done. The keys are named `pre_output_command`.
I verified the wrong string and reported the wrong conclusion.

## The actual bug, which was none of those

Hooks removed. Restart. Transcription works. Output fails. Identically.

```
DEBUG Default output chain: wtype -> eitype -> dotool -> ydotool -> clipboard (wl-copy) -> clipboard (xclip/xsel)
DEBUG wtype not available, trying next
DEBUG eitype not available, trying next
DEBUG dotool not available, trying next
DEBUG ydotool not available, trying next
DEBUG clipboard (wl-copy) not available, trying next
ERROR Output failed: All output methods failed.
```

**Six** backends, all "not available". At this point I'd verified, individually:

- `wtype "text"` from a shell — works
- `wtype` via `systemd-run --user` — works
- `wtype` with the daemon's exact environment via `env -i` — works
- `wl-copy` — works
- `WAYLAND_DISPLAY`, `XDG_RUNTIME_DIR` present in the daemon's environment
- `zwp_virtual_keyboard_manager_v1` advertised by Niri
- no systemd sandboxing: `ProtectHome=no`, `PrivateTmp=no`, no syscall filter
- a window focused and ready to receive text

Everything worked. Everything was "not available". When six independent things
fail identically, the thing they share is the bug.

Voxtype's flake gives you the source, so I read it:

```rust
// src/output/wtype.rs
async fn is_available(&self) -> bool {
    // Just check if wtype exists in PATH
    // Don't check WAYLAND_DISPLAY - systemd services may not have it
    // wtype will fail naturally if Wayland isn't available
    Command::new("which")
        .arg("wtype")
        ...
}
```

`which`.

It probes for every backend by shelling out to `which`. And `which` is **not a
shell builtin** — it's a package. On NixOS, `/run/current-system/sw/bin/which`
exists, but the systemd user unit's minimal PATH doesn't include it.

So `which wtype` failed with ENOENT. Not "wtype missing" — **`which` missing**.
Every backend probe, all six, in a loop:

```
$ grep -rn 'Command::new("which")' src/output/
src/output/wtype.rs:199
src/output/clipboard.rs:94
src/output/ydotool.rs:210
src/output/eitype.rs:248
src/output/xclip.rs:58
src/output/paste.rs:537,556,569
```

The fix, in full:

```nix
systemd.user.services.voxtype.path = [ osdPackage pkgs.which ];
```

And the error message, one more time:

```
Ensure wtype, dotool, ydotool, wl-copy, or xclip is available.
```

Five programs named. All five present. The missing one isn't in the list.

That fixed it. Dictation now works end to end — hold F9, talk, release, and the
text appears in the focused window about a second and a half later.

### Results

All of the above was created by an LLM session on my own NixOS journey. There may be a better way to do this but I like this story because I can follow along. Some of these points of confusion *feel very human* and could be something that would jam me up too. I don't think I would be as persistent as my Pi coding agent though. Which is kind of nice for projects like this. Wether this is actually a bug upstream as of this writing is TBD but I think the lesson here is interesting.

`Command::new("which")` assumes `which` is present. It usually is, on a desktop
distro, in an interactive shell. But it's a package — `which-2.23` here, and
`debianutils` on Debian — not a builtin and not part of any standard. A minimal
container, a stripped-down initramfs, or any systemd unit with a restricted PATH
hits exactly the same wall. NixOS didn't create this; it just declined to hide it.

There are two separate defects:

1. **The probe is unnecessary.** Rust's standard library can search `PATH`
   directly, and the code even acknowledges it doesn't need certainty —
   "*wtype will fail naturally if Wayland isn't available*" is already the
   fallback strategy. Attempting the command and handling `ErrorKind::NotFound`
   would be both simpler and more correct than asking a second program whether
   the first one exists.

2. **The error message names the wrong thing.** This is the more valuable fix.
   `is_available()` returns a bare `bool`, so by the time the chain gives up,
   *why* each backend was rejected has been discarded. "`which` not found" and
   "wtype not found" are collapsed into the same `false`, and the user is told to
   install five programs they already have.

The second one is what cost me the evening. The first is just tidiness.

## Two things that genuinely couldn't port

Not everything was a misdiagnosis. Two differences are real, and both are about
who owns a keypress.

**Niri has no key-release binding.** My Hyprland config used a matched pair —
`bindd` on F9 press to start recording, `binddr` on release to stop:

```
bindd  = , F9, Start dictation (push-to-talk), exec, voxtype record start
binddr = , F9, Stop dictation (push-to-talk),  exec, voxtype record stop
```

Niri 26.04 has `repeat=` and `cooldown-ms=` but nothing that fires on release.
Push-to-talk, as a compositor binding, is simply not expressible.

The way out is to move the responsibility down a layer: Voxtype can read evdev
directly, below the compositor, and handle hold-to-talk itself. That works — it
needs your user in the `input` group, which mine already was, because
DankMaterialShell needed it for backlight control. A dependency I'd added for an
unrelated reason paid for itself here.

Which produced the next problem. Reading evdev *observes* the key without
*consuming* it, so Niri also forwarded F9 to the focused window, and holding it
to dictate filled my editor with `<F9>` at the keyboard repeat rate.

Upstream's answer for Sway and Hyprland is those hooks — flip the compositor into
a mode that swallows keys during output. Niri isn't supported and has no such
mode. But it has a simpler property: **a bound key is consumed, not forwarded.**
So bind it to nothing:

```kdl
F9 repeat=false hotkey-overlay-title="Dictation (push to talk, handled by voxtype)" { spawn "true"; }
```

Niri eats the key, Voxtype still sees it through evdev. `spawn "true"` because
Niri has no dedicated no-op action so just run the "true" keyword for the command shell. I'm thinking of it like a `while true:` style loop.

**The model was sized for a different computer.** My migrated config specified
`large-v3-turbo`, 1.5 GB, which was a fine choice on a machine with CUDA. Here
Whisper runs on the Intel iGPU through Vulkan:

```
INFO Transcription completed in 55.54s: ""
INFO Transcription completed in 24.91s: "Hello and hello, this is Transcribing."
```

Twenty-five to fifty-five seconds for a six-second clip, and one of them
degenerated to an empty string. `base.en` is about eleven times smaller,
English-only, and turns the same clip around in 1.53 seconds.

```
INFO Transcription completed in 1.53s: "Check 1,2,3 is this thing on."
```

Both models stay installed. Switching is one command. But the config I copied
encoded an assumption about *hardware*, and that assumption didn't survive the
move. Worth remembering when porting dotfiles: some of them are about you, and
some are about the machine.

Oh, and the default hotkey for transcription was ScrollLock, which this ThinkPad does not have.

## What I'd tell myself at the start

The theme across both posts is that **an error message tells you where a program
gave up, not where it went wrong.**

- "no default icon" meant no cursor theme was installed anywhere.
- "voxtype-osd-gtk4 not installed" meant it wasn't on that process's PATH.
- "Ensure wtype ... is available" meant `which` wasn't on that process's PATH.

The habit that would have saved me hours is boring: when something claims a
program is missing, **check the environment of the process doing the
complaining**, not your shell's. I remember this lesson from my formative years from the O'Reilly book Essential Systems Administration. I think it was in the chapter about `cron`.

```sh
tr '\0' '\n' < /proc/$(pgrep -f 'voxtype daemon')/environ
systemctl --user show voxtype -p FragmentPath --value
```

Three separate times in this migration, the answer was "it's installed, and that
process can't see it." That's not a NixOS problem exactly — a Docker container
would behave the same. But NixOS makes it *visible*, because PATHs are explicit
store paths instead of an ambient `/usr/bin` that everything inherits by accident.
The thing that made this confusing is the same thing that made it debuggable.

The `RUST_LOG=debug` drop-in was very helpful:

```ini
# ~/.config/systemd/user/voxtype.service.d/debug.conf
[Service]
Environment=RUST_LOG=debug
```

I set that with a drop-in in `~/.config/systemd/user/voxtype.service.d/` — which
is, yes, the exact directory whose shadowing caused bug #2. Drop-ins are additive
rather than overriding so it was harmless, but I moved it for completeness. It now lives
in `voxtype.nix`:

```nix
systemd.user.services.voxtype.environment.RUST_LOG = "info";
```

One line to raise it to `debug` next time, in a file that's in git.

## Status

Dictation works. F9 to hold, Vulkan-accelerated transcription on the Intel iGPU,
GTK4 OSD, no key spam, `base.en` turning six seconds of speech around in about a
second and a half, text landing in the focused window. Toggle and cancel on
`Mod+Ctrl+X` and `Mod+Ctrl+Shift+X`.

The part I actually care about: the whole thing is now *described* somewhere.
Flake input pinned in `flake.lock`, package variant chosen explicitly, daemon
unit declared, cursor of decisions recorded in commit messages. Compare that with
where I started — a binary tree in `/usr/lib/voxtype/` that `pacman` had never
heard of.

That's the trade this migration keeps making. More ceremony up front; a system I
can still explain to myself in six months. I expect I'll even be able to clone this repo on another thinkpad and make it "just work".

## Next

Part 3 is screen capture and file sharing — screenshots, screen recording, and
LocalSend.
