#!/bin/bash
set -euo pipefail

echo "========================================"
echo "🔧 SD CARD EXPAND TOOL (POST-RESTORE)"
echo "========================================"

DEVICE="/dev/sdb"

#####################################
# ROOT CHECK
#####################################
if [ "$(id -u)" -ne 0 ]; then
  echo "❌ Bitte als root ausführen"
  exit 1
fi

#####################################
# DEVICE CHECK
#####################################
if [ ! -b "$DEVICE" ]; then
  echo "❌ Device nicht gefunden: $DEVICE"
  exit 1
fi

echo
echo "⚠️ ZIELGERÄT:"
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,MODEL "$DEVICE"

echo
read -r -p "Wirklich $DEVICE erweitern? (ja/nein): " CONFIRM
if [ "$CONFIRM" != "ja" ]; then
  echo "❌ Abgebrochen"
  exit 1
fi

#####################################
# UNMOUNT
#####################################
echo
echo "📦 Partitionen aushängen..."
for part in ${DEVICE}?*; do
  [ -b "$part" ] && umount "$part" 2>/dev/null || true
done

#####################################
# ROOT PARTITION
#####################################
ROOT_PART="${DEVICE}2"

if [ ! -b "$ROOT_PART" ]; then
  echo "❌ Root-Partition nicht gefunden: $ROOT_PART"
  exit 1
fi

echo "✅ Root-Partition: $ROOT_PART"

#####################################
# TOOLS
#####################################
echo
echo "📦 Tools installieren..."
apt update
apt install -y cloud-guest-utils e2fsprogs parted

#####################################
# EXPAND
#####################################
echo
echo "🚀 Partition 2 erweitern..."
growpart "$DEVICE" 2

#####################################
# FILESYSTEM CHECK + EXPAND
#####################################
echo
echo "🧹 Dateisystem prüfen..."
e2fsck -f -y "$ROOT_PART"

echo
echo "📏 Dateisystem erweitern..."
resize2fs "$ROOT_PART"

#####################################
# FINAL
#####################################
sync

echo
echo "========================================"
echo "✅ SD CARD EXPAND ERFOLGREICH"
echo "========================================"
echo "➡️ SD-Karte kann jetzt direkt in den Pi"
echo
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT "$DEVICE"
