#!/usr/bin/env bash

# Volume settings
STEP=5
MAX_VOLUME=100

# Handle Mic Mute
if [ "$1" == "mic-mute" ]; then
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    IS_MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED" && echo "true" || echo "false")
    if [ "$IS_MUTED" == "true" ]; then
        notify-send -e -h string:x-canonical-private-synchronous:mic \
                    -u low -i microphone-sensitivity-muted-symbolic \
                    -t 1000 "Mic Muted"
    else
        notify-send -e -h string:x-canonical-private-synchronous:mic \
                    -u low -i microphone-sensitivity-high-symbolic \
                    -t 1000 "Mic Unmuted"
    fi
    exit 0
fi

# Get current volume and mute status using wpctl
VOLUME_DATA=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
CURRENT=$(echo "$VOLUME_DATA" | awk '{print $2 * 100}' | cut -d. -f1)
IS_MUTED=$(echo "$VOLUME_DATA" | grep -q "MUTED" && echo "true" || echo "false")

if [ "$1" == "up" ]; then
    # Unmute if muted when raising volume
    [ "$IS_MUTED" == "true" ] && wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
    
    NEW=$((CURRENT + STEP))
    [ $NEW -gt $MAX_VOLUME ] && NEW=$MAX_VOLUME
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "${NEW}%"
elif [ "$1" == "down" ]; then
    NEW=$((CURRENT - STEP))
    [ $NEW -lt 0 ] && NEW=0
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "${NEW}%"
elif [ "$1" == "mute" ]; then
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    VOLUME_DATA=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    IS_MUTED=$(echo "$VOLUME_DATA" | grep -q "MUTED" && echo "true" || echo "false")
fi

# Final fetch for notification
NEW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2 * 100}' | cut -d. -f1)

# Notification logic
if [ "$IS_MUTED" == "true" ]; then
    notify-send -e -h string:x-canonical-private-synchronous:volume \
                -u low -i audio-volume-muted-symbolic \
                -t 1000 "Muted"
else
    notify-send -e -h string:x-canonical-private-synchronous:volume \
                -h int:value:"$NEW" \
                -u low -i audio-volume-high-symbolic \
                -t 1000 "Volume: ${NEW}%"
fi
