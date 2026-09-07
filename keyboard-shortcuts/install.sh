#!/bin/bash
# Apply shortcuts.conf to the current desktop.
# Supports XFCE (xfconf-query), KDE Plasma (kglobalshortcutsrc) and GNOME
# (mutter wm keybindings + media-keys custom keybindings).
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="$DIR/shortcuts.conf"

# shellcheck source=../lib/common.sh
. "$DIR/../lib/common.sh"

if [ ! -f "$CONF" ]; then
  echo "ERROR: $CONF missing. Run $DIR/export.sh on your XFCE machine first."
  exit 1
fi

# XFCE and KDE Plasma supported; other desktops: nothing applicable to apply,
# skip instead of failing.
DE="$(detect_de)"

# --- XFCE ----------------------------------------------------------------
install_xfce() {
  local CHANNEL=xfce4-keyboard-shortcuts
  while IFS=$'\t' read -r kind accel action; do
    case "$kind" in ''|'#'*) continue ;; esac
    local path="/commands/custom/$accel"
    [ "$kind" = "window" ] && path="/xfwm4/custom/$accel" && action="${action}_key"
    if xfconf-query -c "$CHANNEL" -p "$path" -n -t string -s "$action" 2>/dev/null; then
      echo "OK  [$kind] $accel -> $action"
    else
      echo "FAIL [$kind] $accel -> $action"
    fi
  done < "$CONF"
}

# GTK accelerator (<Primary><Alt>t) -> sxhkd chord (ctrl + alt + t)
sxhkd_accel() {
  local s="$1" out=""
  while [[ "$s" == '<'*'>'* ]]; do
    local m="${s%%>*}"; m="${m#<}"; s="${s#*>}"
    case "${m,,}" in
      primary|control|ctrl) out+="ctrl + " ;;
      alt)   out+="alt + " ;;
      super) out+="super + " ;;
      shift) out+="shift + " ;;
    esac
  done
  printf '%s%s' "$out" "$s"
}

# GTK accelerator (<Primary><Alt>t) -> KDE (Ctrl+Alt+T)
kde_accel() {
  local s="$1" mods="" key=""
  # split modifiers from key: everything in <> is a modifier
  while [[ "$s" == '<'*'>'* ]]; do
    local m="${s%%>*}"; m="${m#<}"; s="${s#*>}"
    case "${m,,}" in
      primary|control|ctrl) mods+="Ctrl+" ;;
      alt)   mods+="Alt+" ;;
      super) mods+="Meta+" ;;
      shift) mods+="Shift+" ;;
    esac
  done
  key="$s"
  [[ "$key" =~ ^[a-z]$ ]] && key="${key^^}"   # KDE style: Meta+f -> Meta+F
  # normalize keysym names to KDE names
  case "$key" in
    Page_Up) key="PgUp" ;; Page_Down) key="PgDown" ;;
    Delete) key="Del" ;; Escape) key="Esc" ;;
    period) key="." ;; comma) key="," ;;  # this daemon rejects spelled-out names
  esac
  printf '%s%s' "$mods" "$key"
}

declare -A KWIN_MAP=(
  [tile_left]="Window Quick Tile Left"
  [tile_right]="Window Quick Tile Right"
  [tile_up]="Window Maximize"
  [tile_up_left]="Window Quick Tile Top Left"
  [tile_up_right]="Window Quick Tile Top Right"
  [tile_down_left]="Window Quick Tile Bottom Left"
  [tile_down_right]="Window Quick Tile Bottom Right"
  [maximize_window]="Window Maximize"
  [hide_window]="Window Minimize"
  [show_desktop]="Show Desktop"
  [next_workspace]="Switch to Next Desktop"
  [prev_workspace]="Switch to Previous Desktop"
  [cycle_windows]="Walk Through Windows"
  [cycle_reverse_windows]="Walk Through Windows (Reverse)"
  [move_window_next_workspace]="Window to Next Desktop"
  [move_window_prev_workspace]="Window to Previous Desktop"
)

