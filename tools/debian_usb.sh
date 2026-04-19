#!/bin/bash
# ==========================================
# Script: usb_boot_stick_debian_12_13_lite_server.sh
# Author: topa-LE
# Repo  : https://github.com/topa-LE
# Zweck : Debian 12 oder Debian 13 Netinst ISO
#         herunterladen, prüfen und bootfähig
#         auf USB-Stick flashen
# ==========================================

set -euo pipefail

# ==============================
# KONFIGURATION
# ==============================
ARCH="amd64"
WORKDIR="/home/build/debian_usb_boot"
BS="4M"

# Debian 12 Bookworm
DEB12_VERSION="12.13.0"
DEB12_NAME="Debian 12 Bookworm"
DEB12_ISO="debian-${DEB12_VERSION}-${ARCH}-netinst.iso"
DEB12_BASE_URL="https://cdimage.debian.org/cdimage/archive/${DEB12_VERSION}/${ARCH}/iso-cd"
DEB12_ISO_URL="${DEB12_BASE_URL}/${DEB12_ISO}"
DEB12_SHA_URL="${DEB12_BASE_URL}/SHA256SUMS"

# Debian 13 Trixie
DEB13_VERSION="13.1.0"
DEB13_NAME="Debian 13 Trixie"
DEB13_ISO="debian-${DEB13_VERSION}-${ARCH}-netinst.iso"
DEB13_BASE_URL="https://cdimage.debian.org/debian-cd/current/${ARCH}/iso-cd"
DEB13_ISO_URL="${DEB13_BASE_URL}/${DEB13_ISO}"
DEB13_SHA_URL="${DEB13_BASE_URL}/SHA256SUMS"

# ==============================
# FARBEN / AUSGABEN
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
    err "Bitte als root ausführen: sudo bash /home/build/usb_boot_stick_debian_12_13_lite_server.sh"
fi

# ==============================
# TOOLS CHECK
# ==============================
for cmd in wget sha256sum lsblk dd sync awk grep sed findmnt umount; do
    command -v "${cmd}" >/dev/null 2>&1 || err "Benötigtes Tool fehlt: ${cmd}"
done

# ==============================
# HEADER
# ==============================
clear
echo "=========================================="
echo "🚀 Debian USB Boot Stick Creator"
echo "💽 Build-Server Flash Tool"
echo "📁 Arbeitsverzeichnis: ${WORKDIR}"
echo "🧠 Architektur       : ${ARCH}"
echo "=========================================="
echo

# ==============================
# ARBEITSVERZEICHNIS
# ==============================
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ==============================
# MENÜ
# ==============================
echo "Bitte Debian-Version wählen:"
echo
echo "  1) ${DEB12_NAME} (${DEB12_VERSION})"
echo "  2) ${DEB13_NAME} (${DEB13_VERSION})"
echo
read -rp "👉 Auswahl [1-2]: " CHOICE

case "${CHOICE}" in
    1)
        DISTRO_NAME="${DEB12_NAME}"
        DISTRO_VERSION="${DEB12_VERSION}"
        ISO_NAME="${DEB12_ISO}"
        ISO_URL="${DEB12_ISO_URL}"
        SHA_URL="${DEB12_SHA_URL}"
        ;;
    2)
        DISTRO_NAME="${DEB13_NAME}"
        DISTRO_VERSION="${DEB13_VERSION}"
        ISO_NAME="${DEB13_ISO}"
        ISO_URL="${DEB13_ISO_URL}"
        SHA_URL="${DEB13_SHA_URL}"
        ;;
    *)
        err "Ungültige Auswahl"
        ;;
esac

echo
info "Gewählt     : ${DISTRO_NAME}"
info "Version     : ${DISTRO_VERSION}"
info "ISO         : ${ISO_NAME}"
info "Download    : ${ISO_URL}"
echo

# ==============================
# ISO DOWNLOAD
# ==============================
if [[ -f "${ISO_NAME}" ]]; then
    ok "ISO bereits vorhanden: ${ISO_NAME}"
else
    info "Lade ISO herunter ..."
    wget -O "${ISO_NAME}" "${ISO_URL}"
    ok "ISO erfolgreich geladen"
fi

# ==============================
# SHA256 DOWNLOAD
# ==============================
info "Lade SHA256SUMS ..."
wget -O SHA256SUMS "${SHA_URL}"
ok "SHA256SUMS geladen"

# ==============================
# SHA256 PRÜFUNG
# ==============================
info "Prüfe SHA256 ..."
grep " ${ISO_NAME}$" SHA256SUMS > SHA256SUMS.iso || err "Eintrag für ISO in SHA256SUMS nicht gefunden"
sha256sum -c SHA256SUMS.iso || err "SHA256-Prüfung fehlgeschlagen"
ok "SHA256-Prüfung erfolgreich"

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
read -rp "⚠️ Wirklich ALLES auf ${USB_DEVICE} löschen und ${DISTRO_NAME} bootfähig schreiben? (JA eingeben): " CONFIRM
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
# FLASHEN
# ==============================
echo
info "Schreibe ${DISTRO_NAME} bootfähig auf ${USB_DEVICE} ..."
dd if="${ISO_NAME}" of="${USB_DEVICE}" bs="${BS}" status=progress oflag=sync conv=fsync
sync
ok "ISO erfolgreich auf USB geschrieben"

# ==============================
# ABSCHLUSS
# ==============================
echo
ok "FERTIG: Bootfähiger USB-Stick wurde erstellt"
echo
info "Details:"
echo "  Distribution : ${DISTRO_NAME}"
echo "  Version      : ${DISTRO_VERSION}"
echo "  ISO          : ${ISO_NAME}"
echo "  Zielgerät    : ${USB_DEVICE}"
echo
info "Nächste Schritte:"
echo "  1) USB-Stick sicher entfernen"
echo "  2) Zielsystem auf USB-Boot / UEFI stellen"
echo "  3) Debian installieren"
echo
