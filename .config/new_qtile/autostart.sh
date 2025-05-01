#!/bin/sh
# feh --bg-scale /usr/share/endeavouros/backgrounds/endeavouros-wallpaper.png
# feh --bg-fill /usr/share/endeavouros/backgrounds/eos_wallpapers_community/Endy_vector_EOS-planet.png

# xrandr --output HDMI-0 --primary --mode 1920x1080 --pos 900x0 --rotate normal --output DP-0 --off --output DP-1 --off --output DP-2 --mode 1600x900 --pos 0x0 --rotate right
xrandr --output HDMI-0 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output DP-0 --off --output DP-1 --off --output DP-2 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-3 --off --output DP-4 --off --output DP-5 --off


# feh --bg-fill /home/macanepa/Pictures/frieren.png
# feh --bg-fill ~/.config/qtile/wallpapers/Z375
feh --bg-fill ~/.config/qtile/wallpapers/nieve.jpg

picom & disown # --experimental-backends --vsync should prevent screen tearing on most setups if needed

# Low battery notifier
# ~/.config/qtile/scripts/check_battery.sh & disown

# Bluetooth
# blueman-applet &

# Start welcome
# eos-welcome & disown

nm-applet &

# /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & disown # start polkit agent from GNOME

greenclip daemon &

rclone --vfs-cache-mode writes mount OneDrive: ~/OneDrive & notify-send "OneDrive connected" "Microsoft OneDrive successfully mounted."
