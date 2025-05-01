sudo pacman -S git github-cli vim ranger picom dunst rofi flameshot feh arandr thunar thunar-archive-plugin engrampa lxappearance gnome-keyring playerctl tmux rclone fuse3 man virt-viewer cameractrls xorg-xkill btop --noconfirm  --needed

sudo pacman -S python-mpris2 python-dbus-next python-dbus-fast --noconfirm --needed


if ! test -f ~/.config/rclone/rclone.conf; then
	mkdir -p ~/OneDrive
	rclone config
fi
