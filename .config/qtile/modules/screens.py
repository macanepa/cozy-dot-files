from libqtile import bar
from .widgets import *
from libqtile.config import Screen
from modules.keys import terminal
from libqtile.widget import Mpris2
from .keys import terminal
from .theme import COLORS, BASE
import os




screens = [

    Screen(
        top=bar.Bar(
            [
                widget.Spacer(length=15,
                    background=BASE.BACKGROUND,
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/launch_Icon.png',
                    margin=2,
                    background=BASE.BACKGROUND,
                    # mouse_callbacks={"Button1": power},
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/6.png',
                ),

                widget.GroupBox(
                    font="JetBrainsMono Nerd Font",
                    fontsize=23,
                    borderwidth=3,
                    highlight_method='block',
                    active=BASE.FOREGROUND,
                    block_highlight_text_color=BASE.BLOCK_TEXT_HIGHLIGHT,
                    highlight_color=BASE.HIGHLIGHT,
                    inactive=BASE.BACKGROUND,
                    foreground=BASE.HIGHLIGHT,
                    background=BASE.BACKGROUND2,
                    this_current_screen_border=BASE.BACKGROUND2,
                    this_screen_border=BASE.BACKGROUND2,
                    other_current_screen_border=BASE.BACKGROUND2,
                    other_screen_border=BASE.BACKGROUND2,
                    urgent_border=BASE.BACKGROUND2,
                    rounded=True,
                    disable_drag=True,
                ),

                widget.Spacer(
                    length=8,
                    background=BASE.BACKGROUND2,
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/1.png',
                ),

                widget.CurrentLayoutIcon(
                    custom_icon_paths=["~/.config/qtile/Assets/layout"],
                    background=BASE.BACKGROUND2,
                    scale=0.50,
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/5.png',
                ),

                widget.TextBox(
                    text=" ",
                    font="Font Awesome 6 Free Solid",
                    fontsize=13,
                    background=BASE.BACKGROUND,
                    foreground=BASE.FOREGROUND,
                    # mouse_callbacks={"Button1": search},
                ),

                widget.TextBox(
                    fmt='Search',
                    background=BASE.BACKGROUND,
                    font="JetBrainsMono Nerd Font Bold",
                    fontsize=13,
                    foreground=BASE.FOREGROUND,
                    # mouse_callbacks={"Button1": search},
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/4.png',
                ),

                widget.WindowName(
                    background=BASE.BACKGROUND2,
                    font="JetBrainsMono Nerd Font Bold",
                    fontsize=12,
                    empty_group_string="Desktop",
                    max_chars=130,
                    foreground=BASE.FOREGROUND,
                ),

                # widget.Mpris2(
                #     format="{xesam:title} - ({xesam:artist})",
                #     playing_text=" \ueb2c {track}",
                #     paused_text=" ⏸ {track}",
                #     width=300,
                #     scroll_delay=5,
                #     scroll_interval=0.25,
                #     scroll_step=15,
                #     fontsize=15,
                #     padding=18,
                #     foreground=COLORS.PRIMARY_LIGHT,
                #     # foreground=COLORS.PRIMARY,
                #     # font="3270 Nerd Font Mono"
                # ),

                widget.Image(
                    filename='~/.config/qtile/Assets/3.png',
                ),

                widget.Systray(
                    background=BASE.BACKGROUND,
                    fontsize=2,
                ),

                widget.TextBox(
                    text=' ',
                    background=BASE.BACKGROUND,
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/6.png',
                    background=BASE.BACKGROUND2,
                ),

                widget.TextBox(
                    text="",
                    font="Font Awesome 6 Free Solid",
                    fontsize=13,
                    background=BASE.BACKGROUND2,
                    foreground=BASE.FOREGROUND,
                ),

                widget.Memory(
                    background=BASE.BACKGROUND2,
                    format='{MemUsed: .0f}{mm}',
                    foreground=BASE.FOREGROUND,
                    font="JetBrainsMono Nerd Font Bold",
                    fontsize=13,
                    update_interval=5,
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/2.png',
                ),

                widget.Spacer(
                    length=8,
                    background=BASE.BACKGROUND2,
                ),

                widget.TextBox(
                    text=" ",
                    font="Font Awesome 6 Free Solid",
                    fontsize=13,
                    background=BASE.BACKGROUND2,
                    foreground=BASE.FOREGROUND,
                ),

                widget.Battery(
                    font="JetBrainsMono Nerd Font Bold",
                    fontsize=13,
                    background=BASE.BACKGROUND2,
                    foreground=BASE.FOREGROUND,
                    format='{percent:2.0%}',
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/2.png',
                ),

                widget.Spacer(
                    length=8,
                    background=BASE.BACKGROUND2,
                ),

                widget.TextBox(
                    text=" ",
                    font="Font Awesome 6 Free Solid",
                    fontsize=13,
                    background=BASE.BACKGROUND2,
                    foreground=BASE.FOREGROUND,
                ),

                widget.Volume(
                    font="JetBrainsMono Nerd Font Bold",
                    fontsize=13,
                    background=BASE.BACKGROUND2,
                    foreground=BASE.FOREGROUND,
                ),

                widget.Image(
                    filename='~/.config/qtile/Assets/5.png',
                    background=BASE.BACKGROUND2,
                ),

                widget.TextBox(
                    text=" ",
                    font="Font Awesome 6 Free Solid",
                    fontsize=13,
                    background=BASE.BACKGROUND,
                    foreground=BASE.FOREGROUND,
                ),

                widget.Clock(
                    format='%I:%M %p',
                    background=BASE.BACKGROUND,
                    foreground=BASE.FOREGROUND,
                    font="JetBrainsMono Nerd Font Bold",
                    fontsize=13,
                ),

                widget.Spacer(
                    length=18,
                    background=BASE.BACKGROUND,
                ),

            ],
            30,
            border_color=BASE.BACKGROUND,
            border_width=[0,0,0,0],
            margin=[15,60,6,60],

        ),
    ),

]
