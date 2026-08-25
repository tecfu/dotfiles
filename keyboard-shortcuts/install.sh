#!/bin/bash
# Apply shortcuts.conf to the current desktop.
# Supports XFCE (xfconf-query) and KDE Plasma (kglobalshortcutsrc).
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="$DIR/shortcuts.conf"

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
    period) key="Period" ;; comma) key="Comma" ;;
  esac
  printf '%s%s' "$mods" "$key"
}

declare -A KWIN_MAP=(
  [tile_left]="Window Quick Tile Left"
  [tile_right]="Window Quick Tile Right"
  [tile_up]="Window Maximize"
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
  touch "$KG"

  # stop kglobalaccel so it doesn't overwrite our edits
  systemctl --user stop plasma-kglobalaccel.service 2>/dev/null || killall kglobalaccel5 kglobalaccel6 2>/dev/null || true

  while IFS=$'\t' read -r kind accel action; do
    case "$kind" in ''|'#'*) continue ;; esac
    local ka; ka="$(kde_accel "$accel")"

    if [ "$kind" = "app" ]; then
      # register command as .desktop launcher + [services] entry
      local slug name file
      slug="$(echo -n "$action" | md5sum | cut -c1-8)"
      name="$(basename "$(echo "$action" | awk '{print $1}')")-$slug"
      file="dotfiles-$name.desktop"
      mkdir -p "$HOME/.local/share/applications"
      cat > "$HOME/.local/share/applications/$file" <<EOF2
[Desktop Entry]
Type=Application
Name=$name
Exec=$action
NoDisplay=true
EOF2
      sed -i "/^\[services\]\[$file\]$/,+2d" "$KG"
      printf '\n[services][%s]\n_launch=%s\n' "$file" "$ka" >> "$KG"
      echo "OK  [app] $ka -> $action"

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
        sed -i "s|^$kwin_id=.*|$kwin_id=$ka|" "$KG"
      else
        printf '\n[kwin]\n' >> "$KG"  # harmless duplicate section header for ini parsers
        printf '%s=%s\n' "$kwin_id" "$ka" >> "$KG"
      fi
      echo "OK  [window] $ka -> $kwin_id"
    fi
  done < "$CONF"

  systemctl --user start plasma-kglobalaccel.service 2>/dev/null || killall -q kglobalaccel5 kglobalaccel6 2>/dev/null || true
  echo "NOTE: log out/in once if any shortcut didn't take effect."
}

case "$DE" in
  xfce)
    require_dep xfconf-query "sudo apt-get install xfconf" || exit 0
    install_xfce ;;
  kde)
    # kglobalshortcutsrc editing only needs coreutils; kglobalaccel restart is best-effort
    install_kde ;;
  *)
    install_skip "desktop '$XDG_CURRENT_DESKTOP' is not XFCE/KDE; no applicable shortcut backend"
    exit 0 ;;
esac
