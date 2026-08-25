# Keyboard Shortcuts (XFCE <-> KDE)

Portable shortcut definitions shared across machines.

## Files

- `shortcuts.conf` — source of truth. TSV: `kind<TAB>accelerator<TAB>action`
  - kind: `app` (launch a command) or `window` (window-manager action)
  - accelerator: GTK/XFCE syntax, e.g. `<Primary><Alt>t`, `<Super>l`, `<Primary>F1`
  - action: shell command (app) or an XFCE wm action name minus `_key`
    (e.g. `tile_left`, `workspace_1`, `move_window_left`)

## Usage

```sh
# Save current XFCE shortcuts into shortcuts.conf (run on this laptop)
./export.sh

# Apply shortcuts.conf to the current desktop — auto-detects XFCE vs KDE
# via $XDG_CURRENT_DESKTOP and runs the right importer.
./install.sh

# Or as part of a full dotfiles install:
INSTALL.sh --keyboard-shortcuts
```

## KDE notes

- App shortcuts become `.desktop` launchers in `~/.local/share/applications/dotfiles-*`
  registered under `[services]` in `~/.config/kglobalshortcutsrc`.
- Window actions are mapped to their closest KWin equivalents
  (tiling, maximize, workspaces, walk-through-windows). Actions with no KWin
  equivalent are skipped with a warning.
- Log out/in once after install if shortcuts don't take effect immediately.
