#!/bin/bash

clear

# 🧠 PI MODELL ERKENNEN
MODEL_RAW=$(tr -d '\0' < /proc/device-tree/model)

if [[ "$MODEL_RAW" == *"Raspberry Pi 2"* ]]; then
    PI_MODEL="Pi2"
    ARCH="32bit"
elif [[ "$MODEL_RAW" == *"Raspberry Pi 3"* ]]; then
    PI_MODEL="Pi3"
    ARCH="64bit"
elif [[ "$MODEL_RAW" == *"Raspberry Pi 4"* ]]; then
    PI_MODEL="Pi4"
    ARCH="64bit"
elif [[ "$MODEL_RAW" == *"Raspberry Pi 5"* ]]; then
    PI_MODEL="Pi5"
    ARCH="64bit"
else
    PI_MODEL="UNKNOWN"
    ARCH="$(uname -m)"
fi

# 🚀 HEADER
echo "🚀 BASE IMAGE SETUP (${PI_MODEL} / TRIXIE ${ARCH})"
echo "🧠 CPU: $(uname -m)"
echo "💻 Hostname: $(hostname)"
echo "📅 Build: $(date)"
echo ""

# 🧠 SYSTEM UPDATE
echo "🔄 System Update..."
apt update -y && apt upgrade -y


# 🌍 LOCALES
echo "🌍 Setze Locale..."
sed -i 's/^# *de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
update-locale LANG=de_DE.UTF-8

# 🕒 TIMEZONE
echo "🕒 Setze Zeitzone..."
timedatectl set-timezone Europe/Berlin

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
htop \
curl \
wget \
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
echo "✅ BASE IMAGE FERTIG"
echo "➡️ Jetzt BACKUP erstellen!"
echo ""
