#!/usr/bin/env bash

echo "🐶 WATCHDOG MODUL START"

if ! dpkg -l | grep -q watchdog; then
    apt update -y
    apt install -y watchdog
fi

systemctl enable watchdog
systemctl restart watchdog

echo "✅ WATCHDOG AKTIV"
