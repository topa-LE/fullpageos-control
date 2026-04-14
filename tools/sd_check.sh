#!/bin/bash

# ==========================================
# FullPageOS Tool: SD Check Script
# Author: topa-LE
# Repo: https://github.com/topa-LE/fullpageos-control
# ==========================================

echo "🧪 SD CARD CHECK"

lsblk -d -o NAME,SIZE,MODEL
read -p "Device (z.B. sdb): " DEV

DEVICE="/dev/$DEV"

[ ! -b "$DEVICE" ] && echo "❌ Device fehlt" && exit 1

echo "🔍 FSCK..."
fsck -fy ${DEVICE}1 || true
fsck -fy ${DEVICE}2 || true

echo "🧪 Write Test..."
mount ${DEVICE}2 /mnt 2>/dev/null || true

touch /mnt/testfile && echo "OK" || echo "FAIL"

rm -f /mnt/testfile
umount /mnt 2>/dev/null || true

echo "✅ Check fertig"
