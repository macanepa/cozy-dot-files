#!/bin/bash
# Additional utilities installation script
# Run this to install extra tools not included in the main installer

set -e

echo "Installing additional utilities..."

# Core utilities
sudo pacman -S --noconfirm --needed \
    git \
    github-cli \
    vim \
    ranger \
    picom \
    dunst \
    rofi \
    flameshot \
    feh \
    arandr \
    thunar \
    thunar-archive-plugin \
    engrampa \
    lxappearance \
    playerctl \
    tmux \
    rclone \
    fuse3 \
    man \
    virt-viewer \
    xorg-xkill \
    btop \
    ripgrep \
    fastfetch \
    cmatrix \
    nmap \
    img2pdf \
    nano \
    wget

# Python dependencies for Qtile widgets
sudo pacman -S --noconfirm --needed \
    python-mpris2 \
    python-dbus-next \
    python-dbus-fast

# AUR extras: clipboard manager + terminal markdown viewer (requires yay from install.sh)
if command -v yay &> /dev/null; then
    yay -S --noconfirm --needed clipster mdcat
else
    echo "yay not found, skipping AUR extras (clipster, mdcat)"
fi

# Camera controls (if you have a webcam)
if lsusb | grep -qi "camera\|webcam"; then
    echo "Webcam detected, installing camera controls..."
    sudo pacman -S --noconfirm --needed cameractrls 2>/dev/null || echo "cameractrls not found in repos"
fi

# Setup rclone for cloud storage (optional)
if ! test -f ~/.config/rclone/rclone.conf; then
    echo ""
    read -p "Would you like to configure rclone for cloud storage? (y/N): " setup_rclone
    if [[ "$setup_rclone" =~ ^[yY] ]]; then
        mkdir -p ~/OneDrive
        rclone config
    fi
fi

echo ""
echo "Additional utilities installed successfully!"
