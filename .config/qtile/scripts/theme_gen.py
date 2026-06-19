#!/usr/bin/env python3
"""
theme_gen.py — Generate a complete qtile-bar colour theme from ONE base colour.

The qtile bar is palette-driven (see modules/screens.py). A "theme" is:
  • a palette dict (bg, bg2, fg, fg_light, highlight, accent, primary, ai), and
  • a folder of recoloured PNG assets under Assets/<name>/ (separators, the
    launcher icon, the layout icons and the Claude logo).

This script derives the whole palette from a single hex colour using HLS maths
(the multipliers were reverse-engineered from the hand-tuned green & red themes
so a single colour reproduces a cohesive, pretty palette), then recolours every
PNG that appears in the bar and registers the theme in ~/.config/qtile/themes.json.

The recolour transforms are deterministic because every bar PNG is a flat,
single-colour shape:
  • Icons (flat colour + alpha mask)  ->  -fill COLOUR -colorize 100
        (replaces RGB, keeps the anti-aliased alpha edges; verified pixel-exact
         against the approved red launch_Icon, RMSE = 0)
  • Separators (opaque panels w/ a subtle 3-D fold)  ->  grayscale, fixed-level
        the two source tones (bg=6.667%, bg2=13.333%), then +level-colors bg,bg2
        (keeps the fold; both edges land exactly on the theme bg / bg2 panels)

Usage:
    theme_gen.py <name> <#hexcolor>      # generate + register a theme
    theme_gen.py --palette <name>        # recolour using a built-in palette
                                         #   (green|red) instead of deriving

Asset mapping (which palette colour each PNG is painted with):
    1..6.png        -> bg2   (panel separators, fold preserved)
    launch_Icon.png -> fg
    search.png      -> fg
    layout/*.png    -> fg_light
    claude.png      -> ai
"""
import colorsys
import json
import os
import shutil
import subprocess
import sys

ASSETS = os.path.expanduser("~/.config/qtile/Assets")
REGISTRY = os.path.expanduser("~/.config/qtile/themes.json")
MAGICK = shutil.which("magick") or shutil.which("convert")

# Separators whose subtle 3-D fold must be preserved (opaque panels).
SEPARATORS = ["1.png", "2.png", "3.png", "4.png", "5.png", "6.png"]
# Flat icons painted with a single palette colour. (key -> palette colour key)
FLAT_ICONS = {
    "launch_Icon.png": "fg",
    "search.png": "fg",
    "claude.png": "ai",
}

# ── Built-in palettes (kept byte-identical to modules/screens.py) ─────────────
BUILTIN = {
    "green": {
        "bg": "#0F1212", "bg2": "#202222", "fg": "#607767",
        "fg_light": "#B2BEBC", "highlight": "#202222",
        "accent": "#607767", "primary": "#d3c2aa", "ai": "#D97757",
    },
    "red": {
        "bg": "#120708", "bg2": "#2A1416", "fg": "#A66A6A",
        "fg_light": "#E4B9B9", "highlight": "#2A1416",
        "accent": "#8E1F26", "primary": "#D8A89A", "ai": "#E08C7F",
    },
}


# ── colour helpers ────────────────────────────────────────────────────────────
def hex_to_rgb01(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))


def rgb01_to_hex(rgb):
    return "#" + "".join(f"{max(0, min(255, round(c * 255))):02X}" for c in rgb)


def scale_hex(h, factor):
    r, g, b = hex_to_rgb01(h)
    return rgb01_to_hex((r * factor, g * factor, b * factor))


def clamp(x, lo, hi):
    return max(lo, min(hi, x))


