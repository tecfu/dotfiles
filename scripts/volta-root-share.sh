#!/bin/bash
# Owner of root's view of the installing user's Volta toolchain:
#   /usr/local/lib/volta/env   (the snippet — written here, sourced by the others)
#   /etc/profile.d/volta.sh    (login shells: `sudo su -`, `sudo -i`, root's tty)
#   /root/.bashrc              (NON-login root shells: `sudo su`, `sudo bash`)
#
# WHY THIS EXISTS HERE AND NOT IN A MACHINE SETUP SCRIPT
# Root needs $VOLTA_HOME to point at the user's ~/.volta (volta shims read that
# env var only — they never derive it from argv[0]), so /usr/local/lib/volta/home
# is a symlink to it: repoint one link to change users, no username in /etc.
# But putting that symlink's bin/ ON PATH adds a SECOND SPELLING of the same
# directory. volta-shim's recursion guard scrubs the literal "$VOLTA_HOME/bin"
# from a child's PATH when _VOLTA_TOOL_RECURSION=1, then execs the first `node`
# still on PATH — the aliased entry survives the scrub, resolves back to
# volta-shim, and forks itself again. ~1,000 stopped `node` processes per second:
# the 2026-10-17 "node hangs" incident (7,500 processes, ~32 GB). PATH order does
# not matter; a single aliased entry is enough. See .terminal/scripts/
# volta-path-doctor.sh, which proves it under a bounded probe.
#
# So: the farm stays as the INDIRECTION POINT, and is resolved with readlink to a
# canonical VOLTA_HOME before anything is exported. The real node binary comes
# onto PATH from tools/image; the canonical shim dir goes on LAST (global shims
# stay reachable, never shadow the binary). The farm path never appears on PATH.
#
# Usage:
#   volta-root-share.sh              # apply (sudo where needed)
#   volta-root-share.sh --check      # exit 1 if the system != what apply writes
#   volta-root-share.sh --dry-run    # print what apply would do
#   --quiet  only findings/errors (for INSTALL.sh and doctor.sh)
#   --volta-home PATH  whose ~/.volta to share (default: $VOLTA_HOME or $HOME/.volta)
#                      — needed when invoked as root, e.g. from a post-install hook
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
. "$ROOT_DIR/lib/common.sh"

MODE=apply
QUIET=0
for arg in "$@"; do
  case "$arg" in
    --check|check)   MODE=check ;;
    --apply|apply)   MODE=apply ;;
    --dry-run|dry-run) MODE=dry-run ;;
    --quiet|-q)   QUIET=1 ;;
    --volta-home) NEEDS_ARG=volta-home ;;
    --help|-h)    sed -n '2,30p' "$0"; exit 0 ;;
    *)
      if [ "${NEEDS_ARG:-}" = "volta-home" ]; then VOLTA_SHARE_HOME="$arg"; NEEDS_ARG=
      else echo "Unknown option: $arg" >&2; exit 2; fi
      ;;
  esac
done

# Paths, overridable so the installer can be exercised against a scratch tree
# instead of a live system (used by scripts/test-volta-root-share.sh).
FARM_DIR="${VOLTA_SHARE_DIR:-/usr/local/lib/volta}"
FARM_HOME="$FARM_DIR/home"
ENV_FILE="$FARM_DIR/env"
PROFILE_SH="${VOLTA_SHARE_PROFILE_SH:-/etc/profile.d/volta.sh}"
PI_WRAPPER="${VOLTA_SHARE_PI:-/usr/local/bin/pi}"
ROOT_BASHRC="${VOLTA_SHARE_ROOT_BASHRC:-/root/.bashrc}"
# v1 wrote this inline in /root/.bashrc; the device-config version used its own
# marker. Both are legacy relative to the block below.
MARKER='volta-root-share/v2'
LEGACY_MARKERS=(
  'VOLTA_HOME=/usr/local/lib/volta/home'
  'expose_to_root/v2 source'
)

