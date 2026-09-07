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
  --keyboard-shortcuts   Also apply keyboard shortcuts (XFCE + KDE + GNOME)
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
# pi coding agent (@earendil-works/pi-coding-agent)
# Installs pi into the user's Volta toolchain. Also installs snapshot wrappers
# in /usr/local/bin (pi, vim, nvim): when run via sudo they first copy the
# INVOKING user's config (if it exists, e.g. /home/base/.pi) into root's home,
# then run the root-owned binary. Root reads the user's config but writes ONLY
# root-owned files under /root — the user's config can never be polluted or
# locked out. Root-side changes survive until the user's copy of the same
# file changes (rsync merge, no --delete).
# 'sudo pi update ...' is re-executed as the invoking user instead: pi's
# package dir is $HOME/.pi/agent, so updating as root would only touch the
# /root/.pi snapshot (or write root-owned files into the user's home/volta).
# Invoke as 'sudo pi' — never 'sudo -E pi' (leaks HOME and env between users).
# ---------------------------------------------------------------------------
PI_PKG="@earendil-works/pi-coding-agent"
if [ "$DRY_RUN" = "1" ]; then
  echo "DRY  would install pi (volta install $PI_PKG) + snapshot wrappers in /usr/local/bin (pi, vim, nvim)"
elif command -v volta >/dev/null 2>&1; then
  volta install "$PI_PKG"
  apt_install rsync || true
  PI_BUNDLE="$HOME/.volta/tools/image/packages/$PI_PKG/lib/node_modules/$PI_PKG/dist/bundle/cli.js"
  if [ -f "$PI_BUNDLE" ]; then
    cat >"/tmp/pi-root-wrapper" <<'WRAPPER'
#!/usr/bin/env bash
# Generated by dotfiles INSTALL.sh. Runs __USER__'s Volta-managed pi via
# absolute paths (no Volta shim -> no shim recursion). Via sudo: snapshot the
# invoking user's ~/.pi into /root/.pi first (rsync merge, no --delete), then
# run root's own pi. Root reads the user's config but writes ONLY root-owned
# files under /root — the user's config is never written by root, so it can
# never be polluted or locked out. Root-side changes survive until the user's
# copy of the same file changes.
# 'sudo pi update ...' is re-executed as the invoking user instead: pi's
# package dir is $HOME/.pi/agent, so updating as root would only touch the
# /root/.pi snapshot (or write root-owned files into the user's home/volta).
VH="__VOLTA_HOME__"
PI_BUNDLE="$VH/tools/image/packages/@earendil-works/pi-coding-agent/lib/node_modules/@earendil-works/pi-coding-agent/dist/bundle/cli.js"
NODE="$(ls -1d "$VH"/tools/image/node/*/bin/node 2>/dev/null | sort -V | tail -n1)"
[ -f "$PI_BUNDLE" ] && [ -x "$NODE" ] || { echo "pi not installed for '__USER__'; run dotfiles INSTALL.sh as __USER__" >&2; exit 127; }
# Spawned tools (npm, git) must resolve: prepend the real node/npm bin dir
# (not Volta shims — those resolve against the invoking user's VOLTA_HOME).
export PATH="$(dirname "$NODE"):$PATH"
# Git must never hang the TUI on an unattended prompt: BatchMode fails fast
# instead of asking; accept-new trusts first-contact keys (TOFU) but still
# rejects keys that CHANGED. Seed /root/.ssh/known_hosts for git: sources.
export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND="ssh -oBatchMode=yes -oStrictHostKeyChecking=accept-new"
# 'update' edits $HOME/.pi/agent — run it as the invoking user (their npm,
# their SSH keys for git: sources), never as root.
if [ "$(id -u)" = "0" ] && [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ] && [ "${1:-}" = "update" ]; then
  UHOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
  exec runuser -u "$SUDO_USER" -- env "PATH=$(dirname "$NODE"):$PATH" "$NODE" "$PI_BUNDLE" "$@"
