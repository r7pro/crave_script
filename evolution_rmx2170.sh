#!/bin/bash

# ============================================================
# Evolution X - RMX2170 (Realme 7 Pro)
# ============================================================
#
# Usage: crave -n run --no-patch -- "curl -sf https://raw.githubusercontent.com/r7pro/crave_script/aosp-16/evolution_rmx2170.sh | bash"
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
# Helper: Normalize Git URL
# ============================================================

normalize_git_url() {
    echo "$1" \
        | sed 's#\.git$##' \
        | sed 's#/$##'
}

# ============================================================
# Check existing repo
# ============================================================

echo "=============================="
echo " Checking existing repo..."
echo "=============================="

NEED_REINIT=true

if [ ! -d ".repo" ]; then

    echo "No repo found."

else

    CURRENT_MANIFEST_REMOTE=$( \
        git -C .repo/manifests remote get-url origin 2>/dev/null || true
    )

    CURRENT_MANIFEST_BRANCH=$( \
        git -C .repo/manifests symbolic-ref --short HEAD 2>/dev/null || true
    )

    NORMALIZED_CURRENT_REMOTE=$(normalize_git_url "$CURRENT_MANIFEST_REMOTE")
    NORMALIZED_EXPECTED_REMOTE=$(normalize_git_url "$ROM_MANIFEST_URL")

    echo "Manifest remote : ${CURRENT_MANIFEST_REMOTE:-unknown}"
    echo "Manifest branch : ${CURRENT_MANIFEST_BRANCH:-unknown}"

    if [ "$NORMALIZED_CURRENT_REMOTE" != "$NORMALIZED_EXPECTED_REMOTE" ] || \
       [ "$CURRENT_MANIFEST_BRANCH" != "$ROM_MANIFEST_BRANCH" ]; then

        echo "=============================="
        echo " Different ROM repo detected"
        echo "=============================="

        echo "Expected remote : $ROM_MANIFEST_URL"
        echo "Expected branch : $ROM_MANIFEST_BRANCH"
        echo "Found remote    : ${CURRENT_MANIFEST_REMOTE:-unknown}"
        echo "Found branch    : ${CURRENT_MANIFEST_BRANCH:-unknown}"

        echo
        echo "Re-initializing repo for $ROM_NAME..."
        echo "Existing .repo will NOT be deleted."

        NEED_REINIT=true

    else

        echo "Correct ROM repo detected."
        NEED_REINIT=false

    fi
fi

# ============================================================
# Initialize / Re-initialize ROM repo
# ============================================================

if [ "$NEED_REINIT" = true ]; then

    echo "=============================="
    echo " Initializing $ROM_NAME..."
    echo "=============================="

    repo init \
        -u "$ROM_MANIFEST_URL" \
        -b "$ROM_MANIFEST_BRANCH" \
        --git-lfs \
        --depth=1

    echo "=============================="
    echo " Repo initialized"
    echo "=============================="

else

    echo "=============================="
    echo " Existing repo is correct"
    echo "=============================="

fi

# ============================================================
# Check device local manifest
# ============================================================

echo "=============================="
echo " Checking device manifest..."
echo "=============================="

if [ -d ".repo/local_manifests/.git" ]; then

    CURRENT_DEVICE_MANIFEST_URL=$( \
        git -C .repo/local_manifests remote get-url origin 2>/dev/null || true
    )

    CURRENT_DEVICE_MANIFEST_BRANCH=$( \
        git -C .repo/local_manifests symbolic-ref --short HEAD 2>/dev/null || true
    )

    NORMALIZED_CURRENT_DEVICE_URL=$( \
        normalize_git_url "$CURRENT_DEVICE_MANIFEST_URL"
    )

    NORMALIZED_EXPECTED_DEVICE_URL=$( \
        normalize_git_url "$DEVICE_MANIFEST_URL"
    )

    echo "Device manifest URL    : ${CURRENT_DEVICE_MANIFEST_URL:-unknown}"
    echo "Device manifest branch : ${CURRENT_DEVICE_MANIFEST_BRANCH:-unknown}"

    if [ "$NORMALIZED_CURRENT_DEVICE_URL" = "$NORMALIZED_EXPECTED_DEVICE_URL" ] && \
       [ "$CURRENT_DEVICE_MANIFEST_BRANCH" = "$DEVICE_MANIFEST_BRANCH" ]; then

        echo "Correct device manifest found."
        echo "Pulling latest changes..."

        git -C .repo/local_manifests pull --ff-only

    else

        echo "Wrong device manifest detected."
        echo "Replacing it..."

        rm -rf .repo/local_manifests

        git clone \
            -b "$DEVICE_MANIFEST_BRANCH" \
            "$DEVICE_MANIFEST_URL" \
            .repo/local_manifests
    fi

else

    echo "Device manifest not found."

    rm -rf .repo/local_manifests

    git clone \
        -b "$DEVICE_MANIFEST_BRANCH" \
        "$DEVICE_MANIFEST_URL" \
        .repo/local_manifests
fi

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
echo " Building $ROM_NAME..."
echo "=============================="

m "$BUILD_TARGET"

echo "=============================="
echo " Build complete"
echo "=============================="
