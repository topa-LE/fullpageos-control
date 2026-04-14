#!/bin/bash

# ==========================================
# FullPageOS Tool: Flash Script
# Author: topa-LE
# Repo: https://github.com/topa-LE/fullpageos-control
# ==========================================

set -e

echo "🚀 FullPageOS Universal Flash Tool"

IMAGES=($(ls *.img* 2>/dev/null))
[ ${#IMAGES[@]} -eq 0 ] && echo "❌ Keine Images gefunden" && exit 1

echo ""
select IMAGE in "${IMAGES[@]}"; do
    [ -n "$IMAGE" ] && break
done

echo "👉 Image: $IMAGE"

echo ""
echo "📀 Geräte:"
lsblk -d -o NAME,SIZE,MODEL

read -p "👉 Device (z.B. sdb): " DEV
DEVICE="/dev/$DEV"

[ ! -b "$DEVICE" ] && echo "❌ Ungültig" && exit 1

echo "⚠️ $DEVICE wird überschrieben!"
read -p "FLASH eingeben: " CONFIRM
[ "$CONFIRM" != "FLASH" ] && exit 1

umount ${DEVICE}* 2>/dev/null || true

if [[ "$IMAGE" == *.xz ]]; then
    xzcat "$IMAGE" | dd of="$DEVICE" bs=4M status=progress conv=fsync
else
    dd if="$IMAGE" of="$DEVICE" bs=4M status=progress conv=fsync
fi

sync

echo "✅ FLASH OK"
