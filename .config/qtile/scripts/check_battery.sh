#!/bin/sh

# Start notifier script
~/.config/qtile/scripts/low_bat_notifier.sh &

# Low battery level threshold
low_bat=26

# Battery states
charging="Charging"
fully_charged="Full"
not_charging="Discharging"

# Auto-detect battery path
if [ -d "/sys/class/power_supply/BAT0" ]; then
    BAT_PATH="/sys/class/power_supply/BAT0"
elif [ -d "/sys/class/power_supply/BAT1" ]; then
    BAT_PATH="/sys/class/power_supply/BAT1"
else
    echo "No battery detected, exiting."
    exit 0
fi

check=2

while true; do
    check_running=$(pgrep -fl low_bat_notifier.sh)
    bat_now=$(cat "$BAT_PATH/capacity" 2>/dev/null || echo "100")
    state=$(cat "$BAT_PATH/status" 2>/dev/null || echo "Unknown")
    
    if [ "$state" = "$fully_charged" ] || [ "$state" = "$charging" ]; then
        check=1
        sleep 30
    elif [ "$state" = "$not_charging" ] && [ -z "$check_running" ] && { [ "$bat_now" -gt "$low_bat" ] || [ "$check" -lt 2 ]; }; then
        check=2
        sleep 30
    else
        sleep 30
        ~/.config/qtile/scripts/low_bat_notifier.sh &
    fi
done
