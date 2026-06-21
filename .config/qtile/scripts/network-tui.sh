#!/usr/bin/env bash
# network-tui.sh — themed, auto-refreshing NetworkManager TUI.
#
# A small full-custom front-end over `nmcli`, painted in the *current* cozy qtile
# theme palette. Launched as a qtile scratchpad dropdown:
#     alacritty --class cozy-net -e .../network-tui.sh
# Unlike a rofi menu it stays open and live-refreshes the network list (and the
# signal bars) on its own; connect/toggle/rescan happen in place.
#
# Keys:  ↑/k ↓/j move · ⏎ connect · t wifi on/off · d disconnect · r rescan · q quit
set -uo pipefail

REFRESH=2        # seconds between auto-refreshes (also the key-input timeout)
RESCAN_EVERY=5   # kick a background rescan every N refresh ticks

# ── theme palette: defaults (green), overridden by the live theme ───────────
PAL_bg="#0F1212"; PAL_bg2="#202222"; PAL_fg="#607767"
PAL_fg_light="#B2BEBC"; PAL_primary="#d3c2aa"; PAL_accent="#607767"; PAL_dim="#3a463f"
eval "$(python3 - <<'PY' 2>/dev/null
import json, os
base = os.path.expanduser("~/.config/qtile")
GREEN = {"bg":"#0F1212","bg2":"#202222","fg":"#607767",
         "fg_light":"#B2BEBC","primary":"#d3c2aa","accent":"#607767"}
def load():
    try:
        name = open(os.path.join(base, ".current_theme")).read().strip() or "green"
    except Exception:
        name = "green"
    if name == "green":
        return GREEN
    try:
        p = json.load(open(os.path.join(base, "themes.json"))).get(name)
        if p:
            return {k: p.get(k, GREEN[k]) for k in GREEN}
    except Exception:
        pass
    return GREEN
pal = load()
def _blend(a, b, t):
    a = a.lstrip("#"); b = b.lstrip("#")
    return "#%02x%02x%02x" % tuple(
        round(int(a[i:i+2], 16) * (1 - t) + int(b[i:i+2], 16) * t) for i in (0, 2, 4)
    )
pal["dim"] = _blend(pal["fg"], pal["bg"], 0.45)   # visible-but-subtle (separators, hints)
for k, v in pal.items():
    print(f'PAL_{k}="{v}"')
PY
)" || true

