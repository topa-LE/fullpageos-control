#!/bin/bash
# ==========================================
# Script: usb_boot_stick_debian_12_auto_server.sh
# Author: topa-LE
# Zweck : Debian 12 Bookworm Netinst laden,
#         remastern, Auto-Server-Install ohne Desktop
#         erzeugen und bootfähig auf USB schreiben
# ==========================================

set -euo pipefail

# ==============================
# KONFIGURATION
# ==============================
ARCH="amd64"
DEBIAN_VERSION="12.13.0"
ISO_NAME="debian-${DEBIAN_VERSION}-${ARCH}-netinst.iso"
ISO_URL="https://cdimage.debian.org/cdimage/archive/${DEBIAN_VERSION}/${ARCH}/iso-cd/${ISO_NAME}"
SHA_URL="https://cdimage.debian.org/cdimage/archive/${DEBIAN_VERSION}/${ARCH}/iso-cd/SHA256SUMS"

WORKDIR="/home/build/debian12_auto_server"
ISODIR="${WORKDIR}/iso"
ORIG_ISO="${WORKDIR}/${ISO_NAME}"
AUTO_ISO="${WORKDIR}/debian-12.13.0-amd64-auto-server.iso"
PRESEED_FILE="${WORKDIR}/preseed.cfg"
BS="4M"

# ==============================
# AUSGABEN
# ==============================
info()  { echo -e "\e[1;34mℹ️  $*\e[0m"; }
ok()    { echo -e "\e[1;32m✅ $*\e[0m"; }
warn()  { echo -e "\e[1;33m⚠️  $*\e[0m"; }
err()   { echo -e "\e[1;31m❌ $*\e[0m"; exit 1; }

cleanup() {
    sync || true
}
trap cleanup EXIT

# ==============================
# ROOT CHECK
# ==============================
if [[ "${EUID}" -ne 0 ]]; then
    err "Bitte als root ausführen: sudo bash /home/build/usb_boot_stick_debian_12_auto_server.sh"
fi

# ==============================
# TOOLS CHECK
# ==============================
for cmd in wget sha256sum lsblk dd sync awk grep sed findmnt umount xorriso rsync md5sum; do
    command -v "${cmd}" >/dev/null 2>&1 || err "Benötigtes Tool fehlt: ${cmd}"
done

# ==============================
# HEADER
# ==============================
clear
echo "=============================================="
echo "🚀 Debian 12 Auto Server USB Creator"
echo "💽 Hands-off Install ohne Desktop"
echo "👤 root = debian"
echo "👤 ace  = debian"
echo "📁 Arbeitsverzeichnis: ${WORKDIR}"
echo "=============================================="
echo

# ==============================
# ARBEITSVERZEICHNIS
# ==============================
mkdir -p "${WORKDIR}"
rm -rf "${ISODIR}"
mkdir -p "${ISODIR}"
cd "${WORKDIR}"

# ==============================
# PAKETHINWEIS
# ==============================
info "Falls xorriso oder rsync fehlen:"
echo "apt update && apt install -y xorriso rsync wget"
echo

# ==============================
# ISO DOWNLOAD
# ==============================
if [[ -f "${ORIG_ISO}" ]]; then
    ok "ISO bereits vorhanden: ${ORIG_ISO}"
else
    info "Lade Debian 12 Netinst ISO ..."
    wget -O "${ORIG_ISO}" "${ISO_URL}"
    ok "ISO erfolgreich geladen"
fi

# ==============================
# SHA256 PRÜFEN
# ==============================
info "Lade SHA256SUMS ..."
wget -O "${WORKDIR}/SHA256SUMS" "${SHA_URL}"

info "Prüfe SHA256 ..."
grep " ${ISO_NAME}$" "${WORKDIR}/SHA256SUMS" > "${WORKDIR}/SHA256SUMS.iso" || err "ISO nicht in SHA256SUMS gefunden"
(
    cd "${WORKDIR}"
    sha256sum -c SHA256SUMS.iso
) || err "SHA256-Prüfung fehlgeschlagen"
ok "SHA256-Prüfung erfolgreich"

