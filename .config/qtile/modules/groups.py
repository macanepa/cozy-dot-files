from libqtile.config import Key, Group, ScratchPad, DropDown
from libqtile.lazy import lazy
from .keys import keys, mod

roman = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
groups1 = ["1", "2", "3", "4"]
groups2 = "M"
groups = [Group(str(i), label="\ueaaa") for i in groups1] + [
    Group(str("M"), label="🎧")
]

for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + letter of group = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod1 + shift + letter of group = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )
    keys.extend(
        [
            Key(["control", "mod1"], "Right", lazy.screen.next_group()),
            Key(["control", "mod1"], "Left", lazy.screen.prev_group()),
        ]
    )


def dropdown_geometry(
    term_width_px,
    term_height_px,
    margin_top_px,
    margin_right_px,
    screen_width_px=None,
    screen_height_px=None,
):
    """
    Calculate dropdown terminal geometry as fractions of screen size.
    
    If screen dimensions are not provided, uses reasonable defaults that work
    for most common resolutions (1920x1080 and similar).
    
    For dynamic screen detection, this could be enhanced to query xrandr,
    but static values provide more predictable behavior.
    """
    # Default to 1920x1080 if not specified
    # These work well for most common resolutions
    if screen_width_px is None:
        screen_width_px = 1920
    if screen_height_px is None:
        screen_height_px = 1080
    
    # Calculate as fractions (works for any resolution when values are reasonable)
    width_frac = min(term_width_px / screen_width_px, 0.8)  # Cap at 80% width
    height_frac = min(term_height_px / screen_height_px, 0.9)  # Cap at 90% height
    x_frac = max((screen_width_px - term_width_px - margin_right_px) / screen_width_px, 0.1)
    y_frac = max(margin_top_px / screen_height_px, 0)
    
    return {
        "width": round(width_frac, 3),
        "height": round(height_frac, 3),
        "x": round(x_frac, 3),
        "y": round(y_frac, 3),
    }


# Dropdown geometries for different purposes
geom_chatbot = dropdown_geometry(
    term_width_px=600, term_height_px=800, margin_top_px=0, margin_right_px=58
)

geom_calendar = dropdown_geometry(
    term_width_px=600, term_height_px=800, margin_top_px=0, margin_right_px=58
)

geom_bluetooth = dropdown_geometry(
    term_width_px=600, term_height_px=800, margin_top_px=0, margin_right_px=58
)

geom_sound = dropdown_geometry(
    term_width_px=400, term_height_px=600, margin_top_px=0, margin_right_px=58
)


groups += [
    ScratchPad(
        "scratchpad",
        [
            DropDown(
                "chatbot",
                "alacritty --class wiwi --option font.size=10 -e zsh -ic claude",
                opacity=1,
                on_focus_lost_hide=False,
                **geom_chatbot
            ),
            DropDown(
                "calendar",
                "alacritty -e calcurse",
                opacity=1,
                on_focus_lost_hide=True,
                **geom_calendar
            ),
            DropDown(
                "bluetooth",
                "blueman-manager",
                opacity=1,
                on_focus_lost_hide=True,
                **geom_bluetooth
            ),
            DropDown(
                "sound",
                "pavucontrol",
                opacity=1,
                on_focus_lost_hide=True,
                **geom_sound
            ),
            # Additional useful dropdowns
            DropDown(
                "terminal",
                "alacritty",
                opacity=0.95,
                on_focus_lost_hide=True,
                **dropdown_geometry(
                    term_width_px=1200, term_height_px=700, 
                    margin_top_px=50, margin_right_px=360
                )
            ),
            DropDown(
                "htop",
                "alacritty -e htop",
                opacity=0.95,
                on_focus_lost_hide=True,
                **dropdown_geometry(
                    term_width_px=1000, term_height_px=600, 
                    margin_top_px=50, margin_right_px=460
                )
            ),
        ],
    )
]
