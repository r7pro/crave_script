#!/bin/bash

# ============================================================
# Evolution X - RMX2170 (Realme 7 Pro)
# ============================================================
#
# Usage:
# crave -n run --no-patch -- "curl -sf https://raw.githubusercontent.com/r7pro/crave_script/aosp-16/evolution_rmx2170.sh | bash"
#
# ============================================================

set -e

# ============================================================
# CONFIG - CHANGE ONLY THESE VALUES FOR A DIFFERENT ROM
# ============================================================

ROM_NAME="Evolution X"

ROM_MANIFEST_URL="https://github.com/Evolution-X/manifest"
ROM_MANIFEST_BRANCH="bka"

DEVICE_MANIFEST_URL="https://github.com/r7pro/RMX2170-manifest"
DEVICE_MANIFEST_BRANCH="evox-bka"

DEVICE="RMX2170"
LUNCH_TARGET="lineage_RMX2170-user"
BUILD_TARGET="evolution"

SOURCE_DIR="/tmp/src/android"

# ============================================================
# DO NOT MODIFY BELOW THIS LINE
# ============================================================

echo "=============================="
echo " $ROM_NAME Build - $DEVICE"
echo "=============================="

# Use SOURCE_DIR only if it exists, otherwise build in current workspace
if [ -d "$SOURCE_DIR" ]; then
    cd "$SOURCE_DIR"
fi
echo "Working directory: $(pwd)"

# ============================================================
# Initialize ROM repo
# ============================================================

echo "=============================="
echo " Initializing $ROM_NAME ($ROM_MANIFEST_BRANCH)..."
echo "=============================="

repo init \
    -u "$ROM_MANIFEST_URL" \
    -b "$ROM_MANIFEST_BRANCH" \
    --git-lfs \
    --depth=1

echo "=============================="
echo " Repo initialized"
echo "=============================="

# ============================================================
# Setup device local manifest
# ============================================================

echo "=============================="
echo " Setting up device manifest..."
echo "=============================="

rm -rf .repo/local_manifests

git clone \
    -b "$DEVICE_MANIFEST_BRANCH" \
    "$DEVICE_MANIFEST_URL" \
    .repo/local_manifests

echo "=============================="
echo " Device manifest ready"
echo "=============================="

# ============================================================
# Sync source
# ============================================================

echo "=============================="
echo " Syncing source..."
echo "=============================="

/opt/crave/resync.sh

echo "=============================="
echo " Sync complete"
echo "=============================="

# ============================================================
# Build environment
# ============================================================

echo "=============================="
echo " Setting up build environment..."
echo "=============================="

source build/envsetup.sh

echo "=============================="
echo " Envsetup complete"
echo "=============================="

# ============================================================
# Lunch target
# ============================================================

echo "=============================="
echo " Running lunch $LUNCH_TARGET..."
echo "=============================="

lunch "$LUNCH_TARGET"

echo "=============================="
echo " Lunch complete"
echo "=============================="

# ============================================================
# Build
# ============================================================

echo "=============================="
echo " Building $ROM_NAME ($BUILD_TARGET)..."
echo "=============================="

m "$BUILD_TARGET"

echo "=============================="
echo " Build complete successfully"
echo "=============================="
