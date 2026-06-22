#!/usr/bin/env bash

# Limit settings in percent
LIMIT_MIN_PC=0
LIMIT_MAX_PC=50
STEP_PC=4

# Get hardware data
MAX_RAW=$(brightnessctl m)
CURRENT_RAW=$(brightnessctl g)

# Convert limits to raw values
MIN_RAW=$(( MAX_RAW * LIMIT_MIN_PC / 100 ))
MAX_RAW_LIMIT=$(( MAX_RAW * LIMIT_MAX_PC / 100 ))
RANGE_RAW=$(( MAX_RAW_LIMIT - MIN_RAW ))

# Calculate current relative percentage (rounded)
if [ "$RANGE_RAW" -le 0 ]; then
    CURRENT_REL=100
else
    CURRENT_REL=$(awk -v c="$CURRENT_RAW" -v m="$MIN_RAW" -v r="$RANGE_RAW" 'BEGIN { printf "%d", (c - m) * 100 / r + 0.5 }')
fi

# Calculate new relative percentage
if [ "$1" == "up" ]; then
    NEW_REL=$(( CURRENT_REL + STEP_PC ))
elif [ "$1" == "down" ]; then
    NEW_REL=$(( CURRENT_REL - STEP_PC ))
else
    exit 0
fi

# Clamp relative to 0-100 limits
[ "$NEW_REL" -gt 100 ] && NEW_REL=100
[ "$NEW_REL" -lt 0 ] && NEW_REL=0

# Convert back to raw value for setting (rounded)
NEW_RAW=$(awk -v nr="$NEW_REL" -v m="$MIN_RAW" -v r="$RANGE_RAW" 'BEGIN { printf "%d", m + (nr * r / 100) + 0.5 }')

# Set brightness
brightnessctl set "$NEW_RAW"

# Use exact step for OSD indicator
RELATIVE=$NEW_REL

# Use notify-send: reliable, no conflicts or errors
notify-send -e -h string:x-canonical-private-synchronous:brightness \
            -h int:value:"$RELATIVE" \
            -u low \
            -i display-brightness-symbolic \
            -t 1000 "Brightness: $RELATIVE%"
