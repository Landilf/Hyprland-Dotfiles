#!/usr/bin/env bash

# Volume settings
STEP=2
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

# When Easy Effects is the default sink, control the physical sink connected
# to its playback filter. Resolve it on every press so device changes work.
OUTPUT_TARGET=@DEFAULT_AUDIO_SINK@
if wpctl inspect @DEFAULT_AUDIO_SINK@ | grep -Fq 'node.name = "easyeffects_sink"'; then
    OUTPUT_TARGET=$(pw-dump | jq -r '
        [.[] | select(.type == "PipeWire:Interface:Node")] as $nodes |
        [.[] | select(.type == "PipeWire:Interface:Link") | .info.props as $link |
          select(any($nodes[]; .id == $link["link.output.node"] and
            .info.props["node.group"] == "ee_sink_group")) |
          $nodes[] | select(.id == $link["link.input.node"] and
            .info.props["media.class"] == "Audio/Sink" and
            (.info.props["node.virtual"] // false) != true) | .id] |
        unique | first // empty'
    )
    if [ -z "$OUTPUT_TARGET" ]; then
        notify-send -e -h string:x-canonical-private-synchronous:volume \
                    -u low -i audio-volume-muted-symbolic -t 1000 \
                    "Easy Effects: output device not connected"
        exit 1
    fi
fi

if ! VOLUME_DATA=$(wpctl get-volume "$OUTPUT_TARGET"); then
    exit 1
fi
CURRENT=$(echo "$VOLUME_DATA" | awk '{print $2 * 100}' | cut -d. -f1)
IS_MUTED=$(echo "$VOLUME_DATA" | grep -q "MUTED" && echo "true" || echo "false")

if [ "$1" == "up" ]; then
    # Unmute if muted when raising volume
    [ "$IS_MUTED" == "true" ] && wpctl set-mute "$OUTPUT_TARGET" 0

    NEW=$((CURRENT + STEP))
    [ $NEW -gt $MAX_VOLUME ] && NEW=$MAX_VOLUME
    wpctl set-volume "$OUTPUT_TARGET" "${NEW}%"
elif [ "$1" == "down" ]; then
    NEW=$((CURRENT - STEP))
    [ $NEW -lt 0 ] && NEW=0
    wpctl set-volume "$OUTPUT_TARGET" "${NEW}%"
elif [ "$1" == "mute" ]; then
    wpctl set-mute "$OUTPUT_TARGET" toggle
fi

# Final fetch for notification
VOLUME_DATA=$(wpctl get-volume "$OUTPUT_TARGET")
NEW=$(echo "$VOLUME_DATA" | awk '{print int($2 * 100 + 0.5)}')
IS_MUTED=$(echo "$VOLUME_DATA" | grep -q "MUTED" && echo "true" || echo "false")

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
