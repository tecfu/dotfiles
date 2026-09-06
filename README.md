# Dotfiles

Personal Ubuntu / Xubuntu development environment configs (bash vi-mode, Vim/Neovim, X11 key remaps, XFCE/KDE shortcuts).

## Prerequisites

- Git with submodule support
- Ubuntu/Debian recommended (installer uses `apt` when available)
- For full desktop features: XFCE or KDE Plasma (X11 preferred for x11-config)
- Optional: `curl`, `sudo` for package auto-install

## Installation

```sh
git clone --recurse-submodules https://github.com/tecfu/dotfiles ~/dotfiles
~/dotfiles/INSTALL.sh
```

You can clone anywhere; the installer uses its own directory (or `DOTFILES_DIR`) instead of hard-coding `~/dotfiles`.

### Installer flags

| Flag | Purpose |
|------|---------|
| `--help` | Show usage |
| `--dry-run` | Print actions without changing the system |
| `--ignore-missing-deps` | Skip components whose dependencies are missing |
| `--keyboard-shortcuts` | Apply portable XFCE/KDE shortcuts from `keyboard-shortcuts/` |
| `--skip-volta` | Do not install/update Volta or Node |

Examples:

```sh
./INSTALL.sh --dry-run
./INSTALL.sh --ignore-missing-deps --keyboard-shortcuts
DOTFILES_DIR=/opt/dotfiles ./INSTALL.sh --skip-volta
```

### After install checklist

1. Log out and back in (or reboot) so group/udev changes and desktop shortcuts take effect.
2. Confirm Caps Lock → Esc (BIOS, `/etc/default/keyboard`, or x11-config / custom.kmap).
3. Run `./scripts/doctor.sh` to verify symlinks and tools.
4. Open a new terminal and check vi-mode (`set -o | grep vi`) and editor plugins.

## Updating

Preferred (records current submodule SHAs in the parent commit):

```sh
./scripts/update-submodules.sh
git add -A && git commit -m "chore: update submodules"
git push
```

Manual equivalent:

```sh
git submodule update --init --recursive
git submodule update --remote --recursive
git pull --recurse-submodules
```

Pin policy: the parent repo records exact submodule commits. Prefer committing after `--remote` updates rather than always floating on branch tips in production machines.

## Contents

| Component | Path / submodule | Notes |
|-----------|------------------|--------|
| Terminal (bash, Alacritty, Kitty, tmux, …) | [`.terminal`](https://github.com/tecfu/.terminal) | vi-mode, oh-my-bash, fonts |
| Vim / Neovim | [`.vim`](https://github.com/tecfu/.vim) | Cross-platform; some tweaks may be needed on macOS/Windows |
| X11 key remaps | [`x11-config`](https://github.com/tecfu/x11-config) | Browser C-j/C-k, Caps→Esc via xremap/sxhkd |
| Keyboard shortcuts | `keyboard-shortcuts/` | Portable TSV; XFCE + KDE + GNOME (sxhkd for app launches on KDE) |
| XFCE panel/themes | [`.xfce`](https://github.com/tecfu/.xfce) | Optional; not auto-run by INSTALL.sh |
| IdeaVim | `.ideavimrc` | Symlinked into `$HOME` |
| Surfingkeys (archived) | [`.surfingkeys`](https://github.com/tecfu/.surfingkeys) | Abandoned in favor of Vimium; kept for reference |

### Terminal

Sets bash to vi editing mode. Background reading:

- [Working Productively in Bash's Vi Command Line Editing Mode](http://www.catonmat.net/blog/bash-vi-editing-mode-cheat-sheet)
- [Vi mode in Bash](https://sanctum.geek.nz/arabesque/vi-mode-in-bash)

### X11 config

Remaps keys that browsers do not expose (e.g. `<C-j>`, `<C-k>`). See the submodule README for xremap vs xmodmap vs sxhkd.

### Keyboard shortcuts (XFCE ↔ KDE)

Source of truth: `keyboard-shortcuts/shortcuts.conf` (TSV).

```sh
# Capture current XFCE bindings
./keyboard-shortcuts/export.sh

# Apply to current DE (auto-detects XFCE vs KDE)
./keyboard-shortcuts/install.sh
# or: ./INSTALL.sh --keyboard-shortcuts
```

**KDE notes:** App shortcuts are bound via **sxhkd** (KGlobalAccel ignores file-only `[services]` entries). Window actions map to the closest KWin equivalents. Install `sxhkd` for app launches. Log out/in if bindings do not appear immediately.

Machine-specific app paths (e.g. Code, terminal emulator) live in `shortcuts.conf`; edit that file or maintain a private overlay before applying on a new host.

### CAPS LOCK → ESC (no BIOS, e.g. Radxa ROCK 5B)

```sh
sudo sed -i 's/^XKBOPTIONS=.*/XKBOPTIONS="caps:escape"/' /etc/default/keyboard
```

Log out/in. For virtual consoles, use `.terminal/custom.kmap` with `loadkeys`.

## Doctor / verification

```sh
./scripts/doctor.sh
```

Checks symlinks, session/DE detection, and common tools (xsel, sxhkd, volta, vim/nvim, …).

## Archived / historical

- **Vimperator** — project is dead; config was removed from active install paths. Prefer Vimium.
- **Surfingkeys** — abandoned here due to tab-switch performance and PDF reader limitations; prefer Vimium. Submodule retained as a historical reference only.

## License

**The MIT License (MIT)**

**Copyright (c) 2010 - 2025 Tecfu**

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
