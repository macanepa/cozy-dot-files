#!/usr/bin/env bash
# =============================================================================
# Fingerprint login setup (fprintd) — ThinkPad E14 Gen 7, ELAN 04f3:0c8c
# Run with:  sudo bash scripts/fingerprint-setup.sh
#
# SAFETY: PAM is configured with `auth sufficient pam_fprintd.so`, meaning the
# fingerprint is an OPTIONAL extra — your PASSWORD always keeps working, so you
# can never get locked out. Every PAM file is backed up before editing.
#
# NOTE: ELAN match-on-chip readers are hit-or-miss with the stock libfprint.
# This script tries the OFFICIAL driver first and tells you if it works. If your
# reader isn't detected, you'd need the community `elanmoc2` driver (AUR/source),
# which is outside the current "no AUR" rule — the script stops and explains.
# =============================================================================
set -u
say()  { printf '\n\033[1;34m==> %s\033[0m\n' "$1"; }
ok()   { printf '\033[1;32m  ✓ %s\033[0m\n' "$1"; }
warn() { printf '\033[1;33m  ! %s\033[0m\n' "$1"; }

[ "$(id -u)" -eq 0 ] || { echo "Run as root:  sudo bash $0"; exit 1; }
REAL_USER="${SUDO_USER:-$(logname 2>/dev/null)}"
[ -n "${REAL_USER:-}" ] || { echo "Could not determine your user; run via sudo, not as root directly."; exit 1; }

# 1) Install the official fprintd + libfprint
say "1) Installing fprintd + libfprint (official repos)"
pacman -S --needed --noconfirm fprintd libfprint
systemctl enable --now fprintd.service 2>/dev/null || true

# 2) Probe whether the stock driver actually claims the reader
say "2) Checking if your reader is detected"
probe="$(sudo -u "$REAL_USER" fprintd-list "$REAL_USER" 2>&1)"
echo "    $probe"
if echo "$probe" | grep -qiE 'no devices|impossible to'; then
    warn "The stock libfprint driver does NOT detect your ELAN 04f3:0c8c reader."
    echo "    Options (both outside the current no-AUR rule):"
    echo "      - AUR:    yay -S libfprint-elanmoc2-git   (community driver)"
    echo "      - source: build https://gitlab.freedesktop.org/Depau/libfprint (elanmoc2 branch)"
    echo "    Re-run this script after installing that driver. Nothing was changed to PAM."
    exit 1
fi
ok "Reader detected."

# NOTE: enrolment is NOT done here. fprintd's polkit policy denies enrolment from
# a `sudo -u` context (no active session), so it must run inside YOUR own desktop
# session — see the final instructions. PAM uses `sufficient`, so it is safe to
# configure before any finger is enrolled (it simply falls back to your password).

# 3) Wire PAM — safely (sufficient => password remains a full fallback)
#
# The fprintd rule carries `timeout=5`: because it is the FIRST auth rule, every
# login() in the SDDM greeter runs fprintd before the password is checked. With a
# short timeout, choosing the PASSWORD backup (not touching the sensor) only waits
# ~5s instead of fprintd's 30s default. The greeter (Main.qml) does NOT auto-arm,
# so fprintd only runs when you opt into the finger (Enter on empty / click icon)
# or right after a password submit. `max-tries=3` lets a finicky press retry.
# Lower timeout to 3 for a snappier password path; raise it for more finger margin.
FPRINT_RULE='auth      sufficient  pam_fprintd.so  timeout=5 max-tries=3'
configure_pam() {
    local file="$1"
    [ -f "$file" ] || { warn "$file not found, skipping"; return; }
    if grep -q 'pam_fprintd.so' "$file"; then
        # Already present — normalise the rule to exactly $FPRINT_RULE (idempotent,
        # so re-running picks up a changed timeout/max-tries).
        if grep -qF "$FPRINT_RULE" "$file"; then ok "$file already configured"; return; fi
        cp -a "$file" "${file}.bak.$(date +%s)"
        sed -i 's#^\s*auth\s\+sufficient\s\+pam_fprintd.so.*#'"$FPRINT_RULE"'#' "$file"
        ok "$file rule normalised (backup: ${file}.bak.*)"
        return
    fi
    cp -a "$file" "${file}.bak.$(date +%s)"
    # insert as the FIRST auth rule; 'sufficient' => fingerprint OK = pass,
    # fingerprint fail/timeout = fall through to the normal password rules.
    sed -i '0,/^auth/ s#^auth#'"$FPRINT_RULE"'\nauth#' "$file"
    if grep -q 'pam_fprintd.so' "$file"; then ok "$file configured (backup: ${file}.bak.*)"; else warn "could not edit $file"; fi
}
say "3) Configuring PAM (login + sudo)"
configure_pam /etc/pam.d/sddm     # graphical login
configure_pam /etc/pam.d/sudo     # sudo in the terminal

# 4) Done
say "DONE — one manual step left: ENROL YOUR FINGER"
echo "  Run this in a NORMAL terminal (NOT via sudo), inside your desktop session:"
echo "      fprintd-enroll"
echo "  (touch the sensor repeatedly until it says 'enroll-completed')."
echo ""
echo "  Then lock the screen or open a new sudo prompt and use your finger."
echo "  Your password ALWAYS still works (sufficient). To undo: restore the *.bak.* PAM"
echo "  files and run 'fprintd-delete $REAL_USER'."
echo "  Manage prints:  fprintd-enroll (add) | fprintd-list $REAL_USER | fprintd-delete $REAL_USER"
