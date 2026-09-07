#!/bin/bash

# Evolution X - RMX2170 (Realme 7 Pro)
# Usage: curl -sf https://raw.githubusercontent.com/r7pro/crave_script/aosp-16/evolution_rmx2170.sh | bash

set -e

echo "=============================="
echo " Evolution X Build - RMX2170"
echo "=============================="

# Clean old local manifests
rm -rf .repo/local_manifests/

# Init repo
repo init -u https://github.com/Evolution-X/manifest -b bka --git-lfs --depth=1
echo "=================="
echo "Repo init success"
echo "=================="

# Clone device local manifests
git clone -b evox-bka https://github.com/r7pro/RMX2170-manifest .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

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
