#!/bin/bash
set -e

echo "📦 ODROID-C2 BASE SETUP START (DIETPI OPTIMIERT)"

############################
# SYSTEM UPDATE
############################
echo "🔄 System Update..."
apt update -y && apt upgrade -y

############################
# BASIS PACKAGES
############################
echo "📦 Installiere Basis Pakete..."

apt install -y \
xserver-xorg \
x11-xserver-utils \
xinit \
openbox \
unclutter \
python3 \
curl \
net-tools \
ca-certificates \
git \
wget \
sudo \
dbus-x11 \
fonts-dejavu \
fonts-liberation \
fonts-freefont-ttf

############################
# CHROMIUM (APT – STABIL)
############################
echo "🌐 Installiere Chromium (APT stabil)..."

apt install -y chromium

echo "✅ Chromium installiert"

############################
# SYSTEM CLEANUP
############################
echo "🧹 Cleanup..."
apt autoremove -y
apt clean

############################
# CPU PERFORMANCE MODE
############################
echo "🚀 Setze CPU auf Performance"
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance | tee $cpu || true
done

############################
# SYSTEM OPTIMIERUNG (ODROID C2 / DIETPI)
############################

echo "⚙️ System Optimierung..."

# Swap reduzieren (SD schonen)
sysctl -w vm.swappiness=10
echo "vm.swappiness=10" >> /etc/sysctl.conf

# Journald begrenzen
mkdir -p /etc/systemd/journald.conf.d

cat <<EOF > /etc/systemd/journald.conf.d/size.conf
[Journal]
SystemMaxUse=50M
RuntimeMaxUse=50M
EOF

systemctl restart systemd-journald

############################
# NETWORK STABILITÄT
############################
echo "🌐 Netzwerk Fix..."

cat <<EOF > /etc/resolv.conf
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF

############################
# DONE
############################
echo "✅ BASE SETUP FERTIG (DIETPI READY)"
