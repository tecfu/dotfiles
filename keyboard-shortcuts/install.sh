#!/bin/bash
# Apply shortcuts.conf to the current desktop.
# Supports XFCE (xfconf-query) and KDE Plasma (kglobalshortcutsrc).
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

case "$DE" in
  xfce)
    require_dep xfconf-query xfconf || exit 0
    install_xfce ;;
  kde)
    # kglobalshortcutsrc editing only needs coreutils; kglobalaccel restart is best-effort
    install_kde ;;
  *)
    install_skip "desktop '$XDG_CURRENT_DESKTOP' is not XFCE/KDE; no applicable shortcut backend"
    exit 0 ;;
esac
