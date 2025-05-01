yay -S spicetify-cli --noconfirm
git clone https://github.com/spicetify/spicetify-themes.git ~/.config/spicetify/Themes --depth=1
spicetify config current_theme Sleek
spicetify config color_scheme Coral
spicetify backup apply
spicetify apply
