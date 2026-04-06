#!/usr/bin/env bash
set -euo pipefail

REPO_SOURCE="${1:-$HOME/TornLinux_REPO_READY_BASELINE_1.3.14}"
BUILD_ROOT="${2:-$HOME/tornlinux-build}"
BUILD_NAME="$(basename "$REPO_SOURCE")"
BUILD_TARGET="$BUILD_ROOT/$BUILD_NAME"

echo "========================================"
echo " TornLinux Build Workspace Refresh"
echo "========================================"
echo "Source: $REPO_SOURCE"
echo "Target: $BUILD_TARGET"

if [ ! -d "$REPO_SOURCE" ]; then
  echo "[ERROR] Repo source not found: $REPO_SOURCE"
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "[ERROR] rsync is not installed"
  echo "Install with: sudo apt install -y rsync"
  exit 1
fi

mkdir -p "$BUILD_ROOT"
mkdir -p "$BUILD_TARGET"

echo ""
echo "[1/3] Refreshing disposable build workspace..."
rsync -a --delete \
  --exclude '.git/' \
  --exclude 'node_modules/' \
  --exclude 'dist/' \
  --exclude 'TornLinux-linux-x64/' \
  --exclude '*.iso' \
  --exclude 'live-build/bootstrap/' \
  --exclude 'live-build/chroot/' \
  --exclude 'live-build/binary/' \
  --exclude 'live-build/build/' \
  --exclude 'live-build/cache/' \
  --exclude 'live-build/tmp/' \
  --exclude 'live-build/.build/' \
  "$REPO_SOURCE"/ \
  "$BUILD_TARGET"/

echo ""
echo "[2/3] Resetting ownership in build workspace..."
sudo chown -R "$USER:$USER" "$BUILD_TARGET"

echo ""
echo "[3/3] Ready to build"
echo "Run next:"
echo "  cd $BUILD_TARGET"
echo "  sudo ./scripts/build.sh"
echo "========================================"
