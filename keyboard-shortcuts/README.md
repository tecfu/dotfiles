# Keyboard Shortcuts (XFCE ↔ KDE)

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

# Apply shortcuts.conf to the current desktop — auto-detects XFCE vs KDE
# via $XDG_CURRENT_DESKTOP and runs the right importer.
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

## Dependencies

| DE   | Tools                                      |
|------|--------------------------------------------|
| XFCE | `xfconf-query` (package `xfconf`)          |
| KDE  | `sxhkd` for app launches; coreutils for KWin edits |
