#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  theme-picker.sh — pick a qtile-bar colour theme from rofi, or create a new
#  one from any colour on the fly.
#
#  • Lists the built-in themes (green, red) plus every user theme registered in
#    themes.json, each with a colour swatch.
#  • Selecting one applies it live (scripts/theme_gen.py made the assets; this
#    just swaps the bar via qtile IPC -> modules.functions.apply_theme).
#  • Selecting "✛  Nuevo color…" prompts for a hex colour (and a name), runs
#    theme_gen.py to derive the palette + recolour every bar PNG, then applies it.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

QDIR="$HOME/.config/qtile"
GEN="$QDIR/scripts/theme_gen.py"
JSON="$QDIR/themes.json"

apply() {  # apply <name>
  qtile cmd-obj -o cmd -f eval \
    -a "__import__('modules.functions', fromlist=['apply_theme']).apply_theme(self, '$1')" >/dev/null
}

# Build parallel arrays: NAMES[i] + swatch-markup ROWS[i], in display order.
NAMES=(); ROWS=()
add_row() {  # add_row <name> <accent_hex>
  NAMES+=("$1")
  ROWS+=("<span foreground='$2'>████</span>  $1")
}

# Built-ins first (representative swatch colours).
add_row green "#7E9A86"
add_row red   "#C0494F"
# User themes from the registry (swatch = each theme's accent).
if [[ -f "$JSON" ]]; then
  while IFS='|' read -r n a; do
    [[ -n "$n" ]] && add_row "$n" "$a"
  done < <(python3 -c "
import json,sys
d=json.load(open('$JSON'))
for n,e in d.items(): print(f\"{n}|{e.get('accent','#888888')}\")
" 2>/dev/null)
fi
NEW_INDEX=${#NAMES[@]}
ROWS+=("<span foreground='#9aa'>✛</span>  Nuevo color…")

# Render the menu; -format i returns the chosen row index.
sel=$(printf '%b\n' "${ROWS[@]}" | rofi -dmenu -markup-rows -i -p "Tema" -format i || true)
[[ -z "${sel:-}" ]] && exit 0

if [[ "$sel" -eq "$NEW_INDEX" ]]; then
  color=$(printf '' | rofi -dmenu -p "Color (#RRGGBB)" -lines 0 || true)
  [[ -z "${color:-}" ]] && exit 0
  [[ "$color" != \#* ]] && color="#$color"
  name=$(printf '' | rofi -dmenu -p "Nombre del tema" -lines 0 || true)
  # Slugify (or fall back to the hex digits) so the asset folder name is safe.
  name=$(printf '%s' "${name:-}" | tr 'A-Z ' 'a-z-' | tr -cd 'a-z0-9_-')
  [[ -z "$name" ]] && name=$(printf '%s' "$color" | tr -d '#' | tr 'A-Z' 'a-z')
  if ! python3 "$GEN" "$name" "$color" >/dev/null 2>&1; then
    notify-send "Theme" "No pude generar el tema (¿color hex válido?): $color"
    exit 1
  fi
  apply "$name"
  notify-send "Tema aplicado" "$name  ($color)"
else
  name="${NAMES[$sel]}"
  apply "$name"
  notify-send "Tema aplicado" "$name"
fi
