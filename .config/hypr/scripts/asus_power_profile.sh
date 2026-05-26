#!/usr/bin/env bash

set -euo pipefail

profiles=("Quiet" "Balanced" "Performance")

get_current_profile() {
  local out profile

  out="$(asusctl profile -p 2>/dev/null || true)"
  profile="$(printf "%s\n" "$out" | grep -oE '(Quiet|Balanced|Performance)' | head -n1 || true)"

  if [ -z "$profile" ]; then
    profile="Unknown"
  fi

  printf "%s\n" "$profile"
}

set_profile() {
  local target="$1"

  if asusctl profile -P "$target" >/dev/null 2>&1; then
    return 0
  fi

  if sudo -n asusctl profile -P "$target" >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

next_profile() {
  local current="$1"

  case "$current" in
    Quiet) printf "Balanced\n" ;;
    Balanced) printf "Performance\n" ;;
    Performance) printf "Quiet\n" ;;
    *) printf "Balanced\n" ;;
  esac
}

print_status() {
  local current icon
  current="$(get_current_profile)"

  case "$current" in
    Quiet) icon="󰾅" ;;
    Balanced) icon="󰓅" ;;
    Performance) icon="󰓄" ;;
    *) icon="󰾆" ;;
  esac

  printf "%s %s\n" "$icon" "$current"
}

case "${1:-}" in
  --status|"")
    print_status
    ;;
  --toggle)
    current="$(get_current_profile)"
    target="$(next_profile "$current")"
    set_profile "$target"
    ;;
  --set)
    shift
    case "${1:-}" in
      Quiet|Balanced|Performance)
        set_profile "$1"
        ;;
      *)
        echo "Usage: $0 [--status|--toggle|--set Quiet|Balanced|Performance]" >&2
        exit 2
        ;;
    esac
    ;;
  *)
    echo "Usage: $0 [--status|--toggle|--set Quiet|Balanced|Performance]" >&2
    exit 2
    ;;
esac
