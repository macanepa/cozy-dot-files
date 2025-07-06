from libqtile.lazy import lazy
from libqtile.config import Key
from .functions import toggle_dropdown_ai
import os

mod = "mod4"
terminal = "alacritty"

config_dir = os.path.dirname(__file__)
script_path = os.path.abspath(os.path.join(config_dir, "../scripts/change_volume.sh"))

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    # Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    Key(
        [mod],
        "i",
        lazy.widget["keyboardlayout"].next_keyboard(),
        desc="Next keyboard layout",
    ),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key(
        [mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key(
        [mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"
    ),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "Escape", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key(
        [mod], "p", lazy.spawn(f"rofi -terminal {terminal} -show drun"), desc="Run Rofi"
    ),
    Key(
        [mod],
        "v",
        lazy.spawn(
            f"rofi -modi 'clipboard:greenclip print' -show clipboard -run-command '{{cmd}}'"
        ),
        desc="Run Rofi",
    ),
    Key([mod, "shift"], "s", lazy.spawn("flameshot gui"), desc="Take Screenshot"),
    Key([mod], "t", lazy.window.toggle_floating()),
    # Sound
    # Alsa Mixer
    # Key([], "XF86AudioLowerVolume", lazy.spawn("amixer sset Master,0 5%-")),
    # Key([], "XF86AudioRaiseVolume", lazy.spawn("amixer sset Master,0 5%+")),
    # Key([], "XF86AudioMute", lazy.spawn("amixer sset Master,0 toggle")),
    # Pulse Audio
    Key([], "XF86AudioLowerVolume", lazy.spawn(f"{script_path} -5%")),
    Key([], "XF86AudioRaiseVolume", lazy.spawn(f"{script_path} +5%")),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute 0 toggle")),
    # Music
    Key([mod], "Left", lazy.spawn("playerctl previous")),
    Key([mod], "Right", lazy.spawn("playerctl next")),
    Key([mod], "Space", lazy.spawn("playerctl play-pause")),
    # Key([], "XF86AudioPrev", lazy.spawn("playerctl previous")),
    # Key([], "XF86AudioNext", lazy.spawn("playerctl next")),
    # Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause")),
    # Key([mod, 'control'], "Right", lazy.screen.next_group()),
    # Key([mod, 'control'], "Left", lazy.screen.prev_group()),
    # Brightness
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +10%")),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 10%-")),
    Key([mod], "n", lazy.next_screen(), desc="Move focus to next screen"),
    # wiwi
    Key([mod], "o", toggle_dropdown_ai),
    Key([mod], "e", lazy.spawn("thunar")),
    Key([mod], "b", lazy.spawn("brave"))
]
