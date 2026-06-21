from libqtile import bar
from libqtile.lazy import lazy
from .widgets import *
from libqtile.config import Screen
from modules.keys import terminal
from libqtile.widget import Mpris2
from .keys import terminal
from .theme import COLORS, BASE
from .functions import (
    toggle_dropdown_calendar,
    toggle_dropdown_ai,
    toggle_dropdown_bluetooth,
    toggle_dropdown_sound,
    toggle_dropdown_network,
    power_mode_text,
    network_text,
)
import os
import json

from .groups import groups1, groups2

# Tray con soporte de menú al CLICK DERECHO (cerrar/Quit de cada app).
# El StatusNotifier oficial de qtile no implementa menús dbusmenu; el de
# qtile-extras (de elParaguayo, mantenedor de qtile) sí. Si qtile-extras está
# instalado se usa ese; si no, cae al de qtile (sin menú) y nada se rompe.
# Para habilitarlo:  yay -S qtile-extras   (versión debe coincidir con qtile)
try:
    from qtile_extras.widget import StatusNotifier as TrayStatusNotifier
except ImportError:
    from libqtile.widget import StatusNotifier as TrayStatusNotifier

# The bar's Wi-Fi icon toggles the network dropdown (see modules/groups.py).


# ─────────────────────────────────────────────────────────────────────────────
#  Palette-driven bar.
#
#  The bar is built from a palette dict ``C`` so the SAME layout can be rendered
#  either in the green/sage theme or, at low battery, in a gorgeous red one.
#  Every colour and every decorative PNG separator is parametrised.
#
#  Palette keys:
#    bg        bar background + darkest panels   (was BASE.BACKGROUND)
#    bg2       raised panels                     (was BASE.BACKGROUND2)
#    fg        body text / icons                 (was BASE.FOREGROUND)
#    fg_light  block-highlight / Prompt text     (was BASE.BLOCK_TEXT_HIGHLIGHT)
#    highlight GroupBox highlight_color          (was BASE.HIGHLIGHT)
#    accent    extra ember accent (unused in the byte-equivalent green build)
#    primary   warm accent                       (was BASE.PRIMARY)
#    assets    Image path prefix: '' for green, 'red/' for the red twins
# ─────────────────────────────────────────────────────────────────────────────

# GREEN is built from BASE.*/COLORS so make_screens(GREEN) is byte-equivalent
# to the original hand-written bar.
GREEN = {
    "bg":       BASE.BACKGROUND,            # '#0F1212'
    "bg2":      BASE.BACKGROUND2,           # '#202222'
    "fg":       BASE.FOREGROUND,            # '#607767'
    "fg_light": BASE.BLOCK_TEXT_HIGHLIGHT,  # '#B2BEBC'
    "highlight": BASE.HIGHLIGHT,            # '#202222'
    "accent":   BASE.FOREGROUND,            # unused in green; kept for symmetry
    "primary":  COLORS.PRIMARY,             # '#d3c2aa'
    "ai":       "#D97757",                  # Claude-logo clay (baked into claude.png)
    "assets":   "",
}

# RED: the low-battery alert palette. Recoloured PNG twins live in Assets/red/.
RED = {
    "bg":       "#120708",
    "bg2":      "#2A1416",
    "fg":       "#A66A6A",
    "fg_light": "#E4B9B9",
    "highlight": "#2A1416",
    "accent":   "#8E1F26",
    "primary":  "#D8A89A",
    "ai":       "#E08C7F",                  # coral Claude logo (baked into red/claude.png)
    "assets":   "red/",
}


# ─────────────────────────────────────────────────────────────────────────────
#  Theme registry.
#
#  GREEN and RED are the two built-in palettes. Extra, user-generated themes are
#  produced by scripts/theme_gen.py (which derives a full palette from one colour
#  and recolours every bar PNG into Assets/<name>/) and stored in themes.json.
#  The currently-selected *base* theme name is persisted in .current_theme so the
#  choice survives a qtile restart; the low-battery RED alert always overrides it.
# ─────────────────────────────────────────────────────────────────────────────
BUILTIN = {"green": GREEN, "red": RED}
_THEME_FILE = os.path.expanduser("~/.config/qtile/.current_theme")
_THEMES_JSON = os.path.expanduser("~/.config/qtile/themes.json")


def load_user_themes():
    try:
        with open(_THEMES_JSON) as f:
            return json.load(f)
    except Exception:
        return {}


def load_palette(name):
    """Resolve a theme name to a palette dict (built-in or user-generated)."""
    if name in BUILTIN:
        return BUILTIN[name]
    return load_user_themes().get(name, GREEN)


def current_theme_name():
    try:
        with open(_THEME_FILE) as f:
            return f.read().strip() or "green"
    except Exception:
        return "green"


