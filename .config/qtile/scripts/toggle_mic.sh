#!/bin/bash
# Toggle mute on the default microphone (input source) + notification
pactl set-source-mute @DEFAULT_SOURCE@ toggle

muted=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')
if [ "$muted" = "yes" ]; then
    notify-send -r 1236 -u normal -i microphone-sensitivity-muted "Micrófono silenciado"
else
    notify-send -r 1236 -u normal -i microphone-sensitivity-high "Micrófono activo"
fi
