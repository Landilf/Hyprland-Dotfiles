#!/usr/bin/env bash

# Prevent multiple instances
if pgrep -x "power_refresh.sh" > /dev/null; then
    if [ "$$" != "$(pgrep -fo "power_refresh.sh")" ]; then
        exit 1
    fi
fi

# Script for changing monitor refresh rate based on power status
# 144Hz on AC, 60Hz on battery

# Function to get the current monitor name
get_monitor() {
    hyprctl monitors | grep "Monitor " | awk '{print $2}' | head -n 1
}

# Function to set the refresh rate
set_refresh() {
    local rate=$1
    local monitor=$(get_monitor)
    
    if [ -n "$monitor" ]; then
        echo "Setting monitor $monitor to ${rate}Hz"
        hyprctl keyword monitor "$monitor, 1920x1080@$rate, 0x0, 1"
    else
        echo "Monitor not found, trying fallback eDP-1"
        hyprctl keyword monitor "eDP-1, 1920x1080@$rate, 0x0, 1"
    fi
}

# Function to get current power status (returns 1 for AC, 0 for Battery)
get_ac_status() {
    for ac in /sys/class/power_supply/AC* /sys/class/power_supply/ADP*; do
        if [ -f "$ac/online" ]; then
            cat "$ac/online"
            return
        fi
    done
    echo 1 # Default to AC if not found
}

# Initial check
AC_STATUS=$(get_ac_status)
PREV_STATUS=$AC_STATUS

if [ "$AC_STATUS" -eq 1 ]; then
    set_refresh 144
else
    set_refresh 144
fi

# Monitoring loop
while true; do
    AC_STATUS=$(get_ac_status)
    
    if [ "$AC_STATUS" != "$PREV_STATUS" ]; then
        if [ "$AC_STATUS" -eq 1 ]; then
            set_refresh 144
        else
            set_refresh 144
        fi
        PREV_STATUS=$AC_STATUS
    fi
    
    sleep 5
done
