#!/bin/bash

# Production environment firmware build script
# Usage: ./bin/firmware_build_prod.sh

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FIRMWARE_DIR="$PROJECT_ROOT/firmware"
UI_DIR="$PROJECT_ROOT/ui"

echo "Building firmware in production mode..."
echo ""

# Build UI assets
echo "1. Building UI assets..."
cd "$UI_DIR"
MIX_ENV=prod mix assets.deploy
cd "$PROJECT_ROOT"

# Build firmware
echo ""
echo "2. Building firmware (prod environment)..."
cd "$FIRMWARE_DIR"
export MIX_TARGET=rpi4
export MIX_ENV=prod
mix firmware

echo ""
echo "Firmware build completed!"
echo "Output: $FIRMWARE_DIR/_build/rpi4_prod/nerves/images/firmware.fw"
echo ""
echo "To upload to device:"
echo "  ./bin/firmware_upload_prod.sh"
echo ""
echo "Or manually:"
echo "  cd firmware"
echo "  export MIX_TARGET=rpi4"
echo "  export MIX_ENV=prod"
echo "  mix upload"
