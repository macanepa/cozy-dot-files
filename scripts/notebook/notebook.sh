#!/bin/bash
# Notebook-specific setup script
# Run this if the main installer didn't detect your laptop correctly

set -e

echo "Installing laptop-specific packages..."

# Power management
sudo pacman -S --noconfirm --needed brightnessctl tlp tlp-rdw acpi acpi_call

# Enable TLP for power management
echo "Enabling TLP service..."
sudo systemctl enable tlp.service
sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
sudo systemctl start tlp.service

# Touchpad configuration
echo "Configuring touchpad..."
if [ -f "./40-libinput.conf" ]; then
    sudo mkdir -p /etc/X11/xorg.conf.d/
    sudo cp ./40-libinput.conf /etc/X11/xorg.conf.d/40-libinput.conf
    echo "Touchpad configuration installed"
else
    echo "Warning: 40-libinput.conf not found in current directory"
    echo "Please copy it manually from scripts/notebook/"
fi

echo ""
echo "Laptop setup complete!"
echo "You may need to log out and back in for all changes to take effect."
