#!/bin/bash
# Top-level dotfiles installer.
# Idempotent where practical: safe to re-run.
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Installs dotfiles: symlinks configs into \$HOME, then runs each component
installer (x11-config, .terminal, .vim). Optionally applies keyboard shortcuts.

Options:
  --ignore-missing-deps  Skip configs whose dependencies are missing instead of aborting
  --keyboard-shortcuts   Also apply keyboard shortcuts (XFCE + KDE only)
  --dry-run              Print actions without changing the system
  --skip-volta           Do not install or update Volta / Node
  --help                 Show this help and exit

Environment:
  DOTFILES_DIR           Override repo location (default: directory of this script)
EOF
}

DRY_RUN=0
IGNORE_MISSING_DEPS=0
KEYBOARD_SHORTCUTS=0
SKIP_VOLTA=0

for ARG in "$@"; do
  case "$ARG" in
    --help|-h) usage; exit 0 ;;
    --ignore-missing-deps) IGNORE_MISSING_DEPS=1 ;;
    --keyboard-shortcuts) KEYBOARD_SHORTCUTS=1 ;;
    --dry-run) DRY_RUN=1 ;;
    --skip-volta) SKIP_VOLTA=1 ;;
    *)
      echo "Unknown option: $ARG" >&2
      usage >&2
      exit 1
      ;;
  esac
done

export IGNORE_MISSING_DEPS
export DRY_RUN

# Resolve repo root (allow override for non-standard clone locations)
__DIR__="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$__DIR__}"

OPENING_MESSAGE="START: $0 (DOTFILES_DIR=$DOTFILES_DIR)"
echo "$OPENING_MESSAGE"
if [ "$DRY_RUN" = "1" ]; then
  echo "DRY-RUN mode: no changes will be made"
fi

# shellcheck source=lib/common.sh
. "$DOTFILES_DIR/lib/common.sh"

# ---------------------------------------------------------------------------
# Preconditions
# ---------------------------------------------------------------------------
require_submodules() {
  local missing=0
  local expected=(x11-config .terminal .vim)
  for path in "${expected[@]}"; do
    if [ ! -e "$DOTFILES_DIR/$path" ] || [ -z "$(ls -A "$DOTFILES_DIR/$path" 2>/dev/null || true)" ]; then
      install_error "submodule missing or empty: $path"
      missing=1
    fi
  done
  if [ "$missing" -ne 0 ]; then
    install_error "Clone with: git clone --recurse-submodules https://github.com/tecfu/dotfiles \"$DOTFILES_DIR\""
    install_error "Or run:   git -C \"$DOTFILES_DIR\" submodule update --init --recursive"
    exit 1
  fi
}

require_submodules

# ---------------------------------------------------------------------------
# Symlinks (source -> target). Uses DOTFILES_DIR; never hard-codes ~/dotfiles.
# ---------------------------------------------------------------------------
declare -A SYMLINKS=(
  ["$DOTFILES_DIR/.ideavimrc"]="$HOME/.ideavimrc"
  ["$DOTFILES_DIR/.terminal"]="$HOME/.terminal"
  ["$DOTFILES_DIR/.vim"]="$HOME/.vim"
)

link_one() {
  local src="$1"
  local dst="$2"

  if [ ! -e "$src" ]; then
    install_skip "source missing, not linking: $src"
    return 0
  fi

  if [ -L "$dst" ]; then
    local current
    current="$(readlink -- "$dst" 2>/dev/null || true)"
    if [ "$current" = "$src" ]; then
      echo "OK   already linked: $dst -> $src"
      return 0
    fi
    echo "INFO replacing existing symlink $dst ($current -> $src)"
    if [ "$DRY_RUN" = "1" ]; then
      echo "DRY  ln -sfn \"$src\" \"$dst\""
      return 0
    fi
    ln -sfn "$src" "$dst"
    return 0
  fi

  if [ -e "$dst" ]; then
    local backup="${dst}.saved"
    echo "INFO backing up existing path: $dst -> $backup"
    if [ "$DRY_RUN" = "1" ]; then
      echo "DRY  mv \"$dst\" \"$backup\""
      echo "DRY  ln -sfn \"$src\" \"$dst\""
      return 0
    fi
    mv "$dst" "$backup"
  fi

  echo "INFO linking $dst -> $src"
  if [ "$DRY_RUN" = "1" ]; then
    echo "DRY  ln -sfn \"$src\" \"$dst\""
    return 0
  fi
  ln -sfn "$src" "$dst"
}

for src in "${!SYMLINKS[@]}"; do
  link_one "$src" "${SYMLINKS[$src]}"
done

