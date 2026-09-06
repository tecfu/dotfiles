#!/bin/bash
# Update submodules to latest remote commits and print new SHAs.
# Commit the parent repo afterward to pin the versions.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "Initializing any missing submodules..."
git submodule update --init --recursive

echo "Fetching remote updates..."
git submodule update --remote --recursive

echo ""
echo "Current submodule SHAs (commit these in the parent repo to pin):"
git submodule status

echo ""
echo "Next steps:"
echo "  git add -A"
echo "  git commit -m \"chore: update submodules\""
echo "  git push"
