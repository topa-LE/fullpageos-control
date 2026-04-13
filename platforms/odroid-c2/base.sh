#!/bin/bash
set -e

echo "📦 ODROID-C2 BASE SETUP START"

############################
# SYSTEM UPDATE
############################
apt update -y && apt upgrade -y

############################
# BASIS PACKAGES
############################
apt install -y \
xserver-xorg \
x11-xserver-utils \
xinit \
openbox \
unclutter \
python3 \
curl \
net-tools \
ca-certificates

############################
# CHROMIUM (SNAP – OPTIMIERT)
############################

echo "🌐 Installiere Chromium (Snap optimiert)"

# Snap installieren
apt install -y snapd

# Dienste aktivieren
systemctl enable snapd
systemctl start snapd

systemctl enable snapd.socket
systemctl start snapd.socket

# wichtig: warten bis snap ready ist
sleep 5

# core snap (Basis)
snap install core

# Chromium installieren
snap install chromium

echo "✅ Chromium (Snap) installiert"

snap set system refresh.timer=02:00-04:00

# Snap Performance Fix
snap set system refresh.retain=2

############################
# CLEANUP
############################
apt autoremove -y
apt clean

############################
# CPU PERFORMANCE MODE
############################
echo "🚀 Setze CPU auf Performance"
echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor || true

############################
# DONE
############################
echo "✅ BASE SETUP FERTIG"