# ==============================
# PRESEED ERZEUGEN
# ==============================
info "Erzeuge preseed.cfg ..."

cat > "${PRESEED_FILE}" <<'EOF'
### =========================================
### Debian 12 Auto Server Install (ohne Desktop)
### root: debian
### ace : debian
### =========================================

d-i debian-installer/locale string de_DE.UTF-8
d-i keyboard-configuration/xkb-keymap select de
d-i console-setup/ask_detect boolean false

d-i netcfg/choose_interface select auto
d-i netcfg/get_hostname string debian-server
d-i netcfg/get_domain string local
d-i netcfg/disable_dhcp boolean false

d-i clock-setup/utc boolean true
d-i time/zone string Europe/Berlin
d-i clock-setup/ntp boolean true

d-i passwd/root-login boolean true
d-i passwd/root-password password debian
d-i passwd/root-password-again password debian

d-i passwd/user-fullname string ace
d-i passwd/username string ace
d-i passwd/user-password password debian
d-i passwd/user-password-again password debian

d-i user-setup/allow-password-weak boolean true

d-i mirror/country string manual
d-i mirror/http/hostname string deb.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string

d-i partman/early_command string debconf-set partman-auto/disk "$(list-devices disk | head -n1)"
d-i partman-auto/method string regular
d-i partman-auto/choose_recipe select atomic
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-md/confirm boolean true
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

d-i grub-installer/only_debian boolean true
d-i grub-installer/bootdev string default

tasksel tasksel/first multiselect standard, ssh-server
d-i pkgsel/include string openssh-server sudo curl wget vim git ca-certificates qemu-guest-agent
d-i pkgsel/upgrade select none
popularity-contest popularity-contest/participate boolean false

d-i apt-setup/non-free-firmware boolean true

d-i finish-install/reboot_in_progress note
EOF

ok "preseed.cfg erstellt"

# ==============================
# ISO EXTRAHIEREN
# ==============================
info "Extrahiere ISO ..."
xorriso -osirrox on -indev "${ORIG_ISO}" -extract / "${ISODIR}" >/dev/null 2>&1
ok "ISO extrahiert"

# ==============================
# PRESEED IN ISO LEGEN
# ==============================
info "Kopiere preseed.cfg in ISO ..."
cp "${PRESEED_FILE}" "${ISODIR}/preseed.cfg"

# ==============================
# BIOS BOOTMENÜ ANPASSEN
# ==============================
if [[ -f "${ISODIR}/isolinux/txt.cfg" ]]; then
    info "Passe BIOS Bootmenü an ..."
    sed -i 's#--- quiet#auto=true priority=critical preseed/file=/cdrom/preseed.cfg --- quiet#g' "${ISODIR}/isolinux/txt.cfg"
fi

if [[ -f "${ISODIR}/isolinux/isolinux.cfg" ]]; then
    sed -i 's/^timeout.*/timeout 10/' "${ISODIR}/isolinux/isolinux.cfg" || true
fi

# ==============================
# UEFI BOOTMENÜ ANPASSEN
# ==============================
if [[ -f "${ISODIR}/boot/grub/grub.cfg" ]]; then
    info "Passe UEFI Bootmenü an ..."
    sed -i 's#--- quiet#auto=true priority=critical preseed/file=/cdrom/preseed.cfg --- quiet#g' "${ISODIR}/boot/grub/grub.cfg"
    sed -i 's/^set timeout=.*/set timeout=1/' "${ISODIR}/boot/grub/grub.cfg" || true
fi

# ==============================
# MD5SUMS AKTUALISIEREN
# ==============================
if [[ -f "${ISODIR}/md5sum.txt" ]]; then
    info "Aktualisiere md5sum.txt ..."
    (
        cd "${ISODIR}"
        find . -type f ! -name "md5sum.txt" -print0 | sort -z | xargs -0 md5sum > md5sum.txt
    )
    ok "md5sum.txt aktualisiert"
fi

