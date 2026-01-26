#!/bin/bash

# Development environment Phoenix server startup script
# Usage: ./bin/dev_phx_server.sh

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
UI_DIR="$PROJECT_ROOT/ui"

cd "$UI_DIR"

echo "Starting Phoenix server in development mode..."
echo "Access at: http://localhost:4000"
echo ""

mix phx.server
