#!/bin/bash

# Development environment firmware build script
# Usage: ./bin/firmware_build_dev.sh

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FIRMWARE_DIR="$PROJECT_ROOT/firmware"
UI_DIR="$PROJECT_ROOT/ui"

echo "Building firmware in development mode..."
echo ""

# Build UI assets
echo "1. Building UI assets..."
cd "$UI_DIR"
mix assets.deploy
cd "$PROJECT_ROOT"

# Build firmware
echo ""
echo "2. Building firmware (dev environment)..."
cd "$FIRMWARE_DIR"
export MIX_TARGET=rpi4
export MIX_ENV=dev
mix firmware

echo ""
echo "Firmware build completed!"
echo "Output: $FIRMWARE_DIR/_build/rpi4_dev/nerves/images/firmware.fw"
echo ""
echo "To upload to device:"
echo "  ./bin/firmware_upload_dev.sh"
echo ""
echo "Or manually:"
echo "  cd firmware"
echo "  export MIX_TARGET=rpi4"
echo "  export MIX_ENV=dev"
echo "  mix upload"
