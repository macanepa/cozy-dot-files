#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  icons-setup.sh — one-time setup for theme-aware icons.
#
#  Installs the Papirus icon set USER-LOCAL (~/.local/share/icons) plus the
#  papirus-folders tool, so the theme system can recolour the folder icons to
#  match the active palette on every `mod+shift+t` — WITHOUT root (no sudo, no
#  AUR). User-local install is required so papirus-folders can write the folder
#  symlinks. ~100 MB download, run once.
#
#  After this, modules/app_theme.py:theme_icons() takes over automatically.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

ICONS="$HOME/.local/share/icons"
SCRIPTS="$HOME/.config/qtile/scripts"
mkdir -p "$ICONS" "$SCRIPTS"

echo ":: Installing Papirus icon theme (user-local, no sudo)…"
if ! command -v curl >/dev/null; then echo "need curl"; exit 1; fi
# Official installer; DESTDIR puts it under ~/.local/share/icons (Papirus,
# Papirus-Dark, Papirus-Light).
DESTDIR="$ICONS" sh -c \
  "$(curl -fsSL https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh)"

echo ":: Installing papirus-folders…"
curl -fsSL \
  https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/papirus-folders \
  -o "$SCRIPTS/papirus-folders"
chmod +x "$SCRIPTS/papirus-folders"

echo ":: Done. Papirus-Dark installed. Switch theme with mod+shift+t — the"
echo "   folders will recolour to match (orange for naranjo, blue for ocean, …)."
