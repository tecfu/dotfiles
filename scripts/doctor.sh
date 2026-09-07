#!/bin/bash
# Verify symlinks, tools, and environment for these dotfiles.
# Usage: ./scripts/doctor.sh [--ci]
#   --ci  Treat missing home symlinks as warnings (for GitHub Actions / headless).
set -euo pipefail

CI_MODE=0
for arg in "$@"; do
  case "$arg" in
    --ci) CI_MODE=1 ;;
    --help|-h)
      echo "Usage: $0 [--ci]"
      exit 0
      ;;
  esac
done

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh disable=SC1091
# shellcheck source=../lib/common.sh
. "$ROOT/lib/common.sh"

PASS=0
FAIL=0
WARN=0

ok()   { echo -e "\033[0;32mOK\033[0m    $*"; PASS=$((PASS + 1)); }
bad()  { echo -e "\033[31mFAIL\033[0m  $*"; FAIL=$((FAIL + 1)); }
warn() { echo -e "\033[33mWARN\033[0m  $*"; WARN=$((WARN + 1)); }

echo "======== dotfiles doctor ========"
echo "DOTFILES_DIR=$ROOT"
echo "HOME=$HOME"
echo "DE=$(detect_de)  session=$(detect_session)"
echo "CI_MODE=$CI_MODE"
echo ""

# Symlinks expected by INSTALL.sh
check_link() {
  local dst="$1" expected_src="$2"
  if [ -L "$dst" ]; then
    local actual
    actual="$(readlink -- "$dst" 2>/dev/null || true)"
    if [ "$actual" = "$expected_src" ]; then
      ok "symlink $dst -> $actual"
    else
      bad "symlink $dst points to $actual (expected $expected_src)"
    fi
  elif [ -e "$dst" ]; then
    warn "$dst exists but is not a symlink"
  else
    if [ "$CI_MODE" = "1" ]; then
      warn "missing $dst (expected before install in CI)"
    else
      bad "missing $dst"
    fi
  fi
}

check_link "$HOME/.ideavimrc" "$ROOT/.ideavimrc"
check_link "$HOME/.terminal" "$ROOT/.terminal"
check_link "$HOME/.vim" "$ROOT/.vim"
check_link "$HOME/.inputrc" "$ROOT/.terminal/.inputrc"
check_link "$HOME/.alacritty.toml" "$ROOT/.terminal/.alacritty.toml"

echo ""
echo "---- tools ----"
check_cmd() {
  local name="$1"
  local required="${2:-0}"
  if command -v "$name" >/dev/null 2>&1; then
    ok "$name ($(command -v "$name"))"
  else
    if [ "$required" = "1" ] && [ "$CI_MODE" != "1" ]; then
      bad "$name not found"
    else
      warn "$name not found"
    fi
  fi
}

check_cmd bash 1
check_cmd git 1
check_cmd curl
check_cmd vim
check_cmd nvim
check_cmd xsel
check_cmd sxhkd
check_cmd volta
check_cmd node
check_cmd xfconf-query

echo ""
echo "---- submodules ----"
for path in x11-config .terminal .vim; do
  if [ -d "$ROOT/$path" ] && [ -n "$(ls -A "$ROOT/$path" 2>/dev/null || true)" ]; then
    ok "submodule present: $path"
  else
    bad "submodule missing/empty: $path"
  fi
done

echo ""
echo "======== summary: $PASS ok, $WARN warn, $FAIL fail ========"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
