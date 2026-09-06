#!/bin/bash
# Shared guards for dotfiles installers. Source this from each INSTALL.sh:
#   . "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
#
# Env:
#   IGNORE_MISSING_DEPS=1  (set by top-level INSTALL.sh --ignore-missing-deps)
#     Missing dependencies no longer abort: affected configs are skipped and
#     installation continues. Without it, a missing dependency is fatal.
#
# Desktop compatibility: XFCE, KDE Plasma and GNOME are supported. Callers use
# detect_de to skip DE-specific steps that don't apply ("inapplicable
# incompatibilities"); unknown desktops never abort the install.

install_error() { echo -e "\033[31mERROR: $*\033[0m" >&2; }
install_skip()  { echo -e "\033[33mSKIP: $*\033[0m"; }

# apt_install PKG... — best-effort apt install (Ubuntu/Debian).
# Returns 1 without installing if apt-get is unavailable (e.g. macOS).
apt_install() {
  if ! command -v apt-get >/dev/null 2>&1; then
    install_skip "apt-get not found; install manually: apt install $*"
    return 1
  fi
  echo "INFO: sudo apt-get install -y $*"
  sudo apt-get install -y "$@"
}

# require_dep CMD [APT_PKG]
# Returns 0 if CMD is available. If missing and APT_PKG is set, auto-installs
# it via apt_install, then re-checks. Still missing: prints error, then exits,
# or returns 1 when IGNORE_MISSING_DEPS=1 (caller must skip dependent configs).
# Always call inside `if require_dep ...; then` so the ignore-path is honored.
require_dep() {
  if ! command -v "$1" >/dev/null 2>&1 && [ -n "$2" ]; then
    apt_install "$2"
  fi
  command -v "$1" >/dev/null 2>&1 && return 0
  install_error "dependency \"$1\" is missing.${2:+
To install: apt install $2}"
  if [ "${IGNORE_MISSING_DEPS:-0}" = "1" ]; then
    install_skip "--ignore-missing-deps set; skipping configs that need \"$1\"."
    return 1
  fi
  exit 1
}

# detect_de -> "xfce" | "kde" | "gnome" | "other"
detect_de() {
  case "${XDG_CURRENT_DESKTOP,,}" in
    *xfce*)  echo "xfce" ;;
    *kde*)   echo "kde" ;;
    *gnome*) echo "gnome" ;;
    *)       echo "other" ;;
  esac
}

# detect_session -> "x11" | "wayland" | "unknown"
# Uses the live session type; falls back to display-server env vars.
detect_session() {
  if [ -n "$XDG_SESSION_TYPE" ]; then
    echo "$XDG_SESSION_TYPE"
  elif [ -n "$WAYLAND_DISPLAY" ]; then
    echo "wayland"
  elif [ -n "$DISPLAY" ]; then
    echo "x11"
  else
    echo "unknown"
  fi
}