def current_base_palette():
    """The non-alert palette to render (the user's selected base theme)."""
    return load_palette(current_theme_name())


def _asset(C, name):
    """Path to a decorative PNG separator for the given palette."""
    return f"~/.config/qtile/Assets/{C['assets']}{name}"


# ─────────────────────────────────────────────────────────────────────────────
#  Systray singleton.
#
#  qtile allows only ONE Systray instance for the lifetime of the process
#  (Systray._instances guards this). Because make_bar() may be called repeatedly
#  to rebuild the bar (green <-> red), we must NOT create a fresh Systray each
#  time — that would either trip the "Only one Systray can be used." ConfigError
#  or, via create_mirror(), drop the tray icons. Instead we create exactly one
#  Systray and reuse that same object in every rebuilt bar.
#
#  Systray ignores the palette: its only colour is ``background`` and it draws
#  icons against bar.background when its own background is transparent, so it
#  blends with whatever palette the bar currently uses.
# ─────────────────────────────────────────────────────────────────────────────
# Tray: StatusNotifier (SNI) instead of the legacy Systray — it survives
# reconfigure_screens() (Systray allows only one instance and crashes on rebuild).
# Built fresh per bar inside make_bar so its background follows the palette.


def make_bar(C):
    """Build a bar.Bar from a palette dict ``C``."""
    return bar.Bar(
        [
            widget.Spacer(
                length=15,
                background=C["bg"],
            ),
            widget.Image(
                filename=_asset(C, "launch_Icon.png"),
                margin=2,
                background=C["bg"],
                mouse_callbacks={"Button1": lazy.spawn(f"rofi -terminal {terminal} -show drun")},
            ),
            widget.Image(
                filename=_asset(C, "6.png"),
            ),
            widget.GroupBox(
                font="JetBrainsMono Nerd Font",
                fontsize=23,
                borderwidth=3,
                highlight_method="block",
                active=C["fg"],
                block_highlight_text_color=C["fg_light"],
                highlight_color=C["highlight"],
                inactive=C["bg"],
                foreground=C["highlight"],
                background=C["bg2"],
                this_current_screen_border=C["bg2"],
                this_screen_border=C["bg2"],
                other_current_screen_border=C["bg2"],
                other_screen_border=C["bg2"],
                urgent_border=C["bg2"],
                rounded=True,
                disable_drag=True,
                visible_groups=groups1,
            ),
            # Music group "M" — now sits right after groups 1-4, with a smaller
            # icon (its own GroupBox so it can be sized independently of 1-4).
            widget.GroupBox(
                font="JetBrainsMono Nerd Font",
                fontsize=15,
                borderwidth=3,
                highlight_method="block",
                active=C["fg"],
                block_highlight_text_color=C["fg_light"],
                highlight_color=C["highlight"],
                inactive=C["bg"],
                foreground=C["highlight"],
                background=C["bg2"],
                this_current_screen_border=C["bg2"],
                this_screen_border=C["bg2"],
                other_current_screen_border=C["bg2"],
                other_screen_border=C["bg2"],
                urgent_border=C["bg2"],
                rounded=True,
                disable_drag=True,
                visible_groups=["M"],
            ),
            widget.Spacer(
                length=8,
                background=C["bg2"],
            ),
            widget.Image(
                filename=_asset(C, "1.png"),
            ),
            widget.CurrentLayout(
                mode="icon",
                custom_icon_paths=[f"~/.config/qtile/Assets/{C['assets']}layout"],
                background=C["bg2"],
                scale=0.50,
            ),
            widget.Image(
                filename=_asset(C, "5.png"),
            ),
            widget.TextBox(
                text=" ",
                font="Font Awesome 6 Free Solid",
                fontsize=13,
                background=C["bg"],
                foreground=C["fg"],
            ),
            widget.Prompt(
                fontsize=14,
                foreground=C["fg_light"],
                background=C["bg"],
            ),
            widget.Image(
                filename=_asset(C, "4.png"),
            ),
            widget.WindowName(
                background=C["bg2"],
                font="JetBrainsMono Nerd Font Bold",
                fontsize=12,
                empty_group_string="Desktop",
                max_chars=130,
                foreground=C["fg"],
            ),
            widget.Image(
                filename=_asset(C, "3.png"),
            ),
            TrayStatusNotifier(
                background=C["bg"],
                padding=6,
            ),
            widget.TextBox(
                text=" ",
                background=C["bg"],
            ),
            widget.Image(
                filename=_asset(C, "6.png"),
                background=C["bg2"],
            ),
            widget.TextBox(
                text="",
                font="Font Awesome 6 Free Solid",
                fontsize=13,
                background=C["bg2"],
                foreground=C["fg"],
            ),
            widget.Memory(
                background=C["bg2"],
                format="{MemUsed: .0f}{mm}",
                foreground=C["fg"],
                font="JetBrainsMono Nerd Font Bold",
                fontsize=13,
                update_interval=5,
            ),
            widget.Image(
                filename=_asset(C, "2.png"),
            ),
            widget.Spacer(
                length=8,
                background=C["bg2"],
            ),
            widget.TextBox(
                text=" ",
                font="Font Awesome 6 Free Solid",
                fontsize=13,
                background=C["bg2"],
                foreground=C["fg"],
            ),
            widget.Battery(
                font="JetBrainsMono Nerd Font Bold",
                fontsize=13,
                background=C["bg2"],
                foreground=C["fg"],
                format="{percent:2.0%}",
            ),
            widget.Spacer(
                length=10,
                background=C["bg2"],
            ),
            widget.GenPollText(
                func=power_mode_text,
                update_interval=2,
                markup=True,
                font="JetBrainsMono Nerd Font",
                fontsize=14,
                padding=8,
                foreground=C["fg"],
                background=C["bg2"],
                mouse_callbacks={
                    "Button1": lazy.spawn(
                        os.path.abspath(
                            os.path.join(
                                os.path.dirname(__file__),
                                "..", "scripts", "power-menu.sh",
                            )
                        )
                    )
                },
            ),
            widget.Image(
                filename=_asset(C, "2.png"),
            ),
            widget.Spacer(
                length=8,
                background=C["bg2"],
            ),
            widget.Mpris2(
                format="{xesam:title} - ({xesam:artist})",
                playing_text=" \ueb2c {track}",
                paused_text=" ⏸ {track}",
                font="CaskaydiaCove Nerd Font",
                width=300,
                scroll_delay=5,
                scroll_interval=0.25,
                scroll_step=15,
                fontsize=13,
                padding=10,
                foreground=C["fg"],
                background=C["bg2"],
            ),
            # Network: a Wi-Fi glyph that reflects connectivity; click toggles the
            # network dropdown (scratchpad), like the sound/bluetooth icons — it runs
            # the themed nmcli TUI (scripts/network-tui.sh): scan, connect, toggle.
            widget.GenPollText(
                func=network_text,
                update_interval=5,
                font="Font Awesome 6 Free Solid",
                fontsize=14,
                padding=10,
                foreground=C["fg"],
                background=C["bg2"],
                mouse_callbacks={"Button1": toggle_dropdown_network},
            ),
            widget.TextBox(
                text=" ",
                font="Font Awesome 6 Free Solid",
                fontsize=13,
                background=C["bg2"],
                foreground=C["fg"],
                mouse_callbacks={"Button1": toggle_dropdown_sound},
            ),
            widget.TextBox(
                text="",
                background=C["bg2"],
                foreground=C["fg"],
                font="CaskaydiaCove Nerd Font",  # declare the font that actually draws U+F293
                fontsize=18,
                padding=10,
                mouse_callbacks={"Button1": toggle_dropdown_bluetooth},
            ),
            widget.Image(
                filename=_asset(C, "5.png"),
                background=C["bg2"],
            ),
            widget.KeyboardLayout(
                configured_keyboards=["us", "es"],
                padding=10,
                foreground=C["fg"],
                background=C["bg"],
                fontsize=15,
            ),
            widget.TextBox(
                text=" ",
                font="Font Awesome 6 Free Solid",
                fontsize=13,
                background=C["bg"],
                foreground=C["fg"],
            ),
            widget.Clock(
                format="%I:%M %p",
                background=C["bg"],
                foreground=C["fg"],
                font="JetBrainsMono Nerd Font Bold",
                fontsize=13,
            ),
            widget.TextBox(
                text="",
                font="CaskaydiaCove Nerd Font",
                background=C["bg"],
                foreground=C["fg"],
                fontsize=18,
                padding=10,
                mouse_callbacks={"Button1": toggle_dropdown_calendar},
            ),
            widget.Image(
                filename=_asset(C, "claude.png"),
                background=C["bg"],
                margin_y=6,
                margin_x=9,
                mouse_callbacks={"Button1": toggle_dropdown_ai},
            ),
            widget.Spacer(
                length=18,
                background=C["bg"],
            ),
        ],
        30,
        border_color=C["bg"],
        border_width=[0, 0, 0, 0],
        # margin=[15, 60, 6, 60],  # barra flotante con gaps (descomentar para revertir)
        margin=[0, 0, 0, 0],  # pegada al techo, de extremo a extremo
    )


def make_screens(C):
    """Build the screens list from a palette dict ``C``."""
    return [
        Screen(
            top=make_bar(C),
        ),
    ]


screens = make_screens(current_base_palette())
