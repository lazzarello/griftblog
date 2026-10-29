---
layout: post
title: "Parts To A Whole"
date: 2026-10-28 10:26:41-0700
categories: [tech, nixos]
---

## A Working Wayland Desktop on NixOS

_Part 1 of a series on leaving Omarchy for NixOS. [Part 0](https://blog.griftmarket.com/tech/politics/2026/10/09/moving-off-omarchy.html) is the why. This one is
bootstrapping a desktop from a text console, and the first real bug._

I put a new SSD in a spare ThinkPad P1 and installed NixOS on it. The goal was a tiling
Wayland desktop that felt familiar but used different software: Niri as the compositor,
[Dux Shell](https://duxlabs.dev/) as the shell, and a graphical login screen.

Most of that went fine. Then I spent an evening chasing an invisible mouse pointer. It was
frustrating, but the interesting part was how little work replacing the login stack
required: one file changed, and I could have undone it from the boot menu if it had gone
wrong.

## What I picked, and how little I knew about it

**I had not used any of this software
before.** I'd heard about Niri from a friend and
listened to an interview with its author online. I heard about Noctalia from the same friend but hadn't tried it yet. That's it.

**Niri** was the core software that everything else fit around. It's a scrollable-tiling compositor: instead of
carving a fixed screen into ever-smaller boxes, windows sit in an infinite horizontal
strip and you scroll along it. Columns keep the width you gave them, and opening a fourth
window doesn't reshuffle the other three. Coming from i3 and Hyprland's dwindle, the thing
I noticed within a few minutes the absence of a specific irritation: new
windows no longer resize everything else by default. This is quite nice on a 15" laptop screen.

**Dux Shell** I chose because I wanted a bar, notifications, a launcher, idle handling,
and a lock screen that all agreed with each other, and I did not want to assemble five
programs when I didn't know where to start with one. It's a Quickshell configuration that does all of it
as one piece. That turned out well, and it also means a fair amount of my desktop's
behaviour lives in _its_ settings rather than in my NixOS configuration — which I'll come
back to later, because it's the one place where the "everything is declared in a file" story we're told by NixOS breaks down.

A naming note: DankMaterialShell became **Dux Shell** in the
[2.0 release](https://duxlabs.dev/blog/v2-0-release).

**Noctalia Greeter** became the alternative when the login screen cursor fixes failed. I had heard of it from a friend and colleague on a programming-centric Discord server. It's separate from the Noctalia desktop shell: changing the greeter
left Niri and Dux Shell in place. It felt nice to easily assemble components for a desktop system, knowing what role each performed.

## Why not Hyprland

The obvious question, since Omarchy is a Hyprland distribution and I was happily using it.

The honest primary reason is [Part 0](https://blog.griftmarket.com/tech/politics/2026/10/09/moving-off-omarchy.html): Omarchy's funding flows to Hyprland's main
developer, and Hyprland's governance has its own history that others have documented at
length and I'm not going to relitigate here. I didn't want my daily compositor to be part
of that arrangement. I was also interested in the state of the art in Linux desktop
components for Wayland.

But there's a second reason, and it's the one I'd have arrived at eventually even if none
of the politics existed: **I could never tell where a setting lived.**

Hyprland is enormously capable, but I never fully mapped the relationship between its
configuration, Omarchy's defaults, and the shell's settings. When something behaved
unexpectedly I could rarely answer "which layer owns this?" without grepping several
directories and guessing. My own migration notes from before any of this started had that
complaint in them almost verbatim: _difficulty discovering which layer controls a
behaviour and how to change it._

Niri's configuration is one KDL file with a documented schema, it has a `niri validate`
subcommand, and it does less. That last part is a feature. I gave up animations I liked
and a plugin ecosystem I'd barely used, in exchange for being able to read my window
manager's configuration in one sitting and predict what it would do.

That trade — fewer features, legible ownership — is the same trade as choosing NixOS, and
it's the actual theme of this whole series. It's also why the mouse pointer bug below was
worth investigating: even the failed attempts helped me map the components involved.

## The hardware

A ThinkPad P1 (`20MDCTO1WW`), which is a pleasantly awkward machine:

| Device                     | PCI address    | Driver    |
| -------------------------- | -------------- | --------- |
| Intel UHD Graphics P630    | `0000:00:02.0` | `i915`    |
| NVIDIA Quadro P2000 Mobile | `0000:01:00.0` | `nouveau` |

The internal panel hangs off the Intel chip. The HDMI and DisplayPort connectors are wired
to the NVIDIA card. So I can't simply blacklist the Quadro and enjoy a quiet laptop — I
need it for external displays — but I also don't want it awake and warm during regular activities like working in many terminals and TUIs on battery.

Installation was the graphical NixOS installer with **No Desktop** selected, which gets
you a working, bootable, entirely text-mode system:

- encrypted ext4 root, separate encrypted swap, FAT `/boot`
- `systemd-boot`
- NixOS 26.05

## Before configuring the GPU, look at it

I wanted to know what the machine was actually doing before I wrote any graphics
configuration. Two things mattered.

First, which card owns which output:

```fish
$ ls -l /dev/dri/by-path/
pci-0000:00:02.0-card    -> ../card1
pci-0000:00:02.0-render  -> ../renderD128
pci-0000:01:00.0-card    -> ../card0
pci-0000:01:00.0-render  -> ../renderD129
```

Note that `card0` is the _NVIDIA_ card here. DRM enumeration order is not a stable
identity — if you find yourself writing `card0` into a config file, you're depending on
numbering that can change between boots or kernel versions. On this machine, the PCI-based
`by-path` names are the better identifiers.

Second, whether the Quadro would actually go to sleep:

```fish
$ cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status
suspended
```

Good. Nouveau runtime-suspends the card when nothing is using it. That's evidence about
idle power, not proof of overnight battery life, and I'm being careful about the
difference.

The plan: render on Intel, leave Nouveau loaded so HDMI works, and _verify the renderer
afterwards_ rather than assuming that being the boot VGA device settles it.

## The desktop, in one file

Here's the first thing that's different from a traditional distro. The desktop wasn't a
sequence of `apt install` invocations and hand-edited files under `/etc`. It was one new
file, `desktop.nix`, imported from `configuration.nix`. Here's an excerpt of the initial
setup, not a complete desktop configuration:

```nix
{ pkgs, ... }:

{
  hardware.graphics.enable = true;
  programs.niri.enable = true;

  programs.dms-shell = {
    enable = true;
    systemd.enable = true;
  };

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    defaultSession = "niri";
  };

  # ... audio, bluetooth, packages
}
```

`nixos-rebuild build` checks it without touching the running system.
`nixos-rebuild switch` activates it and makes it the boot default; `nixos-rebuild boot`
changes the next boot without activating now. I leaned on that separation repeatedly.

That worked on the first try. Graphical login appeared, Niri started, Dux Shell started.
And I confirmed the thing I said I wouldn't assume:

```fish
$ journalctl --user -b -t niri | grep 'render node'
INFO niri::backend::tty: using as the render node: "/dev/dri/renderD128"
```

`renderD128` is `0000:00:02.0` — Intel. Niri also picked up `card0` as a secondary device,
which is exactly what I want: the Quadro is available to drive outputs, but isn't the
primary renderer. Meanwhile the Quadro stayed `suspended`.

## Interlude: my first real NixOS surprise

I got tired of typing my password, so I ran `visudo`, added `NOPASSWD: ALL` for `%wheel`,
and got on with my life. It worked.

It kept working right up until the next `nixos-rebuild switch`, at which point it silently
reverted.

This is obvious in hindsight and worth dwelling on, because the failure mode is sneakier
than the usual NixOS lesson implies. The standard framing is "`/etc` is symlinks into the
read-only store, so you can't edit it" — and when that's true, you find out _immediately_,
because your editor refuses to save.

NixOS installs `/etc/sudoers` with restrictive permissions, using a **copy** rather than
the usual store symlink. The generated source is still visible through `/etc/static`:

```fish
/etc/sudoers         -r--r----- 1 root root   (a copy)
/etc/static/sudoers  -> /nix/store/h2ksm...-sudoers   (the actual source)
```

`visudo` opened a perfectly ordinary mutable file, validated it, and saved it. Nothing
objected. The edit was real and it worked — until activation recopied the file from
`/etc/static` and my change evaporated.

So the rule isn't "you can't edit `/etc`". It's: **anything NixOS declares gets
regenerated on activation, symlink or copy.** The tell is `/etc/static/`. If
`ls -l /etc/static/<file>` shows something, NixOS owns that file and your edit has a shelf
life.

The declarative version persists across rebuilds:

```nix
security.sudo.wheelNeedsPassword = false;
```

That grants every wheel member passwordless sudo for all commands — including any process
running as that user. It's a deliberate convenience trade-off, not a recommendation for
every machine.

The useful lesson is where the change belongs: in the configuration, not a hand-edited
generated file.

## The invisible pointer

Now the frustrating part. The login screen had no mouse cursor. Not a frozen cursor — _no_
cursor. The pointer was moving and clicking correctly the whole time; it just wasn't
drawn. Log in blind, and Niri appeared with a working pointer.

So: same machine, same kernel, same libinput, cursor in the session, no cursor at the
greeter.

Niri logged five cursor-loading warnings, including:

```fish
WARN niri::cursor: error loading xcursor default@72: no default icon
WARN niri::cursor: error loading xcursor pointer@72: no default icon
WARN niri::cursor: error loading xcursor grabbing@72: no default icon
```

There was no cursor theme installed _at all_. The system had exactly two icon themes,
`hicolor` and `locolor`, and neither contains a `cursors/` directory. Niri still displayed
a small fallback pointer. I suspected missing cursor assets also explained the invisible
greeter pointer, but that diagnosis remained unproven.

This is the part where I was wrong three times in a row, let's get into it. This entire debugging session was assisted by an LLM. I was interacting with the hardware when it could not, since we're debugging a login session on a Wayland display and there was no user session for the Pi harness to run yet.

### Attempt 1: install a cursor theme

```nix
environment.systemPackages = [ pkgs.adwaita-icon-theme ];
systemd.services.display-manager.environment.XCURSOR_PATH =
  "/run/current-system/sw/share/icons";
```

The second half matters: `XCURSOR_PATH` is exported by `/etc/set-environment`, which
applies to _login shells_. A systemd service isn't one. The `display-manager` unit's
environment was `PATH`, `TZDIR`, `LOCALE_ARCHIVE` and nothing else, so the greeter was
falling back to libXcursor's compiled-in search path — which points inside the libxcursor
store path and contains no themes at all.

Warnings went from five to two. Progress! Still no pointer.

### Attempt 2: name the theme

The two surviving warnings were the clue I'd missed:

```txt
error loading xcursor default@72: no default icon
```

Here `default@72` names the cursor icon and requested size, not the theme. Nothing was
setting `XCURSOR_THEME`, and there was also no theme named `default` in the search path. I
tried explicitly selecting Adwaita.

So I set it explicitly, and also built a tiny package providing a theme _named_ `default`
that inherits Adwaita, for anything that asks without being told:

```nix
environment.sessionVariables = {
  XCURSOR_THEME = "Adwaita";
  XCURSOR_SIZE = "24";
};
```

This fixed Niri: zero warnings and a comfortably sized pointer. The configured size was
24; the physical pixel size also depends on display scaling.

The greeter remained stubbornly cursorless.

I also tried `CursorTheme` in SDDM's configuration. It made no visible difference in this
Wayland setup. Searching the package for `XCURSOR` strings found nothing, but that alone
couldn't establish which code paths handled the setting.

### Attempt 3: configure Weston directly

In this configuration, SDDM launches **Weston** to host its Wayland greeter. Weston runs
on the display hardware; it isn't nested inside Niri:

```ini
CompositorCommand=/nix/store/...-weston-15.0.1/bin/weston --shell=kiosk -c .../weston.ini
```

Weston's manual documents `cursor-theme` and `cursor-size` in the `[shell]` section of
`weston.ini`. The NixOS-generated file contained only `[keyboard]` and `[libinput]`, so I
tried adding the documented settings. Whether they would help with SDDM's kiosk-shell
setup was still a hypothesis.

Because this is NixOS, I could reach into the module's own generated config, reproduce it
exactly, and add the missing section:

```nix
services.displayManager.sddm.wayland.compositorCommand =
  let
    westonIni = (pkgs.formats.ini { }).generate "weston.ini" {
      libinput = { /* ... same as upstream ... */ };
      keyboard = { /* ... same as upstream ... */ };
      shell = {
        cursor-theme = "Adwaita";
        cursor-size = 24;
      };
    };
  in
  "${lib.getExe pkgs.weston} --shell=kiosk -c ${westonIni}";
```

I verified the generated ini now had the `[shell]` block and was otherwise byte-identical
to the module's. It built. I was confident.

It didn't work either.

## Knowing when to stop

At this point I'd spent three rounds on a cursor in a program whose only job is to accept
my password. I still hadn't isolated the cause, and I didn't need to solve it to get a
working login screen. Time to try another greeter.

I picked [Noctalia Greeter](https://docs.noctalia.dev/greeter/), a greeter for `greetd`. A
search of its compositor binary gave me a promising clue:

```fish
$ strings .../bin/noctalia-greeter-compositor | grep XCURSOR
XCURSOR_PATH
XCURSOR_SIZE
XCURSOR_THEME
```

All three names were present. That suggested support, not proof that the variables would
reach the right process or fix rendering. The actual test was logging in.

Two wrinkles in the nixpkgs revision I used: the package was available, but the
`services.displayManager.noctalia-greeter` module wasn't, so I wired `greetd` up directly.
I also explicitly supplied the session directory through `XDG_DATA_DIRS`. The generated
entries weren't in the greeter's usual system search path. These are excerpts from the
replacement configuration; I removed the SDDM configuration at the same time:

```nix
services.greetd = {
  enable = true;
  settings.default_session = {
    command = "${pkgs.noctalia-greeter}/bin/noctalia-greeter-session";
    user = "greeter";
  };
};

systemd.services.greetd.environment.XDG_DATA_DIRS =
  "${config.services.displayManager.sessionData.desktops}/share";
```

I got the `[cursor] theme/size/path` key names out of the binary's own help string rather
than guessing, having already learned what guessing costs.

Then I checked the built system before activating anything:

```fish
display-manager.service -> greetd.service   # alias repointed
sddm.conf.d/                                # gone
niri.desktop visible via XDG_DATA_DIRS      # sessions discoverable
```

`nixos-rebuild switch`, log out, and there was a mouse pointer.

## The part that's actually about NixOS

Here's the diff for replacing one display manager and its greeter compositor, and
replacing it with a different login stack:

```diff
 desktop.nix | 123 +++++++++++++-----------------
 1 file changed, 56 insertions(+), 67 deletions(-)
```

One file. No separate package-removal and service-enable steps, and the generated SDDM
configuration disappeared from the new system. Old packages remained available through
previous generations until garbage collection.

And crucially: **if it hadn't worked, I'd have picked the previous generation from the
boot menu.** That safety net is why I was willing to try a fairly invasive change on a
Tuesday evening rather than scheduling it for a weekend.

I've done this swap on a traditional distro. It's an afternoon of careful work, followed
by weeks of low-grade uncertainty about what's still installed and which config file is
winning. Here the old greeter is _absent from the new system configuration_. Mutable user
settings still exist outside that description; generations aren't backups of my home
directory.

The configuration is now a git repo — two commits, one per working state:

```git
ee4e20c Replace sddm/Weston greeter with greetd + Noctalia Greeter
be4bd78 Initial NixOS configuration for ThinkPad P1
```

I keep the working tree in `~/nixos` with symlinks from `/etc/nixos`, so editing and
committing never need `sudo`. `/etc/nixos` isn't NixOS-managed, so the symlinks survive activation. Here's what that directory looks like

```fish
lee@phillip ~/nixos (main)> ls -l /etc/nixos
total 4
lrwxrwxrwx 1 root root 33 Sep 21 08:57 configuration.nix -> /home/lee/nixos/configuration.nix
lrwxrwxrwx 1 root root 27 Sep 21 08:57 desktop.nix -> /home/lee/nixos/desktop.nix
lrwxrwxrwx 1 root root 42 Sep 21 08:57 hardware-configuration.nix -> /home/lee/nixos/hardware-configuration.nix
lrwxrwxrwx 1 root root 86 Sep 22 14:21 result -> /nix/store/0b779w07in6lmifx7wl3iy1gcbpmszm1-nixos-system-nixos-26.05.9989.ecc58f32d106
```

The commit messages record _why_, including the things that didn't work. That's the
documentation I actually want in eighteen months when I've forgotten all of this and I'm
wondering why there's a comment about Weston in a file that no longer mentions Weston.

## What I'd tell you if you're considering this

**Inspect the artifacts, but don't overread them.** Store paths let me examine exactly
which package and generated configuration I was testing. Searching binary strings gave me
clues; it didn't prove behaviour. Three failed attempts were a useful reminder of that
distinction.

**`build` versus `switch` versus `boot` is the whole safety story.** I checked generated
config files in `./result/etc/` repeatedly before letting any of it near the running
system. Several of my wrong guesses were caught there.

**Reverting is cheap, which changes how you work.** The failed cursor fixes cost time, but
left no pile of manual changes to undo. Abandoning the Weston approach meant replacing a
configuration block, not reconstructing the old installation.

**The layer boundaries stay legible.** By the end I could say exactly who owned what:
greetd owns the login session, Noctalia's bundled wlroots compositor draws the greeter,
Niri is the session compositor, Dux Shell is the shell, and the cursor theme is a package
plus two environment variables. Knowing that is most of what I wanted from this exercise.

## Beyond the first boot

Subsequent tests confirmed HDMI hot-plug, suspend/resume with and without an external
display, and lock-before-suspend. One overnight test measured about 714 mW over 20 hours
43 minutes — roughly four days of standby if that rate holds.

That isn't a clean bill of health: lid-triggered suspend still sometimes hangs. My
workaround — F8 to disable Wi-Fi, then the Dux Shell power menu and hold S, then close the
lid after suspend — has resumed successfully every time I've tried it. That's a
workaround, not a fix; Wi-Fi power handling is a suspect, not a diagnosis. The
measurements and unfinished investigation belong in Part 5.

Next: Installing and configuring Voxtype, the dictation tool I have come to depend on.