install_kde() {
  local KG="$HOME/.config/kglobalshortcutsrc"
  local SXHKD_ENTRIES=""
  touch "$KG"

  # stop kglobalaccel so it doesn't overwrite our edits
  systemctl --user stop plasma-kglobalaccel.service 2>/dev/null || killall kglobalaccel5 kglobalaccel6 2>/dev/null || true

  while IFS=$'\t' read -r kind accel action; do
    case "$kind" in ''|'#'*) continue ;; esac
    local ka; ka="$(kde_accel "$accel")"

    if [ "$kind" = "app" ]; then
      # app launches go through sxhkd: KGlobalAccel silently drops any
      # [services] entry not registered through its own API, so file-based
      # bindings never stick. sxhkd binds accelerators to commands directly.
      local bin; bin="$(echo "$action" | awk '{print $1}')"
      if ! command -v "$bin" >/dev/null 2>&1 && [ ! -x "$bin" ]; then
        echo "SKIP [app] $accel -> $action ('$bin' not installed)"
        continue
      fi
      SXHKD_ENTRIES+="$(sxhkd_accel "$accel")\n    $action\n\n"
      echo "OK  [app] $(sxhkd_accel "$accel") -> $action (sxhkd)"

    else
      # workspace actions are parameterized: workspace_N / move_window_workspace_N
      local kwin_id=""
      if [[ "$action" =~ ^workspace_([0-9]+)$ ]]; then
        kwin_id="Switch to Desktop ${BASH_REMATCH[1]}"
      elif [[ "$action" =~ ^move_window_workspace_([0-9]+)$ ]]; then
        kwin_id="Window to Desktop ${BASH_REMATCH[1]}"
      elif [ -n "${KWIN_MAP[$action]:-}" ]; then
        kwin_id="${KWIN_MAP[$action]}"
      fi

      if [ -z "$kwin_id" ]; then
        echo "SKIP [window] $accel -> $action (no KWin equivalent)"
        continue
      fi

      # replace existing binding line for this kwin shortcut, or append
      # (KConfig merges duplicate [kwin] group headers, so plain appends work)
      if grep -q "^$kwin_id=" "$KG"; then
        sed -i "s|^$kwin_id=.*|$kwin_id=$ka,$ka,$kwin_id|" "$KG"
      else
        printf '\n[kwin]\n' >> "$KG"  # harmless duplicate section header for ini parsers
        printf '%s=%s,%s,%s\n' "$kwin_id" "$ka" "$ka" "$kwin_id" >> "$KG"
      fi
      echo "OK  [window] $ka -> $kwin_id"
    fi
  done < "$CONF"

  # --- write sxhkd config + autostart, restart daemon -------------------
  # merge into existing rc (x11-config symlinks ~/.config/sxhkd/sxhkdrc into
  # its submodule and owns ctrl+j/ctrl+k browser-key bindings there) — only
  # rewrite our marker-delimited section, never the whole file
  mkdir -p "$HOME/.config/sxhkd" "$HOME/.config/autostart"
  RC="$HOME/.config/sxhkd/sxhkdrc"
  touch "$RC"
  sed -i '/^# BEGIN dotfiles keyboard-shortcuts$/,/^# END dotfiles keyboard-shortcuts$/d' "$RC"
  {
    printf '# BEGIN dotfiles keyboard-shortcuts\n'
    printf '%b' "$SXHKD_ENTRIES"
    printf '# END dotfiles keyboard-shortcuts\n'
  } >> "$RC"
  cat > "$HOME/.config/autostart/sxhkd-dotfiles.desktop" <<EOF2
[Desktop Entry]
Type=Application
Name=dotfiles sxhkd
Exec=$HOME/.local/bin/run-sxhkd.sh
X-GNOME-Autostart-enabled=true
EOF2
  mkdir -p "$HOME/.local/bin"
  cat > "$HOME/.local/bin/run-sxhkd.sh" <<EOF2
#!/bin/bash
pkill -f 'sxhkd -c $HOME/.config/sxhkd/sxhkdrc' 2>/dev/null
exec sxhkd -c $HOME/.config/sxhkd/sxhkdrc
EOF2
  chmod +x "$HOME/.local/bin/run-sxhkd.sh"
  pkill -f 'sxhkd -c .*sxhkdrc' 2>/dev/null || true
  setsid "$HOME/.local/bin/run-sxhkd.sh" >/dev/null 2>&1 < /dev/null &

  # remove stale .desktop launchers from the abandoned [services] approach
  rm -f "$HOME"/.local/share/applications/dotfiles-*.desktop
  kbuildsycoca5 --noincremental >/dev/null 2>&1 || true

  systemctl --user start plasma-kglobalaccel.service 2>/dev/null || killall -q kglobalaccel5 kglobalaccel6 2>/dev/null || true
  echo "NOTE: log out/in once if any shortcut didn't take effect."
}

# --- GNOME ----------------------------------------------------------------
# tiling is enforced by OUR OWN layer: the dotfiles-tile helper (xdotool/
# wmctrl frame geometry, per-monitor, toggle on repeat) is run via media-keys
# custom keybindings. Mutter can't quarter-tile and the Tiling Assistant
# extension brings its own drag-to-edge UX, so neither is used for tiling.
# remaining window actions map to Mutter's own bindings (appended, defaults
# kept); app launches use media-keys custom-keybindings. shortcuts.conf
# accelerators are GTK syntax, which is exactly what gsettings wants.
declare -A GNOME_WM_MAP=(
  [maximize_window]="org.gnome.desktop.wm.keybindings maximize"
  [next_workspace]="org.gnome.desktop.wm.keybindings switch-to-workspace-right"
  [prev_workspace]="org.gnome.desktop.wm.keybindings switch-to-workspace-left"
  [move_window_next_workspace]="org.gnome.desktop.wm.keybindings move-to-workspace-right"
  [move_window_prev_workspace]="org.gnome.desktop.wm.keybindings move-to-workspace-left"
)

