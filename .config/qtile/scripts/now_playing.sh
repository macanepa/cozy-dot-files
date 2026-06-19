#!/bin/bash
# Now-Playing: a dunst popup on every track change, for any MPRIS player
# (Spotify, mpv, browsers...). Launched once from autostart_once.sh.
# Downloads album art when the player exposes it.

art_cache="/tmp/nowplaying-art"

playerctl --follow --format $'{{title}}\t{{artist}}\t{{album}}\t{{mpris:artUrl}}' metadata 2>/dev/null |
while IFS=$'\t' read -r title artist album art; do
    [ -z "$title" ] && continue

    icon="audio-x-generic"
    case "$art" in
        file://*) icon="${art#file://}" ;;
        http*)    curl -sfL --max-time 4 "$art" -o "$art_cache" 2>/dev/null && icon="$art_cache" ;;
    esac

    sub="$artist"
    [ -n "$album" ] && sub="$artist  ·  $album"

    # -r 24242 reuses the same notification id so it replaces (doesn't stack)
    notify-send -r 24242 -a "Now Playing" -i "$icon" "$title" "$sub"
done
