#!/bin/bash

set -euo pipefail

echo "========================================"
echo " TornLinux Stable Build Script"
echo "========================================"

# Must be run from repo root
if [ ! -d "live-build" ] || [ ! -d "scripts" ] || [ ! -f "package.json" ]; then
  echo "[ERROR] Must run from repo root"
  exit 1
fi

# Dependency/tool sanity checks
for cmd in npm node sudo lb; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[ERROR] Required command not found: $cmd"
    exit 1
  fi
done

echo ""
echo "[0/10] Ensuring script permissions..."
chmod +x scripts/*.sh
chmod +x live-build/config/hooks/live/* 2>/dev/null || true
chmod +x live-build/config/includes.chroot/usr/local/bin/* 2>/dev/null || true

echo ""
echo "[1/10] Ensuring node dependencies..."
if [ ! -d "node_modules" ]; then
  npm install --legacy-peer-deps
else
  echo "node_modules already present"
fi

echo ""
echo "[2/10] Packaging Linux app..."
npm run package:linux

echo ""
echo "[3/10] Preparing live-build payload..."
./scripts/prepare-live-build.sh

echo ""
echo "[4/10] Running preflight checks..."
./scripts/preflight-check.sh

echo ""
echo "[5/10] Cleaning previous live-build artifacts..."
cd live-build
sudo lb clean --purge
sudo rm -rf cache chroot binary build tmp .build
sudo rm -f ./*.iso
cd ..

echo ""
echo "[6/10] Configuring live-build..."
./scripts/configure-live-build.sh

echo ""
echo "[7/10] Building ISO..."
./scripts/build-iso.sh

echo ""
echo "[8/10] Running post-build validation..."
./scripts/post-build-validate.sh

echo ""
echo "[9/10] Locating ISO..."
ISO=$(find live-build -maxdepth 1 -type f -name "*.iso" | head -n 1 || true)

if [ -n "${ISO}" ] && [ -f "$ISO" ]; then
  echo "[SUCCESS] ISO created:"
  ls -lh "$ISO"
else
  echo "[WARNING] No ISO found"
fi

echo ""
echo "[10/10] Stable build flow complete"
echo "========================================"
echo " Done"
echo "========================================"