# ---------------------------------------------------------------------------
# Volta (optional)
# ---------------------------------------------------------------------------
if [ "$SKIP_VOLTA" = "0" ]; then
  if ! command -v volta >/dev/null 2>&1; then
    if [ "$DRY_RUN" = "1" ]; then
      echo "DRY  would install Volta and node@latest"
    else
      apt_install curl || true
      echo "Installing volta (node version manager)..."
      curl -sSf https://get.volta.sh | bash
      export PATH="${HOME}/.volta/bin:${PATH}"
    fi
  fi
  if command -v volta >/dev/null 2>&1 && [ "$DRY_RUN" = "0" ]; then
    volta install node@latest
  fi
else
  install_skip "Volta/Node (--skip-volta)"
fi

# ---------------------------------------------------------------------------
# Alacritty (tecfu fork)
# https://github.com/tecfu/alacritty — install via cargo, skip if present.
# ---------------------------------------------------------------------------
ALACRITTY_REPO="https://github.com/tecfu/alacritty"
# Check for the fork specifically — a distro alacritty (/usr/bin) must NOT
# satisfy this, or the fork (with the keyboard/copy patches) never installs.
if [ -x "$HOME/.cargo/bin/alacritty" ]; then
  echo "OK   alacritty (tecfu fork) already installed: $HOME/.cargo/bin/alacritty"
elif [ "$DRY_RUN" = "1" ]; then
  echo "DRY  would install alacritty: cargo install --git $ALACRITTY_REPO alacritty"
else
  apt_install cmake g++ pkg-config libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 || true
  if ! command -v cargo >/dev/null 2>&1; then
    apt_install curl || true
    echo "Installing rustup (cargo)..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    export PATH="${HOME}/.cargo/bin:${PATH}"
  fi
  if command -v cargo >/dev/null 2>&1; then
    # Low-RAM devices (fork README: IoT e.g. Radxa 5b) need -j 2 to avoid OOM.
    # Use AVAILABLE memory — total can be large while cache pressure leaves little.
    JOBS=""
    total_mb="$(free -m 2>/dev/null | awk '/^Mem:/{print ($7 != "" && $7 + 0 > 0) ? $7 : $2; exit}')"
    if [ -n "$total_mb" ] && [ "$total_mb" -lt 4000 ]; then
      echo "INFO: low RAM detected (${total_mb}MB), building with -j 2"
      JOBS="-j 2"
    fi
    cargo install --git "$ALACRITTY_REPO" alacritty $JOBS
  else
    install_skip "cargo unavailable; install manually: cargo install --git $ALACRITTY_REPO alacritty"
  fi
fi

# ---------------------------------------------------------------------------
# Component installers
# ---------------------------------------------------------------------------
INSTALL_SCRIPTS=(
  "$DOTFILES_DIR/x11-config/INSTALL.sh"
  "$DOTFILES_DIR/.terminal/INSTALL.sh"
  "$DOTFILES_DIR/.vim/INSTALL.sh"
)

if [ "$KEYBOARD_SHORTCUTS" = "1" ]; then
  INSTALL_SCRIPTS+=("$DOTFILES_DIR/keyboard-shortcuts/install.sh")
fi

FAILED=0
SUCCEEDED=()
SKIPPED=()

for SCRIPT in "${INSTALL_SCRIPTS[@]}"; do
  echo ""
  echo "START SUBSCRIPT: $SCRIPT"

  if [ ! -x "$SCRIPT" ] && [ ! -f "$SCRIPT" ]; then
    install_error "installer not found: $SCRIPT"
    FAILED=1
    continue
  fi

  if [ "$DRY_RUN" = "1" ]; then
    echo "DRY  would run: $SCRIPT"
    SUCCEEDED+=("$SCRIPT")
    continue
  fi

  # Run in a subshell so a child exit does not kill the whole installer
  # unless we choose to abort.
  set +e
  bash "$SCRIPT"
  return_code=$?
  set -e

  if [ "$return_code" -ne 0 ]; then
    echo -e "\033[31mERROR: $SCRIPT (exit $return_code)\033[0m"
    if [ "$IGNORE_MISSING_DEPS" = "1" ]; then
      install_skip "continuing because --ignore-missing-deps is set"
      SKIPPED+=("$SCRIPT")
    else
      FAILED=1
      exit 1
    fi
  else
    echo -e "\033[0;32mSUCCESS: $SCRIPT\033[0m"
    SUCCEEDED+=("$SCRIPT")
  fi
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "======== install summary ========"
echo "Succeeded (${#SUCCEEDED[@]}):"
for s in "${SUCCEEDED[@]:-}"; do echo "  + $s"; done
if [ "${#SKIPPED[@]}" -gt 0 ]; then
  echo "Skipped (${#SKIPPED[@]}):"
  for s in "${SKIPPED[@]}"; do echo "  ~ $s"; done
fi
if [ "$FAILED" -ne 0 ]; then
  echo -e "\033[31mDONE WITH ERRORS: $0\033[0m"
  exit 1
fi
echo -e "\033[0;32mDONE: $0\033[0m"
