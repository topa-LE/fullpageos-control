#!/usr/bin/env bash

echo "🔄 AUTOUPDATE MODUL START"

if ! dpkg -l | grep -q unattended-upgrades; then
    apt update -y
    apt install -y unattended-upgrades
fi

dpkg-reconfigure -f noninteractive unattended-upgrades

systemctl enable apt-daily.timer
systemctl enable apt-daily-upgrade.timer

echo "✅ AUTO-UPDATES AKTIV"
