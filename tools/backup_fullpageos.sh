#!/bin/bash

# ==========================================
# FullPageOS Tool: Backup Script (LOCAL)
# Author: topa-LE
# Repo: https://github.com/topa-LE/fullpageos-control
# ==========================================

set -euo pipefail

############################
# CONFIG
############################
BACKUP_DIR="/media/backup"
DEVICE="/dev/sdb"

HOSTNAME=$(hostname)
DATE=$(date +%F_%H-%M)

BACKUP_FILE="${BACKUP_DIR}/${HOSTNAME}_${DATE}.img"
LOGFILE="${BACKUP_DIR}/${HOSTNAME}_${DATE}.log"

RETENTION=3
LOCKFILE="/tmp/fullpageos_backup.lock"

############################
# START
############################
echo "========================================"
echo " 💾 FULLPAGEOS BACKUP (LOCAL)"
echo "========================================"

############################
# ROOT CHECK
############################
[ "$(id -u)" -ne 0 ] && echo "❌ root erforderlich" && exit 1

############################
# LOCK
############################
if [ -f "$LOCKFILE" ]; then
    echo "❌ Backup läuft bereits!"
    exit 1
fi

touch "$LOCKFILE"
trap 'rm -f "$LOCKFILE"' EXIT

############################
# DIR CHECK
############################
mkdir -p "$BACKUP_DIR"

############################
# DEVICE CHECK
############################
echo "🔍 Device prüfen..."
[ ! -b "$DEVICE" ] && echo "❌ Device fehlt: $DEVICE" && exit 1

############################
# FREE SPACE CHECK
############################
echo "🔍 Speicher prüfen..."
FREE_GB=$(df -BG "$BACKUP_DIR" | awk 'NR==2 {print $4}' | sed 's/G//')

if [ "$FREE_GB" -lt 8 ]; then
    echo "❌ Zu wenig Speicher (mind. 8GB empfohlen)"
    exit 1
fi

############################
# LOGGING
############################
exec > >(tee -a "$LOGFILE") 2>&1

echo "📊 Systemstatus:"
df -h

############################
# BACKUP
############################
echo "💾 Backup läuft..."
dd if="$DEVICE" of="$BACKUP_FILE" bs=16M status=progress conv=fsync

############################
# VERIFY
############################
echo "🔍 Verify..."
[ ! -f "$BACKUP_FILE" ] && echo "❌ Backup fehlgeschlagen" && exit 1
ls -lh "$BACKUP_FILE"

############################
# ROTATION
############################
echo "♻️ Alte Backups löschen..."
cd "$BACKUP_DIR"

ls -t "${HOSTNAME}"_*.img 2>/dev/null | tail -n +$((RETENTION+1)) | xargs -r rm -f

############################
# FINAL
############################
sync

echo ""
echo "========================================"
echo " ✅ BACKUP ERFOLGREICH"
echo "========================================"
echo "📁 Datei: $BACKUP_FILE"
