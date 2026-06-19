import os

from libqtile.lazy import lazy


@lazy.function
def toggle_dropdown_ai(qtile):
    qtile.groups_map["scratchpad"].dropdown_toggle("chatbot")


@lazy.function
def toggle_dropdown_calendar(qtile):
    qtile.groups_map["scratchpad"].dropdown_toggle("calendar")


@lazy.function
def toggle_dropdown_bluetooth(qtile):
    qtile.groups_map["scratchpad"].dropdown_toggle("bluetooth")


@lazy.function
def toggle_dropdown_sound(qtile):
    qtile.groups_map["scratchpad"].dropdown_toggle("sound")


# ─────────────────────────────────────────────────────────────
#   Low-battery alert: rebuild the WHOLE bar as a gorgeous red
#
#   RENDER-SAFE approach (Option A): instead of live-mutating the
#   already-configured widgets (which left text/GroupBox layouts in a
#   half-configured None state and broke rendering), we swap the entire
#   `screens` definition for a palette-built one and let qtile rebuild the
#   bar from scratch via reconfigure_screens(). A no-op reconfigure was
#   proven to keep the bar pixel-perfect, so rebuilding from a clean RED
#   palette renders flawlessly.
# ─────────────────────────────────────────────────────────────
LOW_BAT_PCT = 20        # Red alert when battery <= this %, while discharging.
PREVIEW_RED = False     # TEMP: forces the bar red NOW so you can see it. Set False for real behavior.

# Tracks whether we last rendered the bar in low (red) mode, so we only
# reconfigure when the low-state actually changes (avoids needless rebuilds).
_bat_state = {"low": None}


def set_bar_mode(qtile, red):
    """Render-safe bar swap.

    Replace the live screens definition with a freshly palette-built one and
    ask qtile to rebuild every bar from it. reconfigure_screens() finalises the
    old bar (including its tray) and configures the new one, all on qtile's own
    event loop, so rendering stays correct.

    ``red`` True  -> the low-battery RED alert palette (always wins).
    ``red`` False -> the user's selected *base* theme (green or any generated
                     theme), resolved from screens.current_base_palette().
    """
    import modules.screens as S

    pal = S.RED if red else S.current_base_palette()
    qtile.config.screens = S.make_screens(pal)
    qtile.reconfigure_screens()


# ── Public paint helpers (used by apply/revert snippets & the watcher) ──
def paint_red(qtile):
    set_bar_mode(qtile, True)


def restore(qtile):
    set_bar_mode(qtile, False)


def apply_theme(qtile, name):
    """Select `name` as the base theme, persist it, and render it now.

    Persists the choice to ~/.config/qtile/.current_theme so it survives a
    restart. If the battery is currently low the RED alert keeps priority and
    the new theme appears once the battery recovers; otherwise it shows at once.
    Called over qtile IPC by scripts/theme-picker.sh.
    """
    theme_file = os.path.expanduser("~/.config/qtile/.current_theme")
    with open(theme_file, "w") as f:
        f.write(name)
    low = _battery_is_low()
    _bat_state["low"] = low
    set_bar_mode(qtile, low)
    _set_wallpaper(name)
    # Push the same palette to the rest of the desktop (terminal, notifications,
    # calendar) so the theme is transversal, not just the bar.
    import modules.screens as S
    from .app_theme import apply_app_themes
    apply_app_themes(S.load_palette(name))
    # Full qtile restart so the whole config reloads cleanly on the new theme
    # (the user's "mod+ctrl+r"). reload_config() would NOT do it: config.py
    # imports `screens` at module top level and Python caches that, so a reload
    # keeps the previous palette. Deferred so this IPC call returns first; the
    # app + wallpaper changes above are written to files and survive the restart.
    qtile.call_later(0.3, qtile.restart)
    return name


def _set_wallpaper(name):
    """Set the desktop wallpaper for a theme, if one exists.

    Looks for ~/.config/qtile/wallpapers/<name>.{png,jpg,jpeg} and applies it
    with feh. Themes without a dedicated wallpaper keep the current one. The
    low-battery RED alert never touches the wallpaper (it only repaints the
    bar), so the desktop always shows the selected base theme's wallpaper.
    """
    import subprocess
    wdir = os.path.expanduser("~/.config/qtile/wallpapers")
    for ext in ("png", "jpg", "jpeg"):
        p = os.path.join(wdir, f"{name}.{ext}")
        if os.path.exists(p):
            subprocess.Popen(["feh", "--bg-fill", p])
            return


def _read_battery():
    try:
        cap = int(open("/sys/class/power_supply/BAT0/capacity").read().strip())
        status = open("/sys/class/power_supply/BAT0/status").read().strip()
        return cap, status
    except Exception:
        return 100, "Unknown"


def _battery_is_low():
    if PREVIEW_RED:
        return True
    cap, status = _read_battery()
    return cap <= LOW_BAT_PCT and status == "Discharging"


def _battery_tick(qtile):
    low = _battery_is_low()
    if low != _bat_state["low"]:
        _bat_state["low"] = low
        set_bar_mode(qtile, low)
    qtile.call_later(20, _battery_tick, qtile)


def start_battery_watch(qtile):
    if getattr(qtile, "_bat_watch_started", False):
        return
    qtile._bat_watch_started = True
    # Defer the first tick so the bar is fully up before we ever reconfigure.
    qtile.call_later(2, _battery_tick, qtile)


# ─────────────────────────────────────────────────────────────
#     Performance-mode indicator (AMD platform_profile)
# ─────────────────────────────────────────────────────────────
def power_mode_text():
    """Return ONLY a nerd-font icon for the current AMD platform_profile.

    No label, no per-mode colour: the GenPollText widget paints it in the
    theme's ``fg``, so it matches every other bar icon.
    """
    try:
        prof = open("/sys/firmware/acpi/platform_profile").read().strip()
    except Exception:
        prof = "?"
    return {
        "low-power":   "\uf06c",   # leaf  -> Ahorro
        "balanced":    "\uf24e",   # scale -> Equilibrado
        "performance": "\uf0e7",   # bolt  -> Maximo
    }.get(prof, "\uf059")          # question -> unknown
