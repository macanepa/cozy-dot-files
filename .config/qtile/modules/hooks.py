from libqtile import hook
import subprocess
import os


@hook.subscribe.startup_once
def autostart():
    """Run autostart script once when Qtile starts."""
    home = os.path.expanduser("~/.config/qtile/autostart_once.sh")
    if os.path.exists(home):
        subprocess.Popen([home])


@hook.subscribe.client_new
def float_dialogs(window):
    """Float dialog windows and transient windows."""
    dialog = window.window.get_wm_type() == 'dialog'
    transient = window.window.get_wm_transient_for()
    if dialog or transient:
        window.floating = True


@hook.subscribe.client_new  
def float_steam(window):
    """Float Steam windows that aren't the main window."""
    wm_class = window.window.get_wm_class()
    if wm_class:
        if 'Steam' in wm_class and 'Steam' not in window.name:
            window.floating = True


@hook.subscribe.screen_change
def restart_on_screen_change(event):
    """Reload config when screens change (monitor plugged/unplugged)."""
    from libqtile import qtile
    qtile.reload_config()
