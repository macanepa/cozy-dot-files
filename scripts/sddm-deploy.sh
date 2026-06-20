#!/usr/bin/env bash
# Deploy the 'cozy' SDDM login theme.
#   Preview first (no root):  sddm-greeter-qt6 --test-mode --theme <repo>/sddm/cozy
#   Install:                  sudo bash scripts/sddm-deploy.sh
set -u
[ "$(id -u)" -eq 0 ] || { echo "Run as root:  sudo bash $0"; exit 1; }

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO/sddm/cozy"
DEST="/usr/share/sddm/themes/cozy"
[ -f "$SRC/Main.qml" ] || { echo "Theme not found at $SRC"; exit 1; }

echo "Installing theme:  $SRC  ->  $DEST"
rm -rf "$DEST"
mkdir -p "$DEST"
cp -r "$SRC/." "$DEST/"

# Install the Nerd Font SYSTEM-WIDE. The greeter runs as the unprivileged `sddm`
# user and cannot read fonts under your $HOME (mode 700), so the clock/glyphs
# (fingerprint, lock, power icons) would otherwise fall back to tofu boxes.
FONT_SRC="$REPO/fonts/jet"
FONT_DEST="/usr/local/share/fonts/jetbrains-mono-nerd"
if ls "$FONT_SRC"/*.ttf >/dev/null 2>&1; then
    echo "Installing JetBrainsMono Nerd Font system-wide -> $FONT_DEST"
    mkdir -p "$FONT_DEST"
    cp "$FONT_SRC"/*.ttf "$FONT_DEST/"
    fc-cache -f "$FONT_DEST" >/dev/null 2>&1 || fc-cache -f >/dev/null 2>&1
else
    echo "! No TTFs in $FONT_SRC — install a Nerd Font system-wide (e.g. pacman -S ttf-jetbrains-mono-nerd) or the glyphs will be missing."
fi

mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/10-theme.conf <<'EOF'
[Theme]
Current=cozy
EOF

echo "Done. The new login screen applies on your next logout / reboot."
echo "Preview it now (opens a window):"
echo "    sddm-greeter-qt6 --test-mode --theme $DEST"
echo "To revert: delete /etc/sddm.conf.d/10-theme.conf"
