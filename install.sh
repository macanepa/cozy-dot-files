#!/bin/env bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Introduction & Warning
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║               Welcome to the Cozytile Setup!                  ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
sleep 2

print_warning "Some parts of the script require sudo. If you're planning on leaving the desktop while the installation script runs, better enter your password now!"
sleep 3

# Detect system type (laptop vs desktop)
detect_system_type() {
    if [ -d "/sys/class/power_supply/BAT0" ] || [ -d "/sys/class/power_supply/BAT1" ]; then
        echo "laptop"
    else
        echo "desktop"
    fi
}

# Detect CPU vendor
detect_cpu_vendor() {
    if grep -q "AMD" /proc/cpuinfo; then
        echo "amd"
    elif grep -q "Intel" /proc/cpuinfo; then
        echo "intel"
    else
        echo "unknown"
    fi
}

SYSTEM_TYPE=$(detect_system_type)
CPU_VENDOR=$(detect_cpu_vendor)

print_info "Detected system type: ${SYSTEM_TYPE^^}"
print_info "Detected CPU vendor: ${CPU_VENDOR^^}"
sleep 2

# System update 
print_info "Performing a full system update..."
sudo pacman --noconfirm -Syu
clear
print_success "System update complete"
sleep 2
clear

# Install Git if not present 
print_info "Installing git and base-devel..."
sudo pacman -S --noconfirm --needed git base-devel
clear

# Clone and install yay if not installed
print_info "Checking for AUR helper..."
if ! command -v yay &> /dev/null; then
    print_info "Installing yay, an AUR helper..."
    mkdir -p ~/.srcs
    if git clone https://aur.archlinux.org/yay.git ~/.srcs/yay; then
        (cd ~/.srcs/yay && makepkg -si --noconfirm)
        print_success "yay installed successfully"
    else
        print_error "Failed to clone yay repository"
        exit 1
    fi
else
    print_success "yay is already installed"
fi
clear

# Install CPU microcode based on detection
print_info "Installing CPU microcode..."
case $CPU_VENDOR in
    amd)
        sudo pacman -S --noconfirm --needed amd-ucode
        print_success "AMD microcode installed"
        ;;
    intel)
        sudo pacman -S --noconfirm --needed intel-ucode
        print_success "Intel microcode installed"
        ;;
    *)
        print_warning "Unknown CPU vendor, skipping microcode installation"
        ;;
esac
clear

# Install base-devel and required packages
print_info "Installing dependencies..."
yay -S --noconfirm --needed qtile python-psutil pywal-git picom dunst zsh starship mpd ncmpcpp playerctl brightnessctl alacritty pfetch htop flameshot thunar roficlip rofi ranger neovim vim feh sddm rofi-greenclip
sudo pacman -S --noconfirm --needed git github-cli vim ranger picom dunst rofi flameshot feh arandr thunar thunar-archive-plugin engrampa lxappearance playerctl tmux rclone fuse3 man virt-viewer xorg-xkill btop network-manager-applet blueman
sudo pacman -S --noconfirm --needed python-mpris2 python-dbus-next python-dbus-fast
clear

# Install laptop-specific packages if detected
if [ "$SYSTEM_TYPE" = "laptop" ]; then
    print_info "Laptop detected! Installing power management tools..."
    sudo pacman -S --noconfirm --needed brightnessctl tlp tlp-rdw acpi acpi_call
    sudo systemctl enable tlp.service
    sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
    print_success "Power management tools installed and enabled"
    
    # Install touchpad configuration
    print_info "Configuring touchpad settings..."
    sudo mkdir -p /etc/X11/xorg.conf.d/
    sudo cp ./scripts/notebook/40-libinput.conf /etc/X11/xorg.conf.d/40-libinput.conf
    print_success "Touchpad configured"
fi
clear

# Backup and install configuration files 
print_info "Backing up and installing configuration files..."
sleep 2

