#!/usr/bin/env bash
# Install the performance-mode helper + a tight sudoers rule so the qtile bar
# widget can switch the AMD platform_profile without a password prompt.
#   Run with:  sudo bash scripts/power-mode-setup.sh
set -u
[ "$(id -u)" -eq 0 ] || { echo "Run as root:  sudo bash $0"; exit 1; }

SRC="$(cd "$(dirname "$0")" && pwd)"
USER_NAME="${SUDO_USER:-macanepa}"

# 1) install the root-owned helper (NOT user-writable, so the sudoers rule is safe)
install -o root -g root -m 0755 "$SRC/power-profile" /usr/local/bin/power-profile
echo "installed /usr/local/bin/power-profile"

# 2) tight sudoers rule: only the 3 exact commands, no wildcard
SUDO=/etc/sudoers.d/10-power-profile
cat > "$SUDO" <<EOF
$USER_NAME ALL=(root) NOPASSWD: /usr/local/bin/power-profile set low-power, /usr/local/bin/power-profile set balanced, /usr/local/bin/power-profile set performance
EOF
chmod 0440 "$SUDO"

# 3) validate (an invalid sudoers file can break sudo — so verify, and roll back if bad)
if visudo -c -f "$SUDO" >/dev/null; then
    echo "sudoers rule OK -> $SUDO"
else
    echo "sudoers rule INVALID, removing"; rm -f "$SUDO"; exit 1
fi

echo "Done. The bar power-mode widget can now switch modes (click it)."
