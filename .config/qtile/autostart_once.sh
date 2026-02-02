#!/bin/bash

# Cozytile Autostart Script
# This script runs once when Qtile starts

# ─────────────────────────────────────────────────────────────────
#                      Monitor Configuration
# ─────────────────────────────────────────────────────────────────
# Auto-detect and configure monitors
# You can customize this section for your specific setup

# Get connected monitors
connected_monitors=$(xrandr --query | grep " connected" | cut -d" " -f1)
monitor_count=$(echo "$connected_monitors" | wc -l)

if [ "$monitor_count" -gt 1 ]; then
    # Multi-monitor setup - detect primary and configure
    # Customize this for your specific monitors
    primary=$(echo "$connected_monitors" | head -n1)
    secondary=$(echo "$connected_monitors" | tail -n1)
    
    # Try to set up dual monitors side by side
    xrandr --output "$primary" --primary --auto --output "$secondary" --auto --right-of "$primary" 2>/dev/null
else
    # Single monitor - just use auto
    xrandr --auto 2>/dev/null
fi

# ─────────────────────────────────────────────────────────────────
#                         Wallpaper
# ─────────────────────────────────────────────────────────────────
# Apply wallpaper (uses feh, can also use pywal with: wal -i <wallpaper>)
DEFAULT_WALLPAPER="$HOME/Wallpaper/claudio-testa-FrlCwXwbwkk-unsplash.jpg"

if [ -f "$DEFAULT_WALLPAPER" ]; then
    feh --bg-scale "$DEFAULT_WALLPAPER"
elif [ -d "$HOME/Wallpaper" ]; then
    # Fallback to first image in Wallpaper directory
    first_wallpaper=$(find "$HOME/Wallpaper" -type f \( -iname "*.jpg" -o -iname "*.png" \) | head -n1)
    [ -n "$first_wallpaper" ] && feh --bg-scale "$first_wallpaper"
fi

# ─────────────────────────────────────────────────────────────────
#                         Compositor
# ─────────────────────────────────────────────────────────────────
# Start picom compositor for transparency and effects
pkill -x picom 2>/dev/null
sleep 0.5
picom --config ~/.config/picom/picom.conf &

# ─────────────────────────────────────────────────────────────────
#                       System Tray Apps
# ─────────────────────────────────────────────────────────────────
# Network Manager applet
pgrep -x nm-applet > /dev/null || nm-applet &

# Bluetooth manager (if bluetooth is available)
if command -v blueman-applet &> /dev/null && [ -d "/sys/class/bluetooth" ]; then
    pgrep -x blueman-applet > /dev/null || blueman-applet &
fi

# ─────────────────────────────────────────────────────────────────
#                        Clipboard Manager
# ─────────────────────────────────────────────────────────────────
# Greenclip clipboard daemon
pgrep -x greenclip > /dev/null || greenclip daemon &

# ─────────────────────────────────────────────────────────────────
#                         Cloud Storage
# ─────────────────────────────────────────────────────────────────
# Mount OneDrive if rclone is configured
if command -v rclone &> /dev/null; then
    if rclone listremotes 2>/dev/null | grep -q "OneDrive:"; then
        # Check if already mounted
        if ! mountpoint -q "$HOME/OneDrive" 2>/dev/null; then
            mkdir -p "$HOME/OneDrive"
            rclone --vfs-cache-mode writes mount OneDrive: "$HOME/OneDrive" &
            sleep 2
            if mountpoint -q "$HOME/OneDrive" 2>/dev/null; then
                notify-send "OneDrive Connected" "Microsoft OneDrive successfully mounted."
            fi
        fi
    fi
fi

# ─────────────────────────────────────────────────────────────────
#                     Laptop-Specific Features
# ─────────────────────────────────────────────────────────────────
# Battery monitoring (only on laptops)
if [ -d "/sys/class/power_supply/BAT0" ] || [ -d "/sys/class/power_supply/BAT1" ]; then
    # Start low battery notifier if not already running
    pgrep -f "low_bat_notifier.sh" > /dev/null || ~/.config/qtile/scripts/low_bat_notifier.sh &
fi

# ─────────────────────────────────────────────────────────────────
#                      Polkit Agent (Optional)
# ─────────────────────────────────────────────────────────────────
# Uncomment if you need polkit authentication dialogs
# /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & disown
