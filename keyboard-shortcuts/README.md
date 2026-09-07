# Keyboard Shortcuts (XFCE ↔ KDE ↔ GNOME)

Portable shortcut definitions shared across machines.

## Files

* `shortcuts.conf` — source of truth. TSV: `kind<TAB>accelerator<TAB>action`
  * `kind`: `app` (launch a command) or `window` (window-manager action)
  * `accelerator`: GTK/XFCE syntax, e.g. `<Primary><Alt>t`, `<Super>l`, `<Primary>F1`
  * `action`: shell command (`app`) or an XFCE wm action name minus `_key` (e.g. `tile_left`, `workspace_1`, `move_window_left`)

Edit `shortcuts.conf` (or maintain a private copy) for machine-specific paths such as the Code binary or preferred terminal.

## Usage

```sh
# Save current XFCE shortcuts into shortcuts.conf (run on an XFCE machine)
./export.sh

# Apply shortcuts.conf to the current desktop — auto-detects XFCE vs KDE vs
# GNOME via $XDG_CURRENT_DESKTOP and runs the right importer.
./install.sh

# Or as part of a full dotfiles install:
../INSTALL.sh --keyboard-shortcuts
```

## KDE notes

* **App shortcuts** are bound through **sxhkd**, not KGlobalAccel `[services]`.
  KGlobalAccel silently drops file-based service entries that were not registered
  through its API, so the installer writes a marked section into
  `~/.config/sxhkd/sxhkdrc` and an autostart entry.
  **Install `sxhkd`** (`apt install sxhkd`) for app launches to work.
* Window actions map to the closest KWin equivalents (tiling, maximize,
  workspaces, walk-through-windows). Actions with no KWin equivalent are
  skipped with a warning.
* Log out/in once after install if shortcuts do not take effect immediately.

## GNOME notes

* **Tiling** (halves + corners) is enforced by **our own layer**: the
  installer drops `dotfiles-tile` into `~/.local/bin` and binds each
  `tile_*` action to it via media-keys custom keybindings (same mechanism as
  app launches). The script moves the focused window into that region of the
  monitor it currently occupies (frame geometry via xdotool/wmctrl, dock-aware
  via the WM workarea); pressing the same key again restores the previous
  geometry. **X11 only** — on Wayland the tile bindings are skipped
  (xdotool/wmctrl can't move Wayland windows). Mutter half-tiling and the
  Tiling Assistant extension are intentionally not used — the installer
  also **removes the bindings the old Mutter/Tiling-Assistant setup left
  behind** (our accels are stripped from Mutter's `toggle-tiled-*` and TA's
  quarter keys, and the extension is disabled again) so nothing fires twice.
  Other bindings and extensions are preserved.
  Sanity check without a WM: `~/.local/bin/dotfiles-tile --selftest`.
* **Other window actions** (maximize, workspaces) map to Mutter's own
  bindings (`org.gnome.desktop.wm.keybindings`). Bindings are appended —
  existing defaults (e.g. `Super+Left`) are kept, and re-running never
  duplicates.
* **App shortcuts** use media-keys custom keybindings (`gsettings`); no sxhkd.
  A built-in `terminal` binding claiming the same accelerator (Ubuntu binds
  Ctrl+Alt+T to gnome-terminal) is released so the custom binding works.
* Bindings apply live via dconf; log out/in only if one didn't take.

## Dependencies

| DE   | Tools                                      |
|------|--------------------------------------------|
| XFCE | `xfconf-query` (package `xfconf`)          |
| KDE  | `sxhkd` for app launches; coreutils for KWin edits |
| GNOME | `gsettings` (always present); `wmctrl`, `xdotool`, `x11-xserver-utils` for the tiling layer (X11 only) |
