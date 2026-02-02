#!/bin/bash

### VARIABLES

POLL_INTERVAL=90     # seconds at which to check battery level
LOW_BAT=26           # lesser than this is considered low battery

# Auto-detect battery path
if [ -d "/sys/class/power_supply/BAT0" ]; then
    BAT_PATH=/sys/class/power_supply/BAT0
elif [ -d "/sys/class/power_supply/BAT1" ]; then
    BAT_PATH=/sys/class/power_supply/BAT1
else
    echo "No battery detected, exiting."
    exit 0
fi

BAT_STAT=$BAT_PATH/status

if [[ -f $BAT_PATH/charge_full ]]; then
    BAT_FULL=$BAT_PATH/charge_full
    BAT_NOW=$BAT_PATH/charge_now
elif [[ -f $BAT_PATH/energy_full ]]; then
    BAT_FULL=$BAT_PATH/energy_full
    BAT_NOW=$BAT_PATH/energy_now
elif [[ -f $BAT_PATH/capacity ]]; then
    # Some systems only have capacity (percentage)
    USE_CAPACITY=true
else
    exit 0
fi

# Check if the notification is launched 3 times, then quit the script
launched=0

# Run only if battery is detected
if ls -1qA /sys/class/power_supply/ | grep -q .; then
    while true; do
        if [[ "$USE_CAPACITY" == "true" ]]; then
            bat_percent=$(cat $BAT_PATH/capacity)
        else
            bf=$(cat $BAT_FULL)
            bn=$(cat $BAT_NOW)
            bat_percent=$(( 100 * bn / bf ))
        fi
        
        bs=$(cat $BAT_STAT)

        if [[ $bat_percent -lt $LOW_BAT && "$bs" == "Discharging" ]]; then
            notify-send --urgency=critical --expire-time=5000 "$bat_percent% : Low Battery!"
            launched=$((launched+1))
            (( launched == 3 )) && exit
        fi
        sleep $POLL_INTERVAL
    done
fi
