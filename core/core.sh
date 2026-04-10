#!/bin/bash

echo "🧠 CORE SETUP"

############################
# SYSTEM UPDATE
############################
apt update -y && apt upgrade -y

############################
# BASIS PAKETE
############################
apt install -y \
xserver-xorg \
x11-xserver-utils \
xinit \
openbox \
unclutter \
chromium \
curl \
sudo \
python3 \
xserver-xorg-video-fbdev \
unattended-upgrades \
cron

############################
# USER
############################
if ! id "kiosk" &>/dev/null; then
    useradd -m -s /bin/bash kiosk
    echo "kiosk:kiosk" | chpasswd
    usermod -aG sudo kiosk
fi

############################
# AUTOLOGIN
############################
mkdir -p /etc/systemd/system/getty@tty1.service.d

cat <<EOF > /etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin kiosk --noclear %I \$TERM
EOF

############################
# CHROMIUM POLICY
############################
mkdir -p /etc/chromium/policies/managed

cat <<EOF > /etc/chromium/policies/managed/kiosk.json
{
  "TranslateEnabled": false,
  "TranslateUIEnabled": false
}
EOF
