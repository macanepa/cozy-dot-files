from libqtile.lazy import lazy
from libqtile.config import Key
from .functions import (
    toggle_dropdown_ai,
    toggle_dropdown_terminal,
    toggle_dropdown_htop,
)
import os
import shutil

mod = "mod4"
terminal = "alacritty"

# Browser launched by mod+b: first available in order of preference
# (brave > firefox > chrome). Resolved at config load via shutil.which.
browser = next(
    (b for b in ("brave", "firefox", "google-chrome-stable", "google-chrome") if shutil.which(b)),
    "brave",
)

config_dir = os.path.dirname(__file__)
script_path = os.path.abspath(os.path.join(config_dir, "../scripts/change_volume.sh"))

keys = [
    # ─────────────────────────────────────────────────────────────
    #                    Window Focus Navigation
    # ─────────────────────────────────────────────────────────────
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    
    # ─────────────────────────────────────────────────────────────
    #                    Window Movement
    # ─────────────────────────────────────────────────────────────
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    
    # ─────────────────────────────────────────────────────────────
    #                    Window Resizing
    # ─────────────────────────────────────────────────────────────
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    
    # ─────────────────────────────────────────────────────────────
    #                    Layout Control
    # ─────────────────────────────────────────────────────────────
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(), 
        desc="Toggle between split and unsplit sides of stack"),
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating"),
    
    # ─────────────────────────────────────────────────────────────
    #                    Qtile Control
    # ─────────────────────────────────────────────────────────────
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "Escape", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    
    # ─────────────────────────────────────────────────────────────
    #                    Applications
    # ─────────────────────────────────────────────────────────────
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "p", lazy.spawn(f"rofi -terminal {terminal} -show drun"), desc="Run Rofi launcher"),
    Key([mod], "v", lazy.spawn(
        "rofi -modi 'clipboard:greenclip print' -show clipboard -run-command '{cmd}'"
    ), desc="Run Rofi clipboard"),
    Key([mod, "shift"], "s", lazy.spawn("flameshot gui"), desc="Take Screenshot"),
    Key([mod], "e", lazy.spawn("thunar"), desc="Open file manager"),
    Key([mod], "b", lazy.spawn(browser), desc="Open browser"),
    
    # ─────────────────────────────────────────────────────────────
    #                    Dropdown Terminals
    # ─────────────────────────────────────────────────────────────
    Key([mod], "o", toggle_dropdown_ai, desc="Toggle AI chatbot dropdown"),
    Key([mod], "grave", toggle_dropdown_terminal, desc="Toggle dropdown terminal"),  # grave = `
    Key([mod, "shift"], "Escape", toggle_dropdown_htop, desc="Toggle htop dropdown"),
    
    # ─────────────────────────────────────────────────────────────
    #                    Keyboard Layout
    # ─────────────────────────────────────────────────────────────
    Key([mod], "i", lazy.widget["keyboardlayout"].next_keyboard(), 
        desc="Next keyboard layout"),
    
    # ─────────────────────────────────────────────────────────────
    #                    Audio Control
    # ─────────────────────────────────────────────────────────────
    Key([], "XF86AudioLowerVolume", lazy.spawn(f"{script_path} -5%"), desc="Volume down"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn(f"{script_path} +5%"), desc="Volume up"),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"), desc="Mute toggle"),
    
    # ─────────────────────────────────────────────────────────────
    #                    Media Control
    # ─────────────────────────────────────────────────────────────
    Key([mod], "Left", lazy.spawn("playerctl previous"), desc="Previous track"),
    Key([mod], "Right", lazy.spawn("playerctl next"), desc="Next track"),
    Key([mod], "Space", lazy.spawn("playerctl play-pause"), desc="Play/Pause"),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous"), desc="Previous track"),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next"), desc="Next track"),
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause"), desc="Play/Pause"),
    
    # ─────────────────────────────────────────────────────────────
    #                    Brightness Control (Laptop)
    # ─────────────────────────────────────────────────────────────
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +10%"), desc="Brightness up"),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 10%-"), desc="Brightness down"),
    
    # ─────────────────────────────────────────────────────────────
    #                    Multi-Monitor
    # ─────────────────────────────────────────────────────────────
    Key([mod], "period", lazy.next_screen(), desc="Move focus to next screen"),
    Key([mod], "comma", lazy.prev_screen(), desc="Move focus to previous screen"),
    Key([mod, "shift"], "period", lazy.function(lambda q: q.current_window.toscreen(1) if len(q.screens) > 1 else None),
        desc="Move window to next screen"),
]
