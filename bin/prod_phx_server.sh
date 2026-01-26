#!/bin/bash

# Production environment Phoenix server startup script
# Usage: ./bin/prod_phx_server.sh

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
UI_DIR="$PROJECT_ROOT/ui"

cd "$UI_DIR"

# Check if SECRET_KEY_BASE is set, if not generate one
if [ -z "$SECRET_KEY_BASE" ]; then
  echo "SECRET_KEY_BASE is not set. Generating one..."
  export SECRET_KEY_BASE=$(mix phx.gen.secret)
  echo "Generated SECRET_KEY_BASE (for this session only)"
  echo ""
  echo "Note: To persist this value, run:"
  echo "  export SECRET_KEY_BASE=\"$SECRET_KEY_BASE\""
  echo "  ./bin/prod_phx_server.sh"
  echo ""
fi

# Set default values for environment variables if not set
export PHX_HOST="${PHX_HOST:-localhost}"
export PORT="${PORT:-4000}"
export DATABASE_PATH="${DATABASE_PATH:-$UI_DIR/priv/repo/ui_prod.db}"

# Create database if it doesn't exist
if [ ! -f "$DATABASE_PATH" ]; then
  echo "Database not found. Creating database..."
  MIX_ENV=prod mix ecto.create
fi

echo "Starting Phoenix server in production mode..."
echo "SECRET_KEY_BASE: [set]"
echo "DATABASE_PATH: $DATABASE_PATH"
echo "PHX_HOST: $PHX_HOST"
echo "PORT: $PORT"
echo "Access at: http://$PHX_HOST:$PORT"
echo ""

MIX_ENV=prod mix phx.server
