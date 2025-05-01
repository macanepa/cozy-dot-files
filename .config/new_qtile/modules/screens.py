from libqtile import bar
from .widgets import *
from libqtile.config import Screen
from modules.keys import terminal
from libqtile.widget import Mpris2
from .keys import terminal
from .theme import COLORS
import os


screens = [
    Screen(
        top=bar.Bar(
            [
                widget.Sep(padding=6, linewidth=0, background=COLORS.PRIMARY),
                widget.Image(
                    filename="~/.config/qtile/kh.png",
                    margin=2,
                    background=COLORS.PRIMARY,
                    mouse_callbacks={
                        "Button1": lambda: qtile.cmd_spawn(
                            f"rofi -terminal {terminal} -show drun"
                        )
                    },
                ),
                # widget.TextBox(
                #     text="",
                #     padding=0,
                #     fontsize=30,
                #     foreground=COLORS.PRIMARY,
                #     background=COLORS.PRIMARY,
                # ),
                widget.Sep(padding=5, linewidth=0, background=COLORS.PRIMARY),
                widget.GroupBox(
                    fontsize=20,
                    highlight_method="line",
                    this_screen_border="#5294e2",
                    this_current_screen_border="#5294e2",
                    highlight_color=COLORS.PRIMARY_MUTED,
                    active="#ffffff",
                    inactive=COLORS.PRIMARY_DARK,
                    # inactive=COLORS.PRIMARY_MUTED,
                    background=COLORS.PRIMARY,
                ),
                widget.Sep(padding=10, linewidth=0, background=COLORS.PRIMARY),
                # widget.TextBox(text="", padding=0, fontsize=40, foreground=COLORS.PRIMARY),
                widget.TextBox(
                    text="", padding=0, fontsize=30, foreground=COLORS.PRIMARY
                ),
                widget.Spacer(length=10),
                widget.Prompt(fontsize=14, foreground=COLORS.FOREGROUND),
                widget.WindowName(
                    fontsize=14, foreground=COLORS.PRIMARY_LIGHT, fmt="{}"
                ),
                widget.Chord(
                    chords_colors={
                        "launch": ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                # CurrentLayoutIcon
                # widget.TextBox(text = '',padding = 0,fontsize = 50,foreground='#CF94DC',),
                # widget.CurrentLayoutIcon(padding=10, scale=0.75, background='#CF94DC'),
                # widget.TextBox(text = '',padding = 0,fontsize = 50,foreground='#CF94DC',),
                # BTC
                # widget.TextBox(
                #     text="",
                #     padding=0,
                #     fontsize=40,
                #     foreground=BACKGROUND2,
                # ),
                # widget.CryptoTicker(
                #     padding=5,
                #     fontsize=14,
                #     crypto="BTC",
                #     currency="USD",
                #     format="{crypto}: {symbol}{amount:.0f}",
                #     # foreground=BACKGROUND2,
                #     background=COLORS.PRIMARY,
                #     # background=c1,
                # ),
                # widget.TextBox(
                #     text="",
                #     padding=0,
                #     fontsize=40,
                #     foreground=BACKGROUND2,
                # ),
                # # HAI
                # widget.TextBox(
                #     text="",
                #     padding=0,
                #     fontsize=40,
                #     foreground=BACKGROUND2,
                # ),
                # widget.CryptoTicker(
                #     padding=5,
                #     fontsize=14,
                #     crypto="HAI",
                #     currency="USD",
                #     format="{crypto}: {symbol}{amount:.4f}",
                #     # foreground=BACKGROUND2,
                #     background=BACKGROUND2,
                # ),
                # widget.TextBox(
                #     text="",
                #     padding=0,
                #     fontsize=40,
                #     foreground=BACKGROUND2,
                # ),
                # # EGLD
                # widget.TextBox(
                #     text="",
                #     padding=0,
                #     fontsize=40,
                #     foreground=BACKGROUND2,
                # ),
                # widget.CryptoTicker(
                #     padding=5,
                #     fontsize=14,
                #     crypto="EGLD",
                #     currency="USD",
                #     format="{crypto}: {symbol}{amount:.2f}",
                #     # foreground=BACKGROUND2,
                #     background=BACKGROUND2,
                # ),
                # widget.TextBox(
                #     text="",
                #     padding=0,
                #     fontsize=40,
                #     foreground=BACKGROUND2,
                # ),
                # widget.TextBox(text="", padding=0, fontsize=40, foreground=c1),
                widget.Mpris2(
                    format="{xesam:title} - ({xesam:artist})",
                    playing_text=" \ueb2c {track}",
                    paused_text=" ⏸ {track}",
                    width=300,
                    scroll_delay=5,
                    scroll_interval=0.25,
                    scroll_step=15,
                    fontsize=15,
                    padding=18,
                    foreground=COLORS.PRIMARY_LIGHT,
                    # foreground=COLORS.PRIMARY,
                    # font="3270 Nerd Font Mono"
                ),
                # widget.TextBox(
                #     text="",
                #     padding=0,
                #     fontsize=40,
                #     foreground=c1,
                # ),
                # widget.TextBox(
                #     text="",
                #     padding=0,
                #     fontsize=40,
                #     foreground="2f343f",
                # ),
                # widget.CheckUpdates(
                #    background="2f343f",
                #    padding=10,
                #    update_interval=1800,
                #    distro="Arch_yay",
                #    display_format="{updates} Updates",
                #    mouse_callbacks={
                #        "Button1": lambda: qtile.cmd_spawn(terminal + " -e yay -Syu")
                #    },
                # ),
                # widget.TextBox(
                #     text="",
                #     padding=0,
                #     fontsize=40,
                #     foreground="2f343f",
                # ),
                # widget.Spacer(length=5),
                widget.TextBox(
                    text="", padding=0, fontsize=40, foreground=COLORS.PRIMARY
                ),
                widget.Systray(icon_size=18, background=COLORS.PRIMARY),
                # widget.Bluetooth(background="#555555", padding=100, margin=400),
                # volume,
                # widget.TextBox(
                #     text="",
                #     padding=0,
                #     fontsize=40,
                #     foreground=COLORS.PRIMARY,
                # ),
                # widget.TextBox(text="", padding=0, fontsize=40, foreground=COLORS.PRIMARY),
                widget.Spacer(length=5, background=COLORS.PRIMARY),
                widget.KeyboardLayout(
                    configured_keyboards=["us", "es"],
                    padding=10,
                    foreground="#ffffff",
                    background=COLORS.PRIMARY,
                    fontsize=15,
                ),
                widget.Battery(
                    foreground="ffffff",
                    background=COLORS.PRIMARY,
                    fontsize=15,
                    low_foreground="#da3c3c",
                    low_percentage=0.3,
                    format="{percent:2.0%} ",
                    padding=5,
                ),
                widget.Clock(
                    format="󰥔  %Y-%m-%d %a %I:%M",
                    background=COLORS.PRIMARY,
                    foreground="#ffffff",
                    padding=10,
                ),
                widget.TextBox(
                    text="",
                    padding=0,
                    fontsize=40,
                    foreground=COLORS.PRIMARY,
                ),
                widget.TextBox(
                    text="",
                    mouse_callbacks={
                        "Button1": lambda: qtile.cmd_spawn(
                            os.path.expanduser("~/.config/rofi/powermenu.sh")
                        )
                    },
                    foreground=COLORS.PRIMARY_LIGHT,
                    padding=5,
                ),
                widget.Sep(padding=30, linewidth=0),
            ],
            28,  # height in px
            # background=PRIMARY_MUTED  # background color
            background=COLORS.PRIMARY_MUTED,
            # background=COLORS.PRIMARY,
            margin=[0, 0, 10, 0],
            border_width=[0, 0, 0, 0],
            border_color=COLORS.PRIMARY,
        ),
    ),
]
