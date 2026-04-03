#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/elmuhammadcholidh/cc-provider-switch.git"
INSTALL_DIR="${CC_SWITCH_DIR:-$HOME/cc-provider-switch}"
BIN_DIR="${CC_SWITCH_BIN:-$HOME/.local/bin}"

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required. Install it first: https://stedolan.github.io/jq/"
    exit 1
fi

echo "Installing cc-provider-switch..."

if [[ -d "$INSTALL_DIR" ]]; then
    echo "Updating existing installation at $INSTALL_DIR..."
    git -C "$INSTALL_DIR" pull --ff-only
else
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/cc-switch" "$BIN_DIR/cc-switch"

echo "Done! Run 'cc-switch' to get started."
