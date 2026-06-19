#!/bin/bash
# Performance-mode mini-menu (rofi). Reads + sets the AMD platform_profile.
# Switching needs root, granted via a tight sudoers rule for /usr/local/bin/power-profile.
cur=$(cat /sys/firmware/acpi/platform_profile 2>/dev/null)

mark() { [ "$1" = "$cur" ] && printf ' ●'; }

choice=$(printf 'Ahorro%s\nEquilibrado%s\nMáximo%s\n' \
            "$(mark low-power)" "$(mark balanced)" "$(mark performance)" \
         | rofi -dmenu -i -p "Performance" \
                -theme-str 'window {width: 15%;} listview {lines: 3;}')

case "$choice" in
    Ahorro*)      sudo /usr/local/bin/power-profile set low-power ;;
    Equilibrado*) sudo /usr/local/bin/power-profile set balanced ;;
    Máximo*)      sudo /usr/local/bin/power-profile set performance ;;
esac
