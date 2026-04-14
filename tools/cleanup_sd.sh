#!/bin/bash

# ==========================================
# FullPageOS Tool: Cleanup Script
# Author: topa-LE
# Repo: https://github.com/topa-LE/fullpageos-control
# ==========================================

set -e

echo "========================================"
echo " 🧹 FullPageOS CLEANUP SCRIPT"
echo "========================================"
echo ""

read -p "⚠️ System für Backup bereinigen? (yes/no): " confirm
[ "$confirm" != "yes" ] && echo "❌ Abgebrochen" && exit 1

echo ""
echo "🚀 Cleanup startet..."

echo "[1/6] APT..."
apt clean
apt autoremove -y

echo "[2/6] Logs..."
journalctl --vacuum-time=1s || true
rm -rf /var/log/*.log
rm -rf /var/log/*/*.log

echo "[3/6] Temp..."
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /home/*/.cache/* 2>/dev/null || true

echo "[4/6] History..."
history -c || true
history -w || true

echo "[5/6] Zero Fill..."
dd if=/dev/zero of=/zero.fill bs=1M || true
sync
rm -f /zero.fill

echo "[6/6] Sync..."
sync

echo ""
echo "========================================"
echo " ✅ CLEANUP FERTIG"
echo "========================================"
echo "➡️ Jetzt: poweroff → Backup erstellen"
