#!/bin/bash
set -e

echo "📦 ODROID-C2 BASE SETUP START (FINAL)"

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
dbus \
dbus-x11 \
fonts-dejavu \
fonts-liberation \
fonts-freefont-ttf \
xserver-xorg-video-fbdev \
xserver-xorg-legacy

############################
# CHROMIUM (APT – STABIL)
############################
echo "🌐 Installiere Chromium..."
apt install -y chromium
echo "✅ Chromium installiert"

############################
# XORG FIX (ODROID C2)
############################
echo "🖥️ XORG Fix..."
mkdir -p /etc/X11/xorg.conf.d

cat <<EOF > /etc/X11/xorg.conf.d/99-odroid.conf
Section "Device"
    Identifier "ODROID"
    Driver "fbdev"
    Option "fbdev" "/dev/fb0"
EndSection
EOF

############################
# XWRAPPER FIX
############################
echo "🔐 Xwrapper Fix..."
cat <<EOF > /etc/X11/Xwrapper.config
allowed_users=anybody
needs_root_rights=yes
EOF

############################
# CHROMIUM POLICY (NO TRANSLATE)
############################
echo "🚫 Chromium Policy..."
mkdir -p /etc/chromium/policies/managed

cat <<EOF > /etc/chromium/policies/managed/kiosk.json
{
  "TranslateEnabled": false,
  "BrowserSignin": 0,
  "PasswordManagerEnabled": false,
  "CredentialsEnableService": false
}
EOF

############################
# DBUS AKTIVIEREN
############################
echo "🔌 DBUS aktivieren..."
systemctl enable dbus
systemctl start dbus

############################
# CPU PERFORMANCE MODE
############################
echo "🚀 CPU Performance Mode"
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance | tee $cpu || true
done

############################
# SYSTEM OPTIMIERUNG
############################
echo "⚙️ System Optimierung..."

# Swap reduzieren (SD schonen)
sysctl -w vm.swappiness=10
grep -q "vm.swappiness" /etc/sysctl.conf || echo "vm.swappiness=10" >> /etc/sysctl.conf

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
# CLEANUP
############################
echo "🧹 Cleanup..."
apt autoremove -y
apt clean

############################
# DONE
############################
echo "✅ BASE SETUP FERTIG (FINAL)"
