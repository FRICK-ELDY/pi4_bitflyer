#!/bin/bash

# Development environment firmware upload script
# Usage: ./bin/firmware_upload_dev.sh [device_hostname]

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FIRMWARE_DIR="$PROJECT_ROOT/firmware"

# Default device hostname
DEVICE_HOSTNAME="${1:-nerves.local}"

echo "Uploading firmware to device (dev environment)..."
echo "Device: $DEVICE_HOSTNAME"
echo ""

# Check if firmware file exists
FIRMWARE_FILE="$FIRMWARE_DIR/_build/rpi4_dev/nerves/images/firmware.fw"
if [ ! -f "$FIRMWARE_FILE" ]; then
  echo "Error: Firmware file not found: $FIRMWARE_FILE"
  echo "Please build firmware first: ./bin/firmware_build_dev.sh"
  exit 1
fi

# Upload firmware
cd "$FIRMWARE_DIR"
export MIX_TARGET=rpi4
export MIX_ENV=dev
export NERVES_DEVICE_IP="$DEVICE_HOSTNAME"

echo "Uploading firmware..."
mix upload "$DEVICE_HOSTNAME"

echo ""
echo "Firmware upload completed!"
echo "The device will reboot automatically."
