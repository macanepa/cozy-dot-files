from libqtile.lazy import lazy


@lazy.function
def toggle_dropdown_ai(qtile):
    """Toggle the AI chatbot dropdown terminal."""
    qtile.groups_map["scratchpad"].dropdown_toggle("chatbot")


@lazy.function
def toggle_dropdown_calendar(qtile):
    """Toggle the calendar (calcurse) dropdown."""
    qtile.groups_map["scratchpad"].dropdown_toggle("calendar")


@lazy.function
def toggle_dropdown_bluetooth(qtile):
    """Toggle the Bluetooth manager dropdown."""
    qtile.groups_map["scratchpad"].dropdown_toggle("bluetooth")


@lazy.function
def toggle_dropdown_sound(qtile):
    """Toggle the sound control (pavucontrol) dropdown."""
    qtile.groups_map["scratchpad"].dropdown_toggle("sound")


@lazy.function
def toggle_dropdown_terminal(qtile):
    """Toggle a quick dropdown terminal."""
    qtile.groups_map["scratchpad"].dropdown_toggle("terminal")


@lazy.function
def toggle_dropdown_htop(qtile):
    """Toggle htop system monitor dropdown."""
    qtile.groups_map["scratchpad"].dropdown_toggle("htop")


@lazy.function
def float_to_front(qtile):
    """Bring all floating windows to front."""
    for window in qtile.current_group.windows:
        if window.floating:
            window.cmd_bring_to_front()


@lazy.function
def minimize_all(qtile):
    """Minimize all windows in current group."""
    for window in qtile.current_group.windows:
        window.cmd_toggle_minimize()