fi
if [ "$(id -u)" = "0" ] && [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
  UHOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
  if [ -d "$UHOME/.pi/" ]; then
    if command -v rsync >/dev/null 2>&1; then
      rsync -a --no-o --no-g "$UHOME/.pi/" /root/.pi/ 2>/dev/null
    else
      mkdir -p /root/.pi && cp -a "$UHOME/.pi/." /root/.pi/ 2>/dev/null
    fi
  fi
fi
exec "$NODE" "$PI_BUNDLE" "$@"
WRAPPER
    sed -i "s|__VOLTA_HOME__|$HOME/.volta|g; s|__USER__|$USER|g" /tmp/pi-root-wrapper
    sudo install -m 0755 /tmp/pi-root-wrapper /usr/local/bin/pi
    echo "OK   pi installed (volta) + snapshot wrapper /usr/local/bin/pi"
  else
    install_skip "pi wrapper (bundle not found after volta install)"
  fi
  # vim: same sudo behavior (only for the distro binary; avoids clobbering e.g. brew on mac)
  if [ "$(command -v vim 2>/dev/null)" = "/usr/bin/vim" ]; then
    cat >"/tmp/vim-sudo-wrapper" <<'WRAPPER'
#!/usr/bin/env bash
# Generated by dotfiles INSTALL.sh. Via sudo: snapshot the invoking user's
# vim config (~/.vimrc + ~/.vim) into root's home first, then run root's own
# vim. Root writes ONLY root-owned files under /root — the user's config is
# never written by root, so it can never be polluted or locked out.
UHOME=""
if [ "$(id -u)" = "0" ] && [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
  UHOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
fi
if [ -n "$UHOME" ] && { [ -e "$UHOME/.vimrc" ] || [ -d "$UHOME/.vim/" ]; }; then
  [ -e "$UHOME/.vimrc" ] && cp -f "$UHOME/.vimrc" /root/.vimrc
  if [ -d "$UHOME/.vim/" ]; then
    if command -v rsync >/dev/null 2>&1; then
      rsync -a --no-o --no-g "$UHOME/.vim/" /root/.vim/ 2>/dev/null
    else
      mkdir -p /root/.vim && cp -a "$UHOME/.vim/." /root/.vim/ 2>/dev/null
    fi
  fi
fi
exec /usr/bin/vim "$@"
WRAPPER
    sudo install -m 0755 /tmp/vim-sudo-wrapper /usr/local/bin/vim
    echo "OK   snapshot wrapper /usr/local/bin/vim"
  fi
  # nvim: same sudo behavior, only when the distro nvim is installed
  if [ "$(command -v nvim 2>/dev/null)" = "/usr/bin/nvim" ]; then
    cat >"/tmp/nvim-sudo-wrapper" <<'WRAPPER'
#!/usr/bin/env bash
# Generated by dotfiles INSTALL.sh. Via sudo: snapshot the invoking user's
# nvim config (~/.config/nvim) into root's home first, then run root's own
# nvim. Root writes ONLY root-owned files under /root — the user's config is
# never written by root, so it can never be polluted or locked out.
UHOME=""
if [ "$(id -u)" = "0" ] && [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
  UHOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
fi
if [ -n "$UHOME" ] && [ -d "$UHOME/.config/nvim/" ]; then
  if command -v rsync >/dev/null 2>&1; then
    mkdir -p /root/.config && rsync -a --no-o --no-g "$UHOME/.config/nvim/" /root/.config/nvim/ 2>/dev/null
  else
    mkdir -p /root/.config/nvim && cp -a "$UHOME/.config/nvim/." /root/.config/nvim/ 2>/dev/null
  fi
fi
exec /usr/bin/nvim "$@"
WRAPPER
    sudo install -m 0755 /tmp/nvim-sudo-wrapper /usr/local/bin/nvim
    echo "OK   snapshot wrapper /usr/local/bin/nvim"
  fi
else
  install_skip "pi (volta unavailable)"
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
