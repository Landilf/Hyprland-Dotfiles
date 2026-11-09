#!/usr/bin/env bash
set -eu
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if quickshell kill --path "$script_dir/shell.qml" >/dev/null 2>&1; then
    exit 0
fi
export EMOJI_MENU_DIR="$script_dir"
quickshell --no-duplicate --path "$script_dir/shell.qml"