say()  { [ "$QUIET" = "1" ] || echo "$@"; }
note() { [ "$QUIET" = "1" ] || echo -e "\033[0;32mOK\033[0m    $*"; }
drift(){ echo -e "\033[33mDRIFT\033[0m  $*"; }
# STALE = correct files, wrong *this* shell (it started before the fix). Not an
# installer failure — re-login or `source ~/.profile` clears it — so it never
# changes the exit code, but doctor.sh surfaces it as a warning.
stale(){ echo -e "\033[33mSTALE\033[0m  $*"; }

# Run a command as root: direct when already root, sudo otherwise. In --check we
# only READ, and everything but /root/.bashrc is world-readable, so a sudo
# failure there downgrades to a warning instead of killing the audit.
SUDO=""
[ "$(id -u)" = "0" ] || SUDO="sudo"
root_read() {   # root_read <file> — contents, or nothing if unreadable w/o creds
  if [ -r "$1" ]; then cat -- "$1"
  elif [ -n "$SUDO" ] && $SUDO cat -- "$1" 2>/dev/null; then :
  else return 1
  fi
}

VOLTA_HOME_SRC="${VOLTA_SHARE_HOME:-${VOLTA_HOME:-$HOME/.volta}}"
# VOLTA_HOME is what root's shells will be told; canonicalize it here so the
# farm spelling can never leak into the snippet we are about to compare/write.
VOLTA_HOME_SRC="$(readlink -f "$VOLTA_HOME_SRC" 2>/dev/null || printf '%s' "$VOLTA_HOME_SRC")"
if [ ! -d "$VOLTA_HOME_SRC" ]; then
  echo "ERROR: no volta home at $VOLTA_HOME_SRC (run dotfiles INSTALL.sh, or set VOLTA_HOME)" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# The snippet. Quoted heredoc: it is DATA, expanded in root's shell, never here.
