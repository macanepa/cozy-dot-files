from libqtile.config import Key, Group
from libqtile.lazy import lazy
from .keys import keys, mod

roman = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X']
# groups = [Group(str(i), label=roman[int(i)-1]) for i in '1234']
groups = [Group(str(i), label='\ueaaa') for i in '1234']# + [Group(str('5'), label='M')]

for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + letter of group = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod1 + shift + letter of group = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )
    keys.extend(
        [
            Key(["control", "mod1"], "Right", lazy.screen.next_group()),
            Key(["control", "mod1"], "Left", lazy.screen.prev_group()),
        ]
    )
