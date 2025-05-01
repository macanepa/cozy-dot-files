from libqtile import hook
import subprocess
import os

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('.config/qtile/autostart_once.sh')
    subprocess.call([home])
