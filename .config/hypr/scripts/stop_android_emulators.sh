#!/usr/bin/env bash
set -uo pipefail

emulator_dir="/home/landilf/ProgrammingSoftware/Android/Sdk/emulator/"

pgrep -f -- "$emulator_dir" >/dev/null 2>&1 || exit 0

# Let the emulator save its state before a sleep mode that writes RAM to disk.
pkill -TERM -f -- "$emulator_dir" 2>/dev/null || true
for _ in {1..10}; do
  pgrep -f -- "$emulator_dir" >/dev/null 2>&1 || exit 0
  sleep 1
done

# Do not allow a stuck emulator to make hibernation fail.
pkill -KILL -f -- "$emulator_dir" 2>/dev/null || true
