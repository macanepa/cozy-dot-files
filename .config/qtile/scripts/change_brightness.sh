#!/bin/bash
# Change screen brightness and show a progress-bar notification
if [ -z "$1" ]; then
    echo "Usage: change_brightness.sh <+10%|10%->"
    exit 1
fi

brightnessctl set "$1" >/dev/null

cur=$(brightnessctl get)
max=$(brightnessctl max)
pct=$(( cur * 100 / max ))

# replace-id 1235 (distinct from volume's 1234) so brightness and volume don't clobber each other
notify-send -r 1235 -u normal -i display-brightness -h "int:value:${pct}" -h "int:progress:${pct}" "Brightness: ${pct}%"
