#!/bin/bash

# Inyectar el entorno de sesión en systemd/D-Bus para que los servicios de usuario
# (xdg-desktop-portal, etc.) tengan DISPLAY/XAUTHORITY y funcionen
dbus-update-activation-environment --systemd --all

xrandr --output HDMI-0 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output DP-0 --off --output DP-1 --off --output DP-2 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-3 --off --output DP-4 --off --output DP-5 --off

# Wallpaper: per-theme (~/.config/qtile/wallpapers/<theme>.{png,jpg}) if present, else default
_theme=$(cat ~/.config/qtile/.current_theme 2>/dev/null || echo green)
_wp=""
for _ext in png jpg jpeg; do
  [ -f "$HOME/.config/qtile/wallpapers/$_theme.$_ext" ] && _wp="$HOME/.config/qtile/wallpapers/$_theme.$_ext" && break
done
[ -n "$_wp" ] && feh --bg-fill "$_wp" || feh --bg-scale ~/Wallpaper/claudio-testa-FrlCwXwbwkk-unsplash.jpg

# Start picom
picom --config ~/.config/picom/picom.conf &

nm-applet &

# PolicyKit auth agent: necesario para GUIs que piden permisos root (firewall-config, etc.)
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & disown

greenclip daemon &

# Now-playing notifier (dunst popup on track change)
pgrep -f now_playing.sh > /dev/null || ~/.config/qtile/scripts/now_playing.sh &

rclone --vfs-cache-mode writes mount OneDrive: ~/OneDrive & notify-send "OneDrive connected" "Microsoft OneDrive successfully mounted."
rclone --vfs-cache-mode writes mount GoogleDrive: ~/GoogleDrive & notify-send "GoogleDrive connected" "Google Drive successfully mounted."
