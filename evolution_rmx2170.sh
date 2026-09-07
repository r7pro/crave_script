#!/bin/bash

# Evolution X - RMX2170 (Realme 7 Pro)
# Usage: crave -n run --no-patch -- "curl -sf https://raw.githubusercontent.com/r7pro/crave_script/aosp-16/evolution_rmx2170.sh | bash"

set -e

echo "=============================="
echo " Evolution X Build - RMX2170"
echo "=============================="

MANIFEST_URL="https://github.com/Evolution-X/manifest"
MANIFEST_BRANCH="bka"

# Check if repo is already initialized with Evolution X manifest
if [ -f ".repo/manifest.xml" ] && grep -qi "evolution" .repo/manifest.xml && grep -q "$MANIFEST_BRANCH" .repo/manifest.xml; then
    echo "============================"
    echo "Repo already initialized, skipping init"
    echo "============================"
else
    echo "============================"
    echo "Repo not found, initializing..."
    echo "============================"
    rm -rf .repo/
    repo init -u "$MANIFEST_URL" -b "$MANIFEST_BRANCH" --git-lfs --depth=1
    echo "=================="
    echo "Repo init success"
    echo "=================="
fi

# Clone device local manifests
LOCAL_MANIFEST_URL="https://github.com/r7pro/RMX2170-manifest"
LOCAL_MANIFEST_BRANCH="evox-bka"

if [ -d ".repo/local_manifests" ]; then
    cd .repo/local_manifests
    REMOTE_URL=$(git remote -v | grep -i "origin" | head -1 | awk '{print $2}')
    CURRENT_BRANCH=$(git branch --show-current)
    if echo "$REMOTE_URL" | grep -qi "r7pro/RMX2170-manifest" && [ "$CURRENT_BRANCH" = "$LOCAL_MANIFEST_BRANCH" ]; then
        echo "============================"
        echo "Local manifests exist, pulling latest..."
        echo "============================"
        git pull
        cd ../../
    else
        echo "============================"
        echo "Wrong local manifests, re-cloning..."
        echo "============================"
        cd /tmp/src/android/
        rm -rf .repo/local_manifests/
        git clone -b "$LOCAL_MANIFEST_BRANCH" "$LOCAL_MANIFEST_URL" .repo/local_manifests
    fi
else
    echo "============================"
    echo "Cloning local manifests..."
    echo "============================"
    git clone -b "$LOCAL_MANIFEST_BRANCH" "$LOCAL_MANIFEST_URL" .repo/local_manifests
fi

# Sync
/opt/crave/resync.sh
echo "============================"

# Setup build env
source build/envsetup.sh
echo "====== Envsetup Done ======="

# Lunch
lunch lineage_RMX2170-user
echo "============="

# Build
m evolution
echo "============="
