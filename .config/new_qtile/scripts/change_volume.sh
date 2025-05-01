#!/bin/bash

# Check if a parameter was passed
if [ -z "$1" ]; then
    echo "Please provide a volume increment/decrement."
    exit 1
fi

# Increase or decrease volume by the value passed as the first argument
pactl -- set-sink-volume @DEFAULT_SINK@ "$1"

# Get current volume percentage
volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk -F'/' '{print $2}' | tr -d '[:space:]')

# Make sure the volume is not over 100% or below 0%
if [[ "$volume" == "100%" ]]; then
    volume=100
elif [[ "$volume" == "0%" ]]; then
    volume=0
fi

# Send notification with the current volume level and progress bar
notify-send -r 1234 -u normal -i media-volume-high -h "int:value:${volume}" -h "int:progress:${volume}" "Volume: ${volume}"
