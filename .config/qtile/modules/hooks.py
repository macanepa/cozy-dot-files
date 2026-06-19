from libqtile import hook
import subprocess
import os


@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser(".config/qtile/autostart_once.sh")
    subprocess.call([home])


@hook.subscribe.startup_once
def _battery_watch():
    from libqtile import qtile
    from .functions import start_battery_watch
    start_battery_watch(qtile)