# tiling: shortcuts.conf action -> dotfiles-tile region argument
declare -A GNOME_TILE_MAP=(
  [tile_left]=left
  [tile_right]=right
  [tile_up_left]=up-left
  [tile_up_right]=up-right
  [tile_down_left]=down-left
  [tile_down_right]=down-right
)

# install the dotfiles-tile helper into ~/.local/bin (idempotent).
# returns 1 when the environment can't run it (deps missing / Wayland).
install_tile_helper() {
  require_dep wmctrl wmctrl || return 1
  require_dep xdotool xdotool || return 1
  require_dep xrandr x11-xserver-utils || return 1
  require_dep xprop x11-xserver-utils || return 1
  local session; session="$(detect_session)"
  if [ "$session" != "x11" ]; then
    install_skip "dotfiles-tile needs an X11 session (got '$session'); tile bindings skipped"
    return 1
  fi
  local bin="$HOME/.local/bin/dotfiles-tile"
  if [ ! -x "$bin" ] || ! cmp -s "$DIR/dotfiles-tile" "$bin"; then
    mkdir -p "$HOME/.local/bin"
    install -m 755 "$DIR/dotfiles-tile" "$bin"
    echo "OK  installed $bin (tiling layer)"
  fi
}

# append accel to a gsettings keybinding array, preserving existing defaults
gnome_bind() {
  local schema="$1" key="$2" accel="$3" cur base new
  cur="$(gsettings get "$schema" "$key")"
  case "$cur" in
    *"'$accel'"*)
      echo "OK  [window] $accel -> $schema $key (already bound)"; return 0 ;;
  esac
  base="${cur#@as }"; base="${base%]}"   # '@as []' -> '['
  if [ "$base" = "[" ]; then new="['$accel']"; else new="${base}, '$accel']"; fi
  if gsettings set "$schema" "$key" "$new"; then
    echo "OK  [window] $accel -> $schema $key (appended)"
  else
    echo "FAIL [window] $accel -> $schema $key"
  fi
}

# inverse of gnome_bind: remove accel from a gsettings keybinding array,
# preserving every other entry (defaults and user bindings). No-op if the
# accel isn't in the list.
gnome_unbind() {
  local schema="$1" key="$2" accel="$3" cur base item out="" sep="" new
  local -a parts=()
  cur="$(gsettings get "$schema" "$key")"
  case "$cur" in *"'$accel'"*) ;; *) return 0 ;; esac   # not bound
  base="${cur#@as }"; base="${base#[}"; base="${base%]}"
  while IFS= read -r item; do
    item="${item# }"
    [ -z "$item" ] && continue
    [ "$item" = "'$accel'" ] && continue
    parts+=("$item")
  done < <(tr ',' '\n' <<<"$base")
  if [ ${#parts[@]} -eq 0 ]; then
    new="[]"
  else
    for item in "${parts[@]}"; do out+="$sep$item"; sep=", "; done
    new="[$out]"
  fi
  if gsettings set "$schema" "$key" "$new"; then
    echo "OK  removed stale binding $accel from $schema $key"
  fi
}

# undo keybindings the pre-dotfiles-tile installs left behind: accels
# appended to Mutter's toggle-tiled keys and Ubuntu's Tiling Assistant
# extension — both would fire alongside dotfiles-tile on the same keypress
cleanup_old_tiling() {
  local -a stale=(
    "org.gnome.mutter.keybindings toggle-tiled-left"
    "org.gnome.mutter.keybindings toggle-tiled-right"
  )
  if gsettings list-schemas | grep -q '^org.gnome.shell.extensions.tiling-assistant$'; then
    stale+=(
      "org.gnome.shell.extensions.tiling-assistant tile-topleft-quarter"
      "org.gnome.shell.extensions.tiling-assistant tile-topright-quarter"
      "org.gnome.shell.extensions.tiling-assistant tile-bottomleft-quarter"
      "org.gnome.shell.extensions.tiling-assistant tile-bottomright-quarter"
    )
  fi
  local kind accel action k
  while IFS=$'\t' read -r kind accel action; do
    case "$kind" in ''|'#'*) continue ;; esac
    accel="${accel//<Primary>/<Control>}"
    case "$action" in
      tile_left|tile_right|tile_up_left|tile_up_right|tile_down_left|tile_down_right)
        for k in "${stale[@]}"; do
          # shellcheck disable=SC2086  # "schema key" pair splits into two args
          gnome_unbind $k "$accel"
        done ;;
    esac
  done < "$CONF"

  # the old installer enabled the Tiling Assistant extension; we no longer
  # use it — switch it back off (re-enable via the Extensions app if you
  # want its drag-to-edge UX back)
  local UUID=tiling-assistant@ubuntu.com cur
  cur="$(gsettings get org.gnome.shell enabled-extensions)"
  case "$cur" in *"'$UUID'"*) ;; *) return 0 ;; esac
  gnome-extensions disable "$UUID" 2>/dev/null || true
  gnome_unbind org.gnome.shell enabled-extensions "$UUID"
  echo "OK  disabled Tiling Assistant extension (dotfiles-tile replaces it)"
}