def derive_palette(hexcolor):
    """Derive a full, cohesive palette from one base colour via HLS maths.

    Lightness anchors are fixed per role; saturation scales with the input's
    saturation (so a muted input -> a muted theme, a vivid input -> vivid),
    each with a sensible floor/ceiling. Multipliers reproduce the hand-tuned
    green & red themes from a single representative colour.
    """
    r, g, b = hex_to_rgb01(hexcolor)
    h, _l, s = colorsys.rgb_to_hls(r, g, b)

    def C(L, S):
        return rgb01_to_hex(colorsys.hls_to_rgb(h, L, S))

    bg2 = C(0.120, clamp(s * 1.4, 0.15, 0.50))
    return {
        "bg":        C(0.055, clamp(s * 1.8, 0.20, 0.60)),
        "bg2":       bg2,
        "fg":        C(0.500, clamp(s * 1.0, 0.12, 0.50)),
        "fg_light":  C(0.810, clamp(s * 1.8, 0.12, 0.60)),
        "highlight": bg2,
        "accent":    C(0.340, clamp(s * 2.6, 0.45, 0.85)),
        "primary":   C(0.725, clamp(s * 1.8, 0.18, 0.60)),
        "ai":        C(0.620, clamp(s * 2.2, 0.40, 0.85)),
    }


# ── recolour primitives (ImageMagick) ─────────────────────────────────────────
def _run(args):
    subprocess.run([MAGICK, *args], check=True)


def recolor_flat(src, dst, color):
    """Flat icon: replace RGB with `color`, keep the alpha mask intact."""
    _run([src, "-fill", color, "-colorize", "100", dst])


def recolor_panel(src, dst, bg, bg2):
    """Separator panel: retint so its edges match the bar panels exactly.

    The green source separators are built from exactly two tones - bg #0F1212
    (gray 6.667%) and bg2 #202222 (gray 13.333%) - plus the anti-aliased fold
    between them. Map those two FIXED luminance points to the theme's bg and bg2
    so every separator's dark edge lands on the theme bg panel and its light edge
    on the bg2 panel (no seams, whatever panels it sits between).

    Hand-proven on the red twins. The previous version used -auto-level
    (per-image normalisation) + bg2*0.76 for the dark edge, so each separator's
    dark edge was an arbitrary tone instead of the theme bg - the cause of the
    panel/separator colour mismatch in generated themes."""
    _run([src, "-colorspace", "Gray", "-channel", "RGB",
          "-level", "6.667%,13.333%", "+level-colors", f"{bg},{bg2}", "+channel", dst])


# ── theme builder ─────────────────────────────────────────────────────────────
def build_assets(palette, name):
    """Recolour every bar PNG from the green source assets into Assets/<name>/."""
    if MAGICK is None:
        sys.exit("ERROR: ImageMagick (magick/convert) not found on PATH.")
    out = os.path.join(ASSETS, name)
    os.makedirs(os.path.join(out, "layout"), exist_ok=True)

    for sep in SEPARATORS:
        recolor_panel(os.path.join(ASSETS, sep), os.path.join(out, sep),
                      palette["bg"], palette["bg2"])

    for icon, key in FLAT_ICONS.items():
        src = os.path.join(ASSETS, icon)
        if os.path.exists(src):
            recolor_flat(src, os.path.join(out, icon), palette[key])

    layout_dir = os.path.join(ASSETS, "layout")
    for f in sorted(os.listdir(layout_dir)):
        if f.endswith(".png"):
            recolor_flat(os.path.join(layout_dir, f),
                         os.path.join(out, "layout", f), palette["fg_light"])
    return out


def register(name, palette):
    data = {}
    if os.path.exists(REGISTRY):
        try:
            data = json.load(open(REGISTRY))
        except Exception:
            data = {}
    entry = dict(palette)
    entry["assets"] = f"{name}/"
    data[name] = entry
    json.dump(data, open(REGISTRY, "w"), indent=2)


def generate(name, palette):
    out = build_assets(palette, name)
    register(name, palette)
    return out


def main(argv):
    if len(argv) >= 3 and argv[1] == "--palette":
        name = argv[2]
        palette = BUILTIN.get(name)
        if not palette:
            sys.exit(f"Unknown built-in palette '{name}' (have: {', '.join(BUILTIN)})")
    elif len(argv) >= 3:
        name, color = argv[1], argv[2]
        if not color.startswith("#") or len(color.lstrip('#')) != 6:
            sys.exit("Colour must be a #RRGGBB hex value, e.g. #5E81AC")
        palette = derive_palette(color)
    else:
        sys.exit(__doc__)

    out = generate(name, palette)
    print(f"Theme '{name}' written:")
    for k, v in palette.items():
        print(f"  {k:9} {v}")
    print(f"  assets    {out}/")
    print(f"  registry  {REGISTRY}")


if __name__ == "__main__":
    main(sys.argv)
