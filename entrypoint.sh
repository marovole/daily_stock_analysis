#!/bin/bash
set -e

DATA_DIR="/app/data"
ENV_FILE="${ENV_FILE:-$DATA_DIR/.env}"

mkdir -p "$DATA_DIR" /app/logs /app/reports

if [ ! -f "$ENV_FILE" ] && [ -f "/app/.env.example" ]; then
    cp /app/.env.example "$ENV_FILE"
    echo "Created $ENV_FILE from template"
fi

exec python main.py "$@"
