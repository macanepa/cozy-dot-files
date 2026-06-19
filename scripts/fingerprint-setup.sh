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

# 3) Enrol a fingerprint (INTERACTIVE — swipe/press your finger several times)
say "3) Enrolling your fingerprint — follow the prompts (touch the sensor repeatedly)"
sudo -u "$REAL_USER" fprintd-enroll || { warn "Enrolment failed/cancelled; PAM left untouched."; exit 1; }
ok "Fingerprint enrolled."

# 4) Wire PAM — safely (sufficient => password remains a full fallback)
configure_pam() {
    local file="$1"
    [ -f "$file" ] || { warn "$file not found, skipping"; return; }
    if grep -q 'pam_fprintd.so' "$file"; then ok "$file already has pam_fprintd"; return; fi
    cp -a "$file" "${file}.bak.$(date +%s)"
    # insert as the FIRST auth rule; 'sufficient' => fingerprint OK = pass,
    # fingerprint fail/timeout = fall through to the normal password rules.
    sed -i '0,/^auth/ s/^auth/auth      sufficient  pam_fprintd.so\nauth/' "$file"
    if grep -q 'pam_fprintd.so' "$file"; then ok "$file configured (backup: ${file}.bak.*)"; else warn "could not edit $file"; fi
}
say "4) Configuring PAM (login + sudo)"
configure_pam /etc/pam.d/sddm     # graphical login
configure_pam /etc/pam.d/sudo     # sudo in the terminal

# 5) Done
say "DONE"
echo "  - Lock the screen / open a new sudo prompt and you should be able to use your finger."
echo "  - Your password ALWAYS still works (sufficient). To undo: restore the *.bak.* PAM files"
echo "    and run 'fprintd-delete $REAL_USER'."
echo "  - Manage prints later:  fprintd-enroll (add) | fprintd-list $REAL_USER | fprintd-delete $REAL_USER"
