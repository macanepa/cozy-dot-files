#!/usr/bin/env bash
# Deploy the 'cozy' SDDM login theme.
#   Preview first (no root):  sddm-greeter-qt6 --test-mode --theme <repo>/sddm/cozy
#   Install:                  sudo bash scripts/sddm-deploy.sh
set -u
[ "$(id -u)" -eq 0 ] || { echo "Run as root:  sudo bash $0"; exit 1; }

SRC="$(cd "$(dirname "$0")/.." && pwd)/sddm/cozy"
DEST="/usr/share/sddm/themes/cozy"
[ -f "$SRC/Main.qml" ] || { echo "Theme not found at $SRC"; exit 1; }

echo "Installing theme:  $SRC  ->  $DEST"
rm -rf "$DEST"
mkdir -p "$DEST"
cp -r "$SRC/." "$DEST/"

mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/10-theme.conf <<'EOF'
[Theme]
Current=cozy
EOF

echo "Done. The new login screen applies on your next logout / reboot."
echo "Preview it now (opens a window):"
echo "    sddm-greeter-qt6 --test-mode --theme $DEST"
echo "To revert: delete /etc/sddm.conf.d/10-theme.conf"
