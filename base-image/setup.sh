#!/bin/bash

############################
# 🌍 CONFIG (ANPASSBAR)
############################
TIMEZONE="Europe/Berlin"
LOCALE="de_DE.UTF-8"

echo "🚀 BASE IMAGE SETUP (PI4 / TRIXIE 64BIT)"
echo "🧠 CPU: $(uname -m)"
echo "💻 Hostname: $(hostname)"
echo "📅 Build: $(date)"
echo ""

############################
# 🔄 SYSTEM UPDATE
############################
echo "🔄 System Update..."
apt update -y && apt upgrade -y

############################
# 🧰 BASIS TOOLS
############################
echo "📦 Installiere Basis Tools..."
apt install -y \
sudo \
nano \
vim \
htop \
curl \
wget \
git \
unzip \
rsync \
cron \
net-tools \
dnsutils \
ca-certificates \
bash-completion

############################
# 🔐 SSH (SICHERSTELLEN)
############################
echo "🔐 Aktiviere SSH..."
systemctl enable ssh
systemctl start ssh

############################
# 🌍 LOCALE & TIMEZONE
############################
echo "🌍 Setze Locale & Timezone..."
echo "➡️ TIMEZONE: $TIMEZONE"
echo "➡️ LOCALE: $LOCALE"

timedatectl set-timezone $TIMEZONE

sed -i "s/^# $LOCALE/$LOCALE/" /etc/locale.gen
locale-gen

update-locale LANG=$LOCALE

dpkg-reconfigure -f noninteractive tzdata

############################
# 🖥️ HOSTNAME
############################
echo "🖥️ Setze Hostname..."
hostnamectl set-hostname raspberrypi

############################
# 🌐 NETWORK CHECK
############################
echo "🌐 Netzwerk Check..."
ip a

############################
# 📁 NAS MOUNT BASIS
############################
echo "📁 Erstelle Backup Mount..."
mkdir -p /mnt/raspi-backups

############################
# 🔧 NFS CLIENT
############################
echo "🔧 Installiere NFS Client..."
apt install -y nfs-common

############################
# 🔄 AUTO CLEAN
############################
echo "🧹 Cleanup..."
apt autoremove -y
apt clean

############################
# 🧠 WICHTIG: SYNC
############################
echo "💾 Sync..."
sync

############################
# ✅ DONE
############################
echo ""
echo "✅ BASE IMAGE FERTIG (PI4)"
echo "➡️ Jetzt BACKUP erstellen!"
echo ""