# ==============================
# BOOTOPTIONEN DES ORIGINAL-ISOS ÜBERNEHMEN
# ==============================
info "Lese Boot-Parameter des Original-ISOs ..."
MKISOFS_OPTS="$(
    xorriso -indev "${ORIG_ISO}" -report_el_torito as_mkisofs 2>/dev/null \
    | tail -n +2 \
    | sed ':a;N;$!ba;s/\\\n/ /g'
)"

[[ -n "${MKISOFS_OPTS}" ]] || err "Konnte Boot-Parameter des Original-ISOs nicht ermitteln"

# ==============================
# AUTO-ISO BAUEN
# ==============================
info "Baue neue Auto-ISO ..."
rm -f "${AUTO_ISO}"

cd "${ISODIR}"

# shellcheck disable=SC2086
eval xorriso -as mkisofs ${MKISOFS_OPTS} -V "'Debian 12 Auto Server'" -o "'${AUTO_ISO}'" .

cd "${WORKDIR}"
[[ -f "${AUTO_ISO}" ]] || err "Auto-ISO wurde nicht erzeugt"
ok "Auto-ISO erstellt: ${AUTO_ISO}"

# ==============================
# USB DEVICE AUSWAHL
# ==============================
echo
warn "ALLE DATEN auf dem gewählten USB-Stick werden vollständig gelöscht!"
echo
info "Erkannte Datenträger:"
lsblk -d -o NAME,SIZE,MODEL,TRAN,TYPE
echo
echo "Beispiele:"
echo "  /dev/sdb"
echo "  /dev/sdc"
echo
read -rp "👉 Ziel-Device eingeben (z.B. /dev/sdb): " USB_DEVICE

[[ -b "${USB_DEVICE}" ]] || err "Ungültiges Block-Device: ${USB_DEVICE}"

ROOT_SOURCE="$(findmnt -n -o SOURCE / || true)"
ROOT_PARENT=""
if [[ -n "${ROOT_SOURCE}" ]]; then
    ROOT_PARENT="/dev/$(lsblk -no PKNAME "${ROOT_SOURCE}" 2>/dev/null || true)"
fi

if [[ -n "${ROOT_PARENT}" && "${USB_DEVICE}" == "${ROOT_PARENT}" ]]; then
    err "Abbruch: Zielgerät ist das aktuelle Systemlaufwerk (${ROOT_PARENT})"
fi

echo
info "Gewähltes Zielgerät:"
lsblk "${USB_DEVICE}"
echo
read -rp "⚠️ Wirklich ALLES auf ${USB_DEVICE} löschen und Auto-ISO schreiben? (JA eingeben): " CONFIRM
[[ "${CONFIRM}" == "JA" ]] || err "Abgebrochen"

# ==============================
# GEMOUNTETE PARTITIONEN AUSHÄNGEN
# ==============================
info "Hänge evtl. gemountete Partitionen aus ..."
mapfile -t PARTS < <(lsblk -ln -o NAME "${USB_DEVICE}" | tail -n +2 | sed 's#^#/dev/#')

if [[ "${#PARTS[@]}" -gt 0 ]]; then
    for part in "${PARTS[@]}"; do
        if mount | grep -q "^${part} "; then
            umount "${part}" || err "Konnte ${part} nicht aushängen"
        fi
    done
fi
ok "Partitionen ausgehängt"

# ==============================
# AUF USB SCHREIBEN
# ==============================
echo
info "Schreibe Auto-ISO bootfähig auf ${USB_DEVICE} ..."
dd if="${AUTO_ISO}" of="${USB_DEVICE}" bs="${BS}" status=progress oflag=sync conv=fsync
sync
ok "Auto-ISO erfolgreich auf USB geschrieben"

# ==============================
# ABSCHLUSS
# ==============================
echo
ok "FERTIG: Debian 12 Auto-Server-USB-Stick wurde erstellt"
echo
info "Login-Daten:"
echo "  root : debian"
echo "  ace  : debian"
echo
info "Hinweis:"
echo "  - automatische Installation löscht die erste erkannte Zielplatte"
echo "  - Desktop wird nicht installiert"
echo "  - SSH wird installiert"
echo
