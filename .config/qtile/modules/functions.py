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
LOW_BAT_PCT = 20        # alert at/below this %, while discharging
PREVIEW_RED = False     # TEMP: forces the bar red NOW so you can see it. Set False for real behavior.

# Tracks whether we last rendered the bar in low (red) mode, so we only
# reconfigure when the low-state actually changes (avoids needless rebuilds).
_bat_state = {"low": None}


def set_bar_mode(qtile, red):
    """Render-safe bar swap.

    Replace the live screens definition with a freshly palette-built one and
    ask qtile to rebuild every bar from it. reconfigure_screens() finalises the
    old bar (including its Systray) and configures the new one, all on qtile's
    own event loop, so rendering stays correct.

    The Systray is a process-wide singleton (modules.screens._SYSTRAY) reused
    across every rebuild, so the single-Systray constraint is never violated and
    the tray survives the swap (see modules/screens.py for the full rationale).
    """
    import modules.screens as S

    qtile.config.screens = S.make_screens(S.RED if red else S.GREEN)
    qtile.reconfigure_screens()


# ── Public paint helpers (used by apply/revert snippets & the watcher) ──
def paint_red(qtile):
    set_bar_mode(qtile, True)


def restore(qtile):
    set_bar_mode(qtile, False)


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
    try:
        prof = open("/sys/firmware/acpi/platform_profile").read().strip()
    except Exception:
        prof = "?"
    table = {
        "low-power":   ("", "#788E7D", "Ahorro"),        # leaf   (verde)
        "balanced":    ("", "#b2bebc", "Equilibrado"),   # scale  (claro)
        "performance": ("", "#fb958b", "Máximo"),   # bolt   (coral)
    }
    icon, color, label = table.get(prof, ("", "#607767", prof))
    return f'<span foreground="{color}">{icon}  {label}</span>'