# Install fonts
mkdir -p ~/.local/share/fonts 
cp -r ./fonts/* ~/.local/share/fonts/
fc-cache -f
print_success "Fonts installed"

# Create or rename .backup directory
backup_dir="$HOME/.backup"
if [ -d "$backup_dir" ]; then
    print_warning "$backup_dir already exists. Renaming existing backup directory..."
    i=1
    while [ -d "$backup_dir.old.$i" ]; do
        i=$((i + 1))
    done
    mv "$backup_dir" "$backup_dir.old.$i"
fi
mkdir -p "$backup_dir"

backup_and_install() {
    local folder="$1"
    local src_path="$2"

    if [ -d ~/$folder ]; then
        print_info "$folder configs detected, backing up..."
        mkdir -p ~/.backup/$folder
        mv ~/$folder/* ~/.backup/$folder/ 2>/dev/null || true
    fi
    mkdir -p ~/$folder
    cp -r $src_path/* ~/$folder/
}

backup_install_file() {
    local file="$1"
    local src_path="$2"

    if [ -f ~/$file ]; then
        print_info "$file detected, backing up..."
        mkdir -p ~/.backup/$(dirname "$file")
        mv ~/$file ~/.backup/$(dirname "$file")/ 2>/dev/null || true
    fi
    cp $src_path ~/$file
}

# Backing up & installing
backup_and_install ".config/rofi" "./.config/rofi"
backup_and_install ".config/dunst" "./.config/dunst"
backup_and_install ".config/alacritty" "./.config/alacritty"
backup_and_install ".config/picom" "./.config/picom"
backup_and_install ".config/qtile" "./.config/qtile"
backup_and_install "Wallpaper" "./Wallpaper"
backup_and_install "Themes" "./Themes"
backup_install_file ".config/starship.toml" "./.config/starship.toml"
print_success "Configuration files installed"
sleep 2
clear

# Choose video driver
echo ""
echo -e "${BLUE}Select your GPU driver:${NC}"
echo "1) Intel (xf86-video-intel)"
echo "2) AMD (xf86-video-amdgpu)"
echo "3) NVIDIA Open (nvidia-open) - Recommended for newer cards (RTX 20+)"
echo "4) NVIDIA Proprietary (nvidia) - Recommended for GTX 10 series and older"
echo "5) NVIDIA DKMS (nvidia-dkms) - For custom kernels"
echo "6) Skip GPU driver installation"
echo ""
read -r -p "Choose your video card driver (default 1): " vid

case $vid in
    1) DRI='xf86-video-intel';;
    2) DRI='xf86-video-amdgpu vulkan-radeon';;
    3) DRI='nvidia-open nvidia-settings nvidia-utils';;
    4) DRI='nvidia nvidia-settings nvidia-utils';;
    5) DRI='nvidia-dkms nvidia-settings nvidia-utils';;
    6) DRI="";;
    *) DRI='xf86-video-intel';;
esac

if [ -n "$DRI" ]; then
    sudo pacman -S --noconfirm --needed xorg xorg-xinit $DRI
    print_success "GPU driver installed: $DRI"
else
    sudo pacman -S --noconfirm --needed xorg xorg-xinit
    print_info "Skipped GPU driver installation"
fi
clear

# Set Zsh as the default shell 
print_info "Setting Zsh as the default shell..."
chsh -s $(which zsh)
clear

# Install Oh My Zsh and plugins
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_warning "Removing existing Oh My Zsh installation..."
    rm -rf ~/.oh-my-zsh
fi

print_info "Installing Oh My Zsh and plugins..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install plugins with error handling
if git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null; then
    print_success "zsh-autosuggestions installed"
else
    print_warning "zsh-autosuggestions may already exist"
fi

if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null; then
    print_success "zsh-syntax-highlighting installed"
else
    print_warning "zsh-syntax-highlighting may already exist"
fi

cp -R .zshrc ~/
print_success "Shell configuration complete"
clear

# Enable SDDM 
print_info "Enabling SDDM to start on boot..."
sudo systemctl enable sddm
clear

# Pre-generate pywal colors
print_info "Pre-generating pywal colors..."
echo "This might take some time, hang on tight!"

wal -b 282738 -i ~/Wallpaper/Aesthetic2.png > /dev/null 2>&1
print_success "Theme 1 done"

wal -b 282738 -i ~/Wallpaper/120_-_KnFPX73.jpg > /dev/null 2>&1
print_success "Theme 2 done"

wal -i ~/Wallpaper/claudio-testa-FrlCwXwbwkk-unsplash.jpg > /dev/null 2>&1
print_success "Theme 3 done"

wal -b 232A2E -i ~/Wallpaper/fog_forest_2.png > /dev/null 2>&1 
print_success "Theme 4 done"

# Final summary
echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                  Installation Complete! 🎉                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
print_info "System type: ${SYSTEM_TYPE^^}"
print_info "CPU vendor: ${CPU_VENDOR^^}"
[ -n "$DRI" ] && print_info "GPU driver: $DRI"
echo ""
print_warning "Please reboot your system and select 'Qtile' (NOT 'Qtile Wayland') from SDDM"
echo ""

read -r -p "Would you like to reboot now? (y/N): " reboot_choice
case $reboot_choice in
    [yY]|[yY][eE][sS])
        print_info "Rebooting in 3 seconds..."
        sleep 3
        sudo reboot
        ;;
    *)
        print_info "You can reboot manually when ready with: sudo reboot"
        ;;
esac
