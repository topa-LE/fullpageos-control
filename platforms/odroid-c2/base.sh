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
# CHROMIUM (ODROID FIX – NO SNAP)
############################

echo "🌐 Installiere Chromium (DEB Version für Odroid)"

apt install -y wget

cd /tmp

# Chromium Version (fixiert für Stabilität)
wget https://launchpad.net/~chromium-team/+archive/ubuntu/stable/+files/chromium-browser_114.0.5735.90-0ubuntu0.20.04.1_arm64.deb

# Installation
apt install -y ./chromium-browser_*.deb

# Cleanup
rm -f chromium-browser_*.deb

echo "✅ Chromium (DEB) installiert"


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
