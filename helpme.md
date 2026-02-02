
# ───────────────────────────────────────────────────────────────#
#                     Troubleshooting Guide                      #
# ───────────────────────────────────────────────────────────────#

If you've encountered an issue during the setup process, please refer to the following common errors and their solutions.

# ───────────────────────────────────────────────────────────────#
#                     Common Errors & Fixes                      #
# ───────────────────────────────────────────────────────────────#

## Error 1: Paru/Yay fails due to missing libalpm.so.14

**ERROR:**
```
paru: error while loading shared libraries: libalpm.so.14: cannot open shared object file: No such file or directory
```

**FIX:**
Create a symbolic link to the newer version of the library:
```sh
sudo ln -s /usr/lib/libalpm.so.15.0.0 /usr/lib/libalpm.so.14
```

---

## Error 2: Black screen after logging in with SDDM

**CAUSE:**
Qtile Wayland is selected by default, which may not work with your GPU.

**FIX:**
In the SDDM login screen, click the session selector (usually top-left corner) and choose **"Qtile"** or **"Qtile (Xorg)"** instead of "Qtile Wayland".

---

## Error 3: Screen tearing with NVIDIA GPU

**FIX Option 1:** The picom config should already handle this with `vsync = true`.

**FIX Option 2:** Force full composition pipeline:
```sh
nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"
```

**FIX Option 3:** Add to `/etc/X11/xorg.conf.d/20-nvidia.conf`:
```
Section "Screen"
    Identifier "Screen0"
    Option "metamodes" "nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"
EndSection
```

---

## Error 4: Brightness keys not working (Laptop)

**CAUSE:** User not in video group or brightnessctl not installed.

**FIX:**
```sh
sudo pacman -S brightnessctl
sudo usermod -aG video $USER
```
Log out and log back in for changes to take effect.

---

## Error 5: Battery widget shows "No Battery"

**CAUSE:** The battery path may differ between systems.

**FIX:**
Check your battery path:
```sh
ls /sys/class/power_supply/
```
The scripts now auto-detect BAT0 or BAT1, but if you have a different name, you may need to adjust the scripts.

---

## Error 6: Picom crashes or causes stuttering

**FIX Option 1:** Try a different picom backend. Edit `~/.config/picom/picom.conf`:
```conf
# Change from glx to xrender
backend = "xrender";
```

**FIX Option 2:** Disable animations:
Edit the animations section in picom.conf or comment it out.

**FIX Option 3:** For AMD GPUs, ensure you have the right drivers:
```sh
sudo pacman -S mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon
```

---

## Error 7: Oh My Zsh plugins not working

**CAUSE:** Plugins may not be properly listed in .zshrc

**FIX:**
Ensure your `.zshrc` has:
```sh
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
```

Then reload:
```sh
source ~/.zshrc
```

---

## Error 8: Rofi not showing or crashing

**FIX:**
Regenerate rofi config:
```sh
rofi -show drun
```
If it still fails, check the theme path in rofi config files under `~/.config/rofi/`.

---

## Error 9: OneDrive not mounting

**CAUSE:** rclone not configured or OneDrive remote not set up.

**FIX:**
```sh
rclone config
# Follow the prompts to set up OneDrive
# Name it "OneDrive" (case-sensitive)
```

---

## Error 10: Audio/Volume keys not working

**FIX:**
Ensure PulseAudio or PipeWire is running:
```sh
# For PulseAudio
pulseaudio --start

# For PipeWire
systemctl --user start pipewire pipewire-pulse
```

---

# ───────────────────────────────────────────────────────────────#
#                    Hardware-Specific Issues                    #
# ───────────────────────────────────────────────────────────────#

## AMD GPU: Flickering or artifacts

```sh
# Install all AMD drivers
sudo pacman -S mesa lib32-mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon

# Add to kernel parameters (in /etc/default/grub):
# amdgpu.dc=1
```

## Intel GPU: Poor performance

For newer Intel GPUs (Gen 8+), the modesetting driver may perform better:
```sh
sudo pacman -R xf86-video-intel
# The kernel modesetting driver will be used automatically
```

## NVIDIA: Wrong driver installed

Check your GPU generation and switch:
```sh
# For GTX 900/1000 series
sudo pacman -S nvidia nvidia-utils

# For RTX 20+ series
sudo pacman -S nvidia-open nvidia-utils

# For custom kernels
sudo pacman -S nvidia-dkms nvidia-utils
```

---

# ───────────────────────────────────────────────────────────────#
#                              Note                              #
# ───────────────────────────────────────────────────────────────#

If you encounter an error that isn't listed here, please open an issue at the GitHub repository. Even if you know the fix, it would be great if you let us know to help others!
Thank you!!
