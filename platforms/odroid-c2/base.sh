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
chromium \
python3 \
curl \
net-tools \
ca-certificates

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
