#!/bin/bash

# ==========================================
# FullPageOS Tool: Restore Script (LOCAL)
# Author: topa-LE
# Repo: https://github.com/topa-LE/fullpageos-control
# ==========================================

set -euo pipefail

############################
# CONFIG
############################
BACKUP_DIR="/media/backup"
DATE=$(date +%F_%H-%M)

############################
# START
############################
echo "========================================"
echo " 🔄 FULLPAGEOS RESTORE"
echo "========================================"

############################
# ROOT CHECK
############################
[ "$(id -u)" -ne 0 ] && echo "❌ root erforderlich" && exit 1

############################
# BACKUPS SUCHEN
############################
echo "📦 Verfügbare Backups:"
BACKUPS=($(ls ${BACKUP_DIR}/*.img 2>/dev/null))

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo "❌ Keine Backups gefunden in $BACKUP_DIR"
    exit 1
fi

echo ""
select BACKUP_FILE in "${BACKUPS[@]}"; do
    [ -n "$BACKUP_FILE" ] && break
    echo "❌ Ungültige Auswahl"
done

echo "👉 Gewählt: $BACKUP_FILE"

############################
# DEVICE AUSWAHL
############################
echo ""
echo "📀 Verfügbare Geräte:"
lsblk -d -o NAME,SIZE,MODEL

read -p "👉 Zielgerät (z.B. sdb): " DEV
DEVICE="/dev/$DEV"

[ ! -b "$DEVICE" ] && echo "❌ Ungültiges Device" && exit 1

############################
# SICHERHEIT
############################
echo ""
echo "⚠️ IMAGE: $BACKUP_FILE"
echo "⚠️ ZIEL:  $DEVICE"
echo "⚠️ ALLE DATEN WERDEN GELÖSCHT!"
echo ""

read -p "❗ Zum Bestätigen 'RESTORE' eingeben: " CONFIRM
[ "$CONFIRM" != "RESTORE" ] && echo "❌ Abgebrochen" && exit 1

############################
# UNMOUNT
############################
echo "🔧 Unmount..."
umount ${DEVICE}* 2>/dev/null || true

############################
# RESTORE
############################
echo "💾 Restore läuft..."
dd if="$BACKUP_FILE" of="$DEVICE" bs=16M status=progress conv=fsync

############################
# VERIFY
############################
echo "🔍 Prüfe..."
sync
sleep 2
ls -lh "$BACKUP_FILE"

############################
# DONE
############################
echo ""
echo "========================================"
echo " ✅ RESTORE ERFOLGREICH"
echo "========================================"
echo "➡️ SD Karte einsetzen & booten"
