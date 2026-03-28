#!/usr/bin/env bash

# Settings (synchronized with brightness_control.sh)
LIMIT_MAX_PC=50
IDLE_FACTOR=5 # 5% of the working range

# File to store the brightness before dimming
BRIGHTNESS_FILE="/tmp/hypr_brightness_backup"

# Get current brightness
get_brightness() {
    brightnessctl get
}

case "$1" in
    dim)
        # Only save if we haven't already
        if [ ! -f "$BRIGHTNESS_FILE" ]; then
            CURRENT_RAW=$(get_brightness)
            MAX_RAW=$(brightnessctl m)
            
            # Calculate working max (your "100%")
            WORKING_MAX=$(( MAX_RAW * LIMIT_MAX_PC / 100 ))
            
            # Calculate idle target (5% of working max)
            IDLE_RAW=$(( WORKING_MAX * IDLE_FACTOR / 100 ))

            # Only dim if current brightness is above the idle threshold
            if [ "$CURRENT_RAW" -gt "$IDLE_RAW" ]; then
                echo "$CURRENT_RAW" > "$BRIGHTNESS_FILE"
                brightnessctl set "$IDLE_RAW"
            fi
        fi
        ;;
    restore)
        if [ -f "$BRIGHTNESS_FILE" ]; then
            SAVED_BRIGHTNESS=$(cat "$BRIGHTNESS_FILE")
            brightnessctl set "$SAVED_BRIGHTNESS"
            rm "$BRIGHTNESS_FILE"
        fi
        ;;
    *)
        echo "Usage: $0 {dim|restore}"
        exit 1
        ;;
esac