install_gnome() {
  if ! command -v gsettings >/dev/null 2>&1; then
    install_skip "gsettings not found; not a GNOME session"
    return 0
  fi

  cleanup_old_tiling

  local SCHEMA=org.gnome.settings-daemon.plugins.media-keys
  local SLOT=$SCHEMA.custom-keybinding
  local BASE=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/
  local -a paths=()
  local raw; raw="$(gsettings get $SCHEMA custom-keybindings)"
  read -ra paths <<<"$(sed "s/^@as //; s/[]['\"()]//g" <<<"$raw" | tr ',' ' ')"

  while IFS=$'\t' read -r kind accel action; do
    case "$kind" in ''|'#'*) continue ;; esac
    accel="${accel//<Primary>/<Control>}"   # gsettings spells it Control

    # decide what command this binding runs (media-keys custom keybindings
    # are shared by app launches and our tiling layer)
    local cmd="" label="$kind"
    if [ "$kind" = "app" ]; then
      cmd="$action"
      local bin="${cmd%% *}"
      if ! command -v "$bin" >/dev/null 2>&1 && [ ! -x "$bin" ]; then
        echo "SKIP [app] $accel -> $action ('$bin' not installed)"
        continue
      fi
    elif [ -n "${GNOME_TILE_MAP[$action]:-}" ]; then
      if install_tile_helper; then
        cmd="$HOME/.local/bin/dotfiles-tile ${GNOME_TILE_MAP[$action]}"
        label="tile"
      else
        continue
      fi
    elif [ -n "${GNOME_WM_MAP[$action]:-}" ]; then
      # shellcheck disable=SC2086
      gnome_bind ${GNOME_WM_MAP[$action]} "$accel"
      continue
    else
      echo "SKIP [window] $accel -> $action (no GNOME equivalent)"
      continue
    fi

    # Ubuntu's gnome-terminal owns Ctrl+Alt+T via the built-in `terminal`
    # key — and that value IS the schema default on Ubuntu, so `reset`
    # wouldn't release it. Set an explicit empty override instead.
    local term; term="$(gsettings get $SCHEMA terminal)"
    case "${term//<Primary>/<Control>}" in
      *"'$accel'"*)
        gsettings set $SCHEMA terminal "[]"
        echo "OK  [$label] released built-in terminal binding $accel" ;;
    esac

    # reuse an existing slot bound to this accel, else allocate the next
    # free customN (gap-safe)
    local path="" p n=0
    for p in "${paths[@]}"; do
      if [ "$(gsettings get "$SLOT:$p" binding 2>/dev/null)" = "'$accel'" ]; then
        path="$p"; break
      fi
    done
    if [ -z "$path" ]; then
      while printf '%s' "${paths[*]}" | grep -q "custom$n/"; do n=$((n+1)); done
      path="${BASE}custom$n/"
      paths+=("$path")
    fi
    gsettings set "$SLOT:$path" name "dotfiles: $action"
    gsettings set "$SLOT:$path" command "$cmd"
    gsettings set "$SLOT:$path" binding "$accel"
    echo "OK  [$label] $accel -> $cmd"
  done < "$CONF"

  # write back the slot list
  if [ ${#paths[@]} -eq 0 ]; then
    gsettings set $SCHEMA custom-keybindings "@as []"
  else
    local list=""
    for p in "${paths[@]}"; do list+="'$p', "; done
    gsettings set $SCHEMA custom-keybindings "[${list%, }]"
  fi

  echo "NOTE: GNOME applies these live; log out/in only if one didn't take effect."
}

case "$DE" in
  xfce)
    require_dep xfconf-query xfconf || exit 0
    install_xfce ;;
  kde)
    # kglobalshortcutsrc editing only needs coreutils; kglobalaccel restart is best-effort
    install_kde ;;
  gnome)
    install_gnome ;;
  *)
    install_skip "desktop '$XDG_CURRENT_DESKTOP' is not XFCE/KDE/GNOME; no applicable shortcut backend"
    exit 0 ;;
esac
