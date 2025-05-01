from libqtile import layout
from libqtile.config import Match
from modules.theme import WINDOW

layouts = [
    layout.Columns(
        border_focus_stack=[WINDOW.FOCUSED, WINDOW.UNFOCUSED],
        border_width=4,
        border_focus=WINDOW.FOCUSED,
        border_normal=WINDOW.UNFOCUSED,
        margin=10,
        margin_on_single=10,
    ),
    layout.Max(margin=10, margin_on_single=10),
    # layout.MonadTall(margin=8, border_focus='#5294e2', border_normal='#2c5380'),
    # layout.Columns(border_focus_stack='#d75f5f'),
    # layout.Max(),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        #Match(title="Acceso: Cuentas de Google - Brave")
    ],
    border_width=0,
    border_focus=WINDOW.FOCUSED,
    # border_normal="#ffc400",
    border_normal=WINDOW.UNFOCUSED,
)
