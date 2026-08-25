#!/bin/bash
# Shared guards for dotfiles installers. Source this from each INSTALL.sh:
#   . "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
#
# Env:
#   IGNORE_MISSING_DEPS=1  (set by top-level INSTALL.sh --ignore-missing-deps)
#     Missing dependencies no longer abort: affected configs are skipped and
#     installation continues. Without it, a missing dependency is fatal.
#
# Desktop compatibility: XFCE and KDE Plasma are supported. Callers use
# detect_de to skip DE-specific steps that don't apply ("inapplicable
# incompatibilities"); unknown desktops never abort the install.

install_error() { echo -e "\033[31mERROR: $*\033[0m" >&2; }
install_skip()  { echo -e "\033[33mSKIP: $*\033[0m"; }

# require_dep CMD [INSTALL_HINT]
# Returns 0 if CMD is available. If missing: prints error + hint, then exits,
# or returns 1 when IGNORE_MISSING_DEPS=1 (caller must skip dependent configs).
# Always call inside `if require_dep ...; then` so the ignore-path is honored.
require_dep() {
  command -v "$1" >/dev/null 2>&1 && return 0
  install_error "dependency \"$1\" is missing.${2:+
To install: $2}"
  if [ "${IGNORE_MISSING_DEPS:-0}" = "1" ]; then
    install_skip "--ignore-missing-deps set; skipping configs that need \"$1\"."
    return 1
  fi
  exit 1
}

# detect_de -> "xfce" | "kde" | "other"
detect_de() {
  case "${XDG_CURRENT_DESKTOP,,}" in
    *xfce*) echo "xfce" ;;
    *kde*)  echo "kde" ;;
    *)      echo "other" ;;
  esac
}
