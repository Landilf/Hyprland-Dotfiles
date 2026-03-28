#!/usr/bin/env bash

# Limit settings in percent
LIMIT_MIN_PC=0
LIMIT_MAX_PC=50
STEP_PC=4

# Get hardware data
MAX_RAW=$(brightnessctl m)
CURRENT_RAW=$(brightnessctl g)

# Convert percentages to raw values
MIN_RAW=$(( MAX_RAW * LIMIT_MIN_PC / 100 ))
MAX_RAW_LIMIT=$(( MAX_RAW * LIMIT_MAX_PC / 100 ))
STEP_RAW=$(( MAX_RAW * STEP_PC / 100 ))

# Calculate new value
if [ "$1" == "up" ]; then
    NEW_RAW=$(( CURRENT_RAW + STEP_RAW ))
elif [ "$1" == "down" ]; then
    NEW_RAW=$(( CURRENT_RAW - STEP_RAW ))
else
    exit 0
fi

# Clamp result to limits
[ "$NEW_RAW" -gt "$MAX_RAW_LIMIT" ] && NEW_RAW=$MAX_RAW_LIMIT
[ "$NEW_RAW" -lt "$MIN_RAW" ] && NEW_RAW=$MIN_RAW

# Set brightness
brightnessctl set "$NEW_RAW"

# Calculate relative percentage for OSD indicator
RANGE_RAW=$(( MAX_RAW_LIMIT - MIN_RAW ))
if [ "$RANGE_RAW" -le 0 ]; then
    RELATIVE=100
else
    RELATIVE=$(( (NEW_RAW - MIN_RAW) * 100 / RANGE_RAW ))
fi

# Use notify-send: reliable, no conflicts or errors
notify-send -e -h string:x-canonical-private-synchronous:brightness \
            -h int:value:"$RELATIVE" \
            -u low \
            -i display-brightness-symbolic \
            -t 1000 "Brightness: $RELATIVE%"
