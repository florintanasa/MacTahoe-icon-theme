#!/bin/bash
# =========================================================================
# BRGV-OS Theme Asset Compilation and Unification Utility
# Curates and packages all compiled color/size variants into a single tar.gz
# =========================================================================

set -e # Exit immediately if any command returns a non-zero status

# Define source directory and map the output layout safely outside the tree
SRC_DIR="$(pwd)"
BUILD_DIR="${HOME}/brgvos_build_MacTahoe_cursors_tmp"
OUTPUT_ARCHIVE="${SRC_DIR}/MacTahoe-cursors-all.tar.gz"

echo "=== [1/4] Cleaning previous volatile build artifacts ==="
rm -rf "${BUILD_DIR}"
rm -f "${OUTPUT_ARCHIVE}"
mkdir -p "${BUILD_DIR}"

echo "=== [2/4] Executing structural cursor theme compilation ==="
if [ -d "cursors" ]; then
    # Map the relative paths to point to the inner cursors repository layout
    CURSORS_BASE="${SRC_DIR}/cursors"
    OPEN_DIR="${CURSORS_BASE}"
    UPSTREAM_SRC_DIR="${CURSORS_BASE}/src"
    INDEX_FILE="${UPSTREAM_SRC_DIR}/cursorSVG"

    # Define color mappings modeled on upstream arrays
    COLOR_VARIANTS=("" "-dark")

    # Double structural iteration loop replicating the target installation workflow
    for color in "${COLOR_VARIANTS[@]}"; do
        # Map target directory output tokens dynamically outside the tree
        THEME_DIR="${BUILD_DIR}/MacTahoe${color}-cursors"

        echo "Building cursor flavor: MacTahoe${color}-cursors..."
        mkdir -p "${THEME_DIR}"

        # 1. Copy core binary distribution assets
        cp -r "${CURSORS_BASE}/dist${color}"/* "${THEME_DIR}/"

        # 2. Inject vector layouts and assets tree required for scaling consistency
        cp -rf "${UPSTREAM_SRC_DIR}/scalable" "${THEME_DIR}/cursors_scalable"

        # 3. Inject explicit tracking SVG identifiers loop parsed from upstream index
        if [ -f "${INDEX_FILE}" ]; then
            for svgid in $(cat "${INDEX_FILE}"); do
                cp -rf "${UPSTREAM_SRC_DIR}/svg${color}/${svgid}.svg" "${THEME_DIR}/cursors_scalable/${svgid}" 2>/dev/null || true
            done
        fi

        # 4. Inject structural progress, spinner, and wait state components
        cp -rf "${UPSTREAM_SRC_DIR}/svg${color}/progress"*.svg "${THEME_DIR}/cursors_scalable/progress" 2>/dev/null || true
        cp -rf "${UPSTREAM_SRC_DIR}/svg${color}/wait"*.svg "${THEME_DIR}/cursors_scalable/wait" 2>/dev/null || true
    done
else
    echo "ERROR: 'cursors' target directory structure not found in current path!"
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
