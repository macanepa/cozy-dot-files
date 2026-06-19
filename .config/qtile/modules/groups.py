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
    screen_width_px=1920,
    screen_height_px=1080,
):
    width_frac = term_width_px / screen_width_px
    height_frac = term_height_px / screen_height_px
    x_frac = (screen_width_px - term_width_px - margin_right_px) / screen_width_px
    y_frac = margin_top_px / screen_height_px
    return {
        "width": round(width_frac, 3),
        "height": round(height_frac, 3),
        "x": round(x_frac, 3),
        "y": round(y_frac, 3),
    }


geom = dropdown_geometry(
    term_width_px=600, term_height_px=800, margin_top_px=0, margin_right_px=58
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
                **geom
            ),
            DropDown(
                "calendar",
                "alacritty -e calcurse",
                opacity=1,
                on_focus_lost_hide=True,
                **geom
            ),
            DropDown(
                "bluetooth",
                "blueman-manager",
                opacity=1,
                on_focus_lost_hide=True,
                **dropdown_geometry(
                    term_width_px=600,
                    term_height_px=800,
                    margin_top_px=0,
                    margin_right_px=58,
                )
            ),
            DropDown(
                "sound",
                "pavucontrol",
                opacity=1,
                on_focus_lost_hide=True,
                **dropdown_geometry(
                    term_width_px=400,
                    term_height_px=600,
                    margin_top_px=0,
                    margin_right_px=58,
                )
            ),
        ],
    )
]
