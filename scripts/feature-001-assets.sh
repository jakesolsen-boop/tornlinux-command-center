#!/usr/bin/env bash
set -euo pipefail

echo "========================================"
echo " TornLinux Feature 001"
echo " Clean Visual Assets (Repo-Internal)"
echo "========================================"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

CURRENT_VERSION="$(tr -d '[:space:]' < "$PROJECT_ROOT/VERSION")"

# Preferred 1.5.1/1.5.0-derived clean asset locations already in repo
SPLASH_CANDIDATES=(
  "$PROJECT_ROOT/assets/master/splash.png"
  "$PROJECT_ROOT/assets/master/tornlinux-splash.png"
)

WALLPAPER_CANDIDATES=(
  "$PROJECT_ROOT/assets/master/wallpaper.png"
  "$PROJECT_ROOT/assets/master/tornlinux-wallpaper-final.png"
)

pick_first_existing() {
  local chosen=""
  for path in "$@"; do
    if [ -f "$path" ]; then
      chosen="$path"
      break
    fi
  done
  if [ -z "$chosen" ]; then
    return 1
  fi
  printf '%s\n' "$chosen"
}

SPLASH_SOURCE="$(pick_first_existing "${SPLASH_CANDIDATES[@]}")" || {
  echo "[ERROR] Could not find repo-contained clean splash asset."
  echo "Searched:"
  printf '  - %s\n' "${SPLASH_CANDIDATES[@]}"
  exit 1
}

WALLPAPER_SOURCE="$(pick_first_existing "${WALLPAPER_CANDIDATES[@]}")" || {
  echo "[ERROR] Could not find repo-contained clean wallpaper asset."
  echo "Searched:"
  printf '  - %s\n' "${WALLPAPER_CANDIDATES[@]}"
  exit 1
}

TARGET_SPLASH="$PROJECT_ROOT/live-build/config/includes.chroot/usr/share/tornlinux/splash.png"
TARGET_WALLPAPER="$PROJECT_ROOT/live-build/config/includes.chroot/usr/share/tornlinux/wallpaper.png"
TARGET_PLYMOUTH_BG="$PROJECT_ROOT/live-build/config/includes.chroot/usr/share/plymouth/themes/tornlinux/background.png"

ARCHIVE_SPLASH_DIR="$PROJECT_ROOT/assets/splash"
ARCHIVE_WALLPAPER_DIR="$PROJECT_ROOT/assets/wallpaper"
ARCHIVE_SPLASH="$ARCHIVE_SPLASH_DIR/splash_${CURRENT_VERSION}.png"
ARCHIVE_WALLPAPER="$ARCHIVE_WALLPAPER_DIR/wallpaper_${CURRENT_VERSION}.png"

mkdir -p "$(dirname "$TARGET_SPLASH")" "$(dirname "$TARGET_WALLPAPER")" "$(dirname "$TARGET_PLYMOUTH_BG")"
mkdir -p "$ARCHIVE_SPLASH_DIR" "$ARCHIVE_WALLPAPER_DIR"

echo ""
echo "[1/5] Using repo-contained source assets..."
echo "Splash source:    $SPLASH_SOURCE"
echo "Wallpaper source: $WALLPAPER_SOURCE"
echo "Version:          $CURRENT_VERSION"

echo ""
echo "[2/5] Replacing active runtime visuals..."
cp "$SPLASH_SOURCE" "$TARGET_SPLASH"
cp "$WALLPAPER_SOURCE" "$TARGET_WALLPAPER"
cp "$SPLASH_SOURCE" "$TARGET_PLYMOUTH_BG"

echo ""
echo "[3/5] Writing version-consistent archive copies..."
cp "$SPLASH_SOURCE" "$ARCHIVE_SPLASH"
cp "$WALLPAPER_SOURCE" "$ARCHIVE_WALLPAPER"

STATUS_FILE="$PROJECT_ROOT/features/001-clean-visual-assets/docs/status.md"
NOTES_FILE="$PROJECT_ROOT/features/001-clean-visual-assets/docs/notes.md"
DECISIONS_FILE="$PROJECT_ROOT/features/001-clean-visual-assets/docs/decisions.md"

echo ""
echo "[4/5] Refreshing feature documentation..."
if [ -f "$STATUS_FILE" ]; then
  cat > "$STATUS_FILE" <<EOF
status: in-progress
tested: no
merged: no
source: repo-contained salvage assets
human-check: pending
version: $CURRENT_VERSION
EOF
fi

if [ -f "$NOTES_FILE" ]; then
  cat > "$NOTES_FILE" <<EOF
# Feature 001: Clean Visual Assets

## Purpose
Replace the stable baseline active runtime visuals with the finalized clean versions recovered from the repo-contained salvage source.

## Scope
- active splash image
- active wallpaper image
- active Plymouth background image
- version-consistent asset history copies for the current baseline version

## Source
- $SPLASH_SOURCE
- $WALLPAPER_SOURCE

## Targets
- live-build/config/includes.chroot/usr/share/tornlinux/splash.png
- live-build/config/includes.chroot/usr/share/tornlinux/wallpaper.png
- live-build/config/includes.chroot/usr/share/plymouth/themes/tornlinux/background.png
- assets/splash/splash_${CURRENT_VERSION}.png
- assets/wallpaper/wallpaper_${CURRENT_VERSION}.png
EOF
fi

if [ -f "$DECISIONS_FILE" ]; then
  cat > "$DECISIONS_FILE" <<EOF
# Decisions

- Feature 001 replaces only the active runtime visual assets.
- Limited version consistency is included by creating current-version archive copies.
- Historical assets are preserved and not deleted.
- Animation, UI changes, and broader asset-system redesign remain out of scope.
EOF
fi

echo ""
echo "[5/5] Feature 001 asset application complete."
echo ""
echo "Updated runtime targets:"
echo "  - $TARGET_SPLASH"
echo "  - $TARGET_WALLPAPER"
echo "  - $TARGET_PLYMOUTH_BG"
echo ""
echo "Updated versioned asset copies:"
echo "  - $ARCHIVE_SPLASH"
echo "  - $ARCHIVE_WALLPAPER"
echo ""
echo "Next:"
echo "  1. git status"
echo "  2. review changed files"
echo "  3. commit Feature 001"
echo "  4. rebuild from fresh build workspace"
echo "========================================"
