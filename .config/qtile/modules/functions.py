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