# ── truecolor helpers ───────────────────────────────────────────────────────
_rgb() { local h=${1#\#}; printf '%d;%d;%d' "$((16#${h:0:2}))" "$((16#${h:2:2}))" "$((16#${h:4:2}))"; }
RST=$'\033[0m'
C_FG=$'\033[38;2;'"$(_rgb "$PAL_fg")"m
C_HI=$'\033[38;2;'"$(_rgb "$PAL_fg_light")"m
C_ACC=$'\033[38;2;'"$(_rgb "$PAL_primary")"m
C_DIM=$'\033[38;2;'"$(_rgb "$PAL_dim")"m

# ── glyphs (nerd font) ──────────────────────────────────────────────────────
G_WIFI=$''
G_LOCK=$'\U000f033e'
G_DOT=$'●'
G_OK=$'\U000f05e0'
sig_icon() { # $1 = signal 0-100
  local s=$1
  if   (( s >= 75 )); then printf '%s' $'\U000f0928'
  elif (( s >= 50 )); then printf '%s' $'\U000f0925'
  elif (( s >= 25 )); then printf '%s' $'\U000f0922'
  elif (( s >= 5  )); then printf '%s' $'\U000f091f'
  else                     printf '%s' $'\U000f092b'; fi
}
rule() { local n=$1; printf "${C_DIM}"; printf '─%.0s' $(seq 1 "$n"); printf "${RST}"; }
declare -a LINES
row() { local _s; printf -v _s "$@"; LINES+=("$_s"); }   # append a formatted line

# ── terminal setup ──────────────────────────────────────────────────────────
cleanup() { printf '\033[?25h\033[?1049l'; stty echo 2>/dev/null; }
trap cleanup EXIT INT TERM
printf '\033[?1049h\033[?25l'   # alt-screen + hide cursor
stty -echo 2>/dev/null

# ── nmcli helpers ───────────────────────────────────────────────────────────
WIFI_DEV="$(nmcli -t -f DEVICE,TYPE device 2>/dev/null | awk -F: '$2=="wifi"{print $1; exit}')"
wifi_on() { [[ "$(nmcli radio wifi 2>/dev/null)" == enabled ]]; }
is_saved() { nmcli -t -f NAME connection show 2>/dev/null | grep -qxF "$1"; }

declare -a SSIDS SIGNALS SECS ACTIVES
SEL=0; MSG=""; MSG_TTL=0; TICK=0

scan_list() {
  SSIDS=(); SIGNALS=(); SECS=(); ACTIVES=()
  wifi_on || return
  local line in_use signal security ssid seen=":"
  while IFS= read -r line; do
    in_use=${line%%:*};  line=${line#*:}
    signal=${line%%:*};  line=${line#*:}
    security=${line%%:*}; ssid=${line#*:}
    ssid=${ssid//\\:/:}
    [[ -z $ssid ]] && continue
    [[ $seen == *":$ssid:"* ]] && continue   # one row per SSID (strongest first)
    seen+="$ssid:"
    SSIDS+=("$ssid")
    SIGNALS+=("${signal:-0}")
    SECS+=("$security")
    [[ $in_use == "*" ]] && ACTIVES+=(1) || ACTIVES+=(0)
  done < <(nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID device wifi list --rescan no 2>/dev/null)
  (( SEL >= ${#SSIDS[@]} )) && SEL=$(( ${#SSIDS[@]} - 1 ))
  (( SEL < 0 )) && SEL=0
}

render() {
  local n=${#SSIDS[@]} i ssid sig sec act sel dot lock namecol label pad buf
  local EL=$'\033[K'           # erase to end of line
  LINES=()
  row ''
  if wifi_on; then
    row '   %s%s%s  %sRedes Wi-Fi%s          %s%s en vivo%s' \
      "$C_ACC" "$G_WIFI" "$RST" "$C_HI" "$RST" "$C_DIM" "$G_DOT" "$RST"
  else
    row '   %s%s%s  %sRedes Wi-Fi%s          %sapagado%s' \
      "$C_ACC" "$G_WIFI" "$RST" "$C_HI" "$RST" "$C_ACC" "$RST"
  fi
  row '   %s' "$(rule 46)"
  row ''
  if ! wifi_on; then
    row '   %sWi-Fi apagado.%s  pulsá %st%s para encender.' "$C_FG" "$RST" "$C_ACC" "$RST"
  elif (( n == 0 )); then
    row '   %sbuscando redes…%s' "$C_DIM" "$RST"
  else
    for ((i=0; i<n; i++)); do
      ssid=${SSIDS[i]}; sig=${SIGNALS[i]}; sec=${SECS[i]}; act=${ACTIVES[i]}
      if (( i == SEL )); then sel="${C_ACC}▎${RST}"; namecol=$C_HI; else sel=" "; namecol=$C_FG; fi
      if [[ $act == 1 ]]; then dot="${C_ACC}${G_DOT}${RST}"; else dot=" "; fi
      if [[ -n $sec ]]; then lock="${C_DIM}${G_LOCK}${RST}"; else lock=" "; fi
      label=${ssid:0:24}; pad=$(( 24 - ${#label} )); (( pad < 0 )) && pad=0   # pad by chars (UTF-8 safe)
      row '  %s %s  %s%s%s%*s %s%s%s %s%3d%s  %s' \
        "$sel" "$dot" "$namecol" "$label" "$RST" "$pad" "" \
        "$C_ACC" "$(sig_icon "$sig")" "$RST" "$C_FG" "$sig" "$RST" "$lock"
    done
  fi
  row ''
  row '   %s' "$(rule 46)"
  row '   %s↑↓%s mover   %s⏎%s conectar   %st%s wifi   %sd%s desconectar   %sr%s scan   %sq%s salir' \
    "$C_ACC" "$C_DIM" "$C_ACC" "$C_DIM" "$C_ACC" "$C_DIM" "$C_ACC" "$C_DIM" "$C_ACC" "$C_DIM" "$C_ACC" "$C_DIM"
  if (( MSG_TTL > 0 )) && [[ -n $MSG ]]; then row ''; row '   %s%s%s' "$C_HI" "$MSG" "$RST"; fi
  # Flicker-free: one write — home, every line cleared to EOL, then clear below.
  buf=$'\033[H'
  for i in "${LINES[@]}"; do buf+="$i$EL"$'\n'; done
  buf+=$'\033[J'
  printf '%s' "$buf"
}

notify() { MSG="$1"; MSG_TTL=2; }

connect_sel() {
  local n=${#SSIDS[@]}; (( n == 0 )) && return
  local ssid=${SSIDS[SEL]} sec=${SECS[SEL]} act=${ACTIVES[SEL]} out
  (( act == 1 )) && { notify "Ya conectado a $ssid"; return; }
  printf '\n   %sConectando a %s…%s\n' "$C_ACC" "$ssid" "$RST"
  if is_saved "$ssid" || [[ -z $sec ]]; then
    out=$(nmcli device wifi connect "$ssid" 2>&1)
  else
    printf '   %s%s Contraseña para %s:%s ' "$C_ACC" "$G_LOCK" "$ssid" "$RST"
    printf '\033[?25h'                       # show cursor; echo stays OFF (silent)
    local pwd; IFS= read -rs pwd; echo
    printf '\033[?25l'
    [[ -z $pwd ]] && { notify "Cancelado"; return; }
    out=$(nmcli device wifi connect "$ssid" password "$pwd" 2>&1)
  fi
  if [[ $out == *successfully* ]]; then notify "Conectado a $ssid"
  else notify "Error: ${out#Error: }"; fi
}

disconnect_active() {
  [[ -n $WIFI_DEV ]] || { notify "Sin dispositivo Wi-Fi"; return; }
  if nmcli device disconnect "$WIFI_DEV" >/dev/null 2>&1; then notify "Desconectado"
  else notify "No se pudo desconectar"; fi
}

toggle_wifi() {
  if wifi_on; then nmcli radio wifi off >/dev/null 2>&1; notify "Wi-Fi apagado"
  else nmcli radio wifi on >/dev/null 2>&1; notify "Wi-Fi encendido"; fi
}

# ── main loop ───────────────────────────────────────────────────────────────
[[ -z $WIFI_DEV ]] && { clear; echo "  Sin dispositivo Wi-Fi (NetworkManager)."; sleep 2; exit 0; }
nmcli device wifi rescan >/dev/null 2>&1 &
while true; do
  scan_list
  render
  (( MSG_TTL > 0 )) && MSG_TTL=$(( MSG_TTL - 1 ))
  TICK=$(( TICK + 1 ))
  if (( TICK % RESCAN_EVERY == 0 )) && wifi_on; then
    nmcli device wifi rescan >/dev/null 2>&1 &
  fi
  if IFS= read -rsn1 -t "$REFRESH" key; then
    if [[ $key == $'\033' ]]; then IFS= read -rsn2 -t 0.01 k2 || true; key+="$k2"; fi
    case $key in
      k|$'\033[A') (( SEL > 0 )) && SEL=$(( SEL - 1 )) ;;
      j|$'\033[B') (( SEL < ${#SSIDS[@]} - 1 )) && SEL=$(( SEL + 1 )) ;;
      ''|$'\n'|$'\r') connect_sel ;;
      t|T) toggle_wifi ;;
      d|D) disconnect_active ;;
      r|R) nmcli device wifi rescan >/dev/null 2>&1 & notify "Reescaneando…" ;;
      q|Q) break ;;
    esac
  fi
done
