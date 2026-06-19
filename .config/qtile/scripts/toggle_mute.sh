#!/bin/bash
# Toggle mute on the default sink and show a notification
# (mirrors change_volume.sh: same replace-id 1234 so it stacks with volume changes)
pactl set-sink-mute @DEFAULT_SINK@ toggle

muted=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk -F'/' '{print $2}' | tr -d '[:space:]%')

if [ "$muted" = "yes" ]; then
    notify-send -r 1234 -u normal -i audio-volume-muted -h "int:value:0" -h "int:progress:0" "Muted"
else
    notify-send -r 1234 -u normal -i audio-volume-high -h "int:value:${volume}" -h "int:progress:${volume}" "Volume: ${volume}%"
fi