# ---------------------------------------------------------------------------
env_snippet() {
  # Quoted heredoc + one substitution: the snippet is DATA (expanded in root's
  # shell, never here), but it must name the farm this machine actually uses.
  sed "s|@@FARM_HOME@@|$FARM_HOME|g" <<'SNIPPET'
# >>> volta-root-share/v2 — the user's Volta toolchain, shared with root >>>
# Written by dotfiles/scripts/volta-root-share.sh. Do not edit in place: edit
# that script, then re-run it. /etc/profile.d/volta.sh and /root/.bashrc source
# THIS FILE so there is exactly one copy of this logic on the machine.
#
# VOLTA_HOME is canonicalized from the farm symlink before anything is exported.
# The farm's own bin/ must never reach PATH: it is a second spelling of
# $VOLTA_HOME/bin, and volta-shim's anti-recursion scrub removes only the
# literal "$VOLTA_HOME/bin" — the alias survives, re-resolves to the shim, and
# the shim forks itself forever under _VOLTA_TOOL_RECURSION=1.
if [ -d @@FARM_HOME@@ ]; then
  # Tools must be findable BEFORE VOLTA_HOME is canonicalized: `sudo su` is a
  # non-login shell whose PATH may predate this file (that is the shape that
  # broke), and coreutils lives in /usr/bin, not in the system default of some
  # ssh origins.
  case ":$PATH:" in *":/usr/bin:"*) ;; *) PATH="$PATH:/usr/bin" ;; esac
  _volta_home=$(readlink -f @@FARM_HOME@@ 2>/dev/null) || _volta_home=
  if [ -n "$_volta_home" ]; then
    VOLTA_HOME="$_volta_home"
    export VOLTA_HOME
    # The pinned node binary (real ELF) — resolves before any shim.
    _volta_node=$(ls -1d "$VOLTA_HOME"/tools/image/node/*/bin 2>/dev/null | sort -V | tail -n1)
    if [ -n "$_volta_node" ]; then
      case ":$PATH:" in *":$_volta_node:"*) ;; *) PATH="$_volta_node:$PATH" ;; esac
    fi
    unset _volta_node
    # One shim dir, spelled exactly "$VOLTA_HOME/bin" (so volta's scrub removes
    # it) and LAST (so it never shadows the binary above).
    case ":$PATH:" in *":$VOLTA_HOME/bin:"*) ;; *) PATH="$PATH:$VOLTA_HOME/bin" ;; esac
    # Heal a PATH we did not break: a shell that inherited the farm entry before
    # this file was fixed still carries it, and one alias is enough to loop.
    PATH=$(printf '%s' ":$PATH:" | sed -e 's|:@@FARM_HOME@@/bin|:|g' \
                                   -e 's|:\{2,\}|:|g' -e 's|^:||' -e 's|:$||')
    export PATH
  fi
  unset _volta_home
fi
# <<< volta-root-share/v2 <<<
SNIPPET
}

profile_sh() {
  cat <<EOF
# >>> volta-root-share/v2 — see $ENV_FILE >>>
[ -r $ENV_FILE ] && . $ENV_FILE
# <<< volta-root-share/v2 <<<
EOF
}

# Same one-liner for /root/.bashrc, under its own marker so re-running is a no-op.
# `sudo su` and `sudo bash` are NON-login: they never read /etc/profile.d, which
# is why the snippet had to be duplicated there — and duplicating the BODY is
# exactly how v1 pinned VOLTA_HOME to the farm spelling after profile.d fixed it.
root_bashrc_block() {
  cat <<EOF
# >>> volta-root-share/v2 (root non-login shells) >>>
[ -r $ENV_FILE ] && . $ENV_FILE
# <<< volta-root-share/v2 <<<
EOF
}

# Does /usr/local/bin/pi run pi through a Volta shim? The v1 (device-config)
# version was `export VOLTA_HOME=/usr/local/lib/volta/home; exec
# "$VOLTA_HOME/bin/pi"`. That is dangerous twice over: the shim re-resolves node
# via PATH, and VOLTA_HOME itself is the FARM spelling, so volta's scrub removes
# the wrong entry and the canonical dir survives next to it. The dotfiles wrapper
# execs tools/image/node/…/bin/node directly and carries no shim reference.
pi_wrapper_is_shim_exec() {
  [ -e "$PI_WRAPPER" ] || return 1
  root_read "$PI_WRAPPER" 2>/dev/null | grep -q 'tools/image' && return 1
  root_read "$PI_WRAPPER" 2>/dev/null | grep -qE 'VOLTA_HOME|\.volta|volta/'
}

# ---------------------------------------------------------------------------
# What would change, as a checklist shared by --check and --apply.
# ---------------------------------------------------------------------------
FINDINGS=()
SHELL_FINDINGS=()

audit() {
  FINDINGS=()
  SHELL_FINDINGS=()
  local want got
  want="$(env_snippet)"

  # 1. farm symlink points at a real volta home
  if [ -L "$FARM_HOME" ]; then
    if [ "$(readlink -f "$FARM_HOME" 2>/dev/null)" != "$(readlink -f "$VOLTA_HOME_SRC")" ]; then
      FINDINGS+=("$FARM_HOME -> $(readlink "$FARM_HOME") (want $VOLTA_HOME_SRC)")
    fi
  elif [ -e "$FARM_HOME" ]; then
    FINDINGS+=("$FARM_HOME exists but is not a symlink")
  else
    FINDINGS+=("$FARM_HOME missing")
  fi

  # 2. the snippet is exactly what we generate
  if [ -f "$ENV_FILE" ]; then
    got="$(cat "$ENV_FILE")"
    [ "$got" = "$want" ] || FINDINGS+=("$ENV_FILE differs from this script")
  else
    FINDINGS+=("$ENV_FILE missing")
  fi

  # 3. profile.d is a thin source, not a second copy with the farm on PATH
  if [ -f "$PROFILE_SH" ]; then
    if grep -qF "$FARM_HOME/bin" "$PROFILE_SH" 2>/dev/null || \
       grep -q 'PATH=.*VOLTA_HOME/bin' "$PROFILE_SH" 2>/dev/null; then
      FINDINGS+=("$PROFILE_SH puts a shim dir on PATH directly (must source $ENV_FILE)")
    elif ! grep -q "$MARKER" "$PROFILE_SH" 2>/dev/null; then
      FINDINGS+=("$PROFILE_SH is not the volta-root-share source block")
    fi
  else
    FINDINGS+=("$PROFILE_SH missing")
  fi

  # 4. root's non-login shells reach the snippet, and hold no stale copy of it
  local rbashrc; rbashrc="$(root_read "$ROOT_BASHRC" 2>/dev/null || true)"
  if [ -z "$rbashrc" ]; then
    FINDINGS+=("$ROOT_BASHRC unreadable (needs sudo to audit)")
  else
    if printf '%s\n' "$rbashrc" | grep -q "$MARKER"; then
      :
    else
      FINDINGS+=("$ROOT_BASHRC does not source $ENV_FILE (sudo su skips $PROFILE_SH)")
    fi
    if printf '%s\n' "$rbashrc" | grep -qF 'VOLTA_HOME=/usr/local/lib/volta/home'; then
      FINDINGS+=("$ROOT_BASHRC still exports the farm spelling of VOLTA_HOME")
    fi
  fi

  # 5. the pi wrapper: absent is fine (root falls back to the shared shim dir,
  # which is canonical), a shim-exec wrapper is not — see pi_wrapper_is_shim_exec.
  if [ -e "$PI_WRAPPER" ]; then
    if pi_wrapper_is_shim_exec; then
      FINDINGS+=("$PI_WRAPPER runs pi through Volta shims — re-run INSTALL.sh for the absolute-path wrapper")
    fi
  else
    say "$PI_WRAPPER absent: 'sudo pi' uses the shared shim dir; run INSTALL.sh for the snapshot wrapper"
  fi

  # 6. the live PATH (this shell) must carry no alias of the shim dir
  local canon e resolved
  canon="$(readlink -f "$VOLTA_HOME_SRC/bin" 2>/dev/null || true)"
  local IFS=:
  for e in $PATH; do
    [ -n "$e" ] || continue
    if [ "$e" != "$VOLTA_HOME_SRC/bin" ]; then
      # resolve before comparing: "same string" is not the failure mode, "same
      # directory by a different name" is
      resolved="$(readlink -f "${e%/}" 2>/dev/null || true)"
      if [ -n "$resolved" ] && [ "$resolved" = "$canon" ]; then
        SHELL_FINDINGS+=("PATH carries an aliased shim dir: $e")
      fi
    fi
  done
}

# Remove stale inline copies of the snippet from /root/.bashrc (v1 exported the
# farm spelling directly into the file; device-config v2 appended its own source
# block). Back up once, before the first edit.
strip_legacy_root_bashrc() {
  local m
  for m in "${LEGACY_MARKERS[@]}"; do
    $SUDO grep -qs "$m" "$ROOT_BASHRC" 2>/dev/null || continue
    note "FIX: removing a stale copy of the Volta snippet from $ROOT_BASHRC (\"$m\")"
    $SUDO cp -a "$ROOT_BASHRC" "$ROOT_BASHRC.pre-volta-root-share.bak"
    # Single quotes are required: these are regexes matching LITERAL '$...' text
    # in the file (v1 wrote `export PATH="$VOLTA_HOME/bin:$PATH"`), not expansions.
    # shellcheck disable=SC2016
    $SUDO sed -i \
      -e '/^# volta shims.*installing user/d' \
      -e '/^export VOLTA_HOME=\/usr\/local\/lib\/volta\/home$/d' \
      -e '/^export PATH="\$VOLTA_HOME\/bin:\$PATH"$/d' \
      -e '/^# >>> expose_to_root\/v2 source >>>$/,/^# <<< expose_to_root\/v2 source <<<$/d' \
      "$ROOT_BASHRC" 2>/dev/null || true
  done
}

apply() {
  $SUDO install -d -m 755 "$FARM_DIR"
  if [ "$(readlink "$FARM_HOME" 2>/dev/null || true)" != "$VOLTA_HOME_SRC" ]; then
    $SUDO ln -sfn "$VOLTA_HOME_SRC" "$FARM_HOME"
    note "LINKED $FARM_HOME -> $VOLTA_HOME_SRC"
  fi
  if [ "$(cat "$ENV_FILE" 2>/dev/null || true)" != "$(env_snippet)" ]; then
    env_snippet | $SUDO tee "$ENV_FILE" >/dev/null
    $SUDO chmod 644 "$ENV_FILE"
    note "WROTE  $ENV_FILE"
  fi
  if ! cmp -s <(profile_sh) "$PROFILE_SH" 2>/dev/null; then
    profile_sh | $SUDO tee "$PROFILE_SH" >/dev/null
    $SUDO chmod 644 "$PROFILE_SH"
    note "WROTE  $PROFILE_SH"
  fi
  if [ -n "$SUDO" ]; then
    $SUDO test -r "$ROOT_BASHRC" 2>/dev/null || { echo "WARN: cannot read $ROOT_BASHRC — re-run with sudo" >&2; return 1; }
  fi
  strip_legacy_root_bashrc
  if ! $SUDO grep -qs "$MARKER" "$ROOT_BASHRC" 2>/dev/null; then
    root_bashrc_block | $SUDO tee -a "$ROOT_BASHRC" >/dev/null
    note "LINKED $ROOT_BASHRC sources $ENV_FILE"
  fi
  # A shim-exec pi wrapper is not merely suboptimal: it re-spells VOLTA_HOME as
  # the farm and defeats the guard this file just installed. Remove it (backed up)
  # so root falls back to the canonical shim dir on PATH until INSTALL.sh writes
  # the real wrapper. Never silently overwrite a file this script did not create.
  if pi_wrapper_is_shim_exec; then
    $SUDO cp -a "$PI_WRAPPER" "$PI_WRAPPER.pre-volta-root-share"
    $SUDO rm -f "$PI_WRAPPER"
    note "FIX: removed the shim-exec $PI_WRAPPER (backup: $PI_WRAPPER.pre-volta-root-share) — run INSTALL.sh to install the snapshot wrapper"
  fi
}

case "$MODE" in
  dry-run)
    echo "DRY  would write $ENV_FILE + $PROFILE_SH and hook $ROOT_BASHRC (VOLTA_HOME_SRC=$VOLTA_HOME_SRC)"
    audit
    for f in "${FINDINGS[@]+"${FINDINGS[@]}"}"; do echo "DRY  would fix: $f"; done
    ;;
  check)
    audit
    for f in "${SHELL_FINDINGS[@]+"${SHELL_FINDINGS[@]}"}"; do
      stale "$f (this shell predates the fix: re-login, or source ~/.terminal/.profile)"
    done
    if [ "${#FINDINGS[@]}" = "0" ]; then
      note "volta root share: $ENV_FILE, $PROFILE_SH, $ROOT_BASHRC all match this script"
      exit 0
    fi
    for f in "${FINDINGS[@]}"; do drift "$f"; done
    echo "Fix with: bash $ROOT_DIR/scripts/volta-root-share.sh" >&2
    exit 1
    ;;
  apply)
    audit
    apply
    audit
    for f in "${SHELL_FINDINGS[@]+"${SHELL_FINDINGS[@]}"}"; do
      stale "$f (this shell predates the fix: re-login, or source ~/.terminal/.profile)"
    done
    if [ "${#FINDINGS[@]}" = "0" ]; then
      note "volta root share converged ($ENV_FILE names no aliased shim dir)"
    else
      for f in "${FINDINGS[@]}"; do drift "still: $f"; done
      exit 1
    fi
    ;;
esac
