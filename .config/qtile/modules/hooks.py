from libqtile import hook
import subprocess
import os


@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser(".config/qtile/autostart_once.sh")
    subprocess.call([home])


# startup (not startup_once) so the watcher is rearmed on every restart too,
# not just on a cold boot. start_battery_watch() guards against double-start.
@hook.subscribe.startup
def _battery_watch():
    from libqtile import qtile
    from .functions import start_battery_watch
    start_battery_watch(qtile)
