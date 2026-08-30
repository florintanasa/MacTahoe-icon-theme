#!/bin/bash
# =========================================================================
# BRGV-OS Theme Asset Compilation and Unification Utility
# Curates and packages all compiled color/size variants into a single tar.gz
# =========================================================================

set -e # Exit immediately if any command returns a non-zero status

# Define source directory and map the output layout safely outside the tree
SRC_DIR="$(pwd)"
BUILD_DIR="${HOME}/brgvos_build_MacTahoe_icon_tmp"
OUTPUT_ARCHIVE="${SRC_DIR}/MacTahoe-icons-all.tar.gz"

echo "=== [1/4] Cleaning previous volatile build artifacts ==="
rm -rf "${BUILD_DIR}"
rm -f "${OUTPUT_ARCHIVE}"
mkdir -p "${BUILD_DIR}"

echo "=== [2/4] Executing native SASS/CSS theme compilation layer ==="
# Invokes the installer using all variations outside the source path boundary
if [ -f "./install.sh" ]; then
    ./install.sh -d "${BUILD_DIR}" --theme all
else
    echo "ERROR: Core install.sh script not found in current directory!"
    exit 1
fi

echo "=== [3/4] Purging hazardous and forbidden upstream file permission masks ==="
# Standardizes UNIX masks to satisfy strict target distribution packaging laws
find "${BUILD_DIR}" -type f -exec chmod 644 {} +
find "${BUILD_DIR}" -type d -exec chmod 755 {} +

echo "=== [4/4] Packing structural tree into a compressed global archive ==="
# Compress target directories symmetrically without embedding nested parent paths
cd "${BUILD_DIR}"
tar -czf "${OUTPUT_ARCHIVE}" .
cd "${SRC_DIR}"

# Housekeeping: delete the external temporary building folder tree to save space
rm -rf "${BUILD_DIR}"

echo "========================================================================="
# Check physical existence of final bundle to ensure compilation integrity
if [ -f "${OUTPUT_ARCHIVE}" ]; then
    ARCHIVE_SIZE=$(du -sh "${OUTPUT_ARCHIVE}" | cut -f1)
    echo " SUCCESS: Unified tarball generated perfectly: ${OUTPUT_ARCHIVE}"
    echo " Combined package payload footprint: ${ARCHIVE_SIZE}"
    echo " Action Required: Upload this file as binary to GitHub Release."
else
    echo " ERROR: Tarball generation phase failed unexpectedly."
    exit 1
fi
echo "========================================================================="
