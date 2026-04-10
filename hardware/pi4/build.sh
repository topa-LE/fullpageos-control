#!/bin/bash

echo "🚀 FULLPAGEOS KIOSK V1 BUILD (PI4 64BIT TRIXIE)"
echo "🧠 CPU: $(uname -m)"
echo "💻 Hostname: $(hostname)"
echo "📅 Build: $(date)"
echo ""

############################
# 🔧 VARIABLEN
############################
KIOSK_USER="kiosk"
KIOSK_HOME="/home/$KIOSK_USER"
START_URL="https://internet-artikel.de"
NEW_HOSTNAME="fullpageOS"

############################
# 🔄 SYSTEM UPDATE
############################
echo "🔄 System Update..."
apt update -y && apt upgrade -y

############################
# 📦 PAKETE
############################
echo "📦 Installiere Pakete..."
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
unattended-upgrades

############################
# 👤 USER
############################
echo "👤 Erstelle Kiosk User..."
if ! id "$KIOSK_USER" &>/dev/null; then
    useradd -m -s /bin/bash $KIOSK_USER
    echo "$KIOSK_USER:$KIOSK_USER" | chpasswd
    usermod -aG sudo $KIOSK_USER
fi

############################
# 🔐 AUTOLOGIN
############################
echo "🔐 Aktiviere Autologin..."
mkdir -p /etc/systemd/system/getty@tty1.service.d

cat <<EOF > /etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $KIOSK_USER --noclear %I \$TERM
EOF

############################
# 🖥️ PI4 CONFIG
############################
echo "🖥️ Setze PI4 Config..."

BOOT_CONFIG="/boot/config.txt"
[ -f /boot/firmware/config.txt ] && BOOT_CONFIG="/boot/firmware/config.txt"

cat <<EOF > $BOOT_CONFIG
dtparam=audio=on
camera_auto_detect=1
display_auto_detect=1

dtoverlay=vc4-kms-v3d

gpu_mem=256
max_framebuffers=2

hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=82
hdmi_drive=2

disable_overscan=1

[all]
EOF

############################
# 🧹 CHROMIUM RESET
############################
echo "🧹 Bereinige Chromium Profile..."
rm -rf $KIOSK_HOME/.config/chromium
rm -rf $KIOSK_HOME/.cache/*

############################
# ⚙️ OPENBOX AUTOSTART
############################
echo "⚙️ Setze Autostart..."
mkdir -p $KIOSK_HOME/.config/openbox

cat <<'EOF' > /home/kiosk/.config/openbox/autostart
#!/bin/bash

xrandr --output HDMI-1 --mode 1920x1080

xset s off
xset -dpms
xset s noblank

unclutter -idle 0 &

sleep 2

while true; do

URL=$(cat /home/kiosk/url.txt)

chromium \
--kiosk \
--start-fullscreen \
--noerrdialogs \
--disable-infobars \
--disable-session-crashed-bubble \
--disable-restore-session-state \
--no-first-run \
--disable-translate \
--disable-features=Translate,TranslateUI \
--disable-sync \
--disable-background-networking \
--disable-default-apps \
--disable-extensions \
--disable-prompt-on-repost \
--no-default-browser-check \
--disable-pinch \
--overscroll-history-navigation=0 \
--window-position=0,0 \
--window-size=1920,1080 \
--use-gl=egl \
--enable-gpu \
--ignore-gpu-blocklist \
"$URL"

sleep 2

done
EOF

chmod +x /home/kiosk/.config/openbox/autostart

############################
# 🧾 STARTX AUTOLOGIN
############################
echo "🧾 Setze Auto StartX..."

cat <<EOF > $KIOSK_HOME/.bash_profile

if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    startx /usr/bin/openbox-session
fi

EOF

############################
# 🌐 DEFAULT URL
############################
echo "$START_URL" > $KIOSK_HOME/url.txt

############################
# 🔐 RECHTE
############################
chown -R $KIOSK_USER:$KIOSK_USER $KIOSK_HOME

############################
# 🔄 HOSTNAME
############################
hostnamectl set-hostname $NEW_HOSTNAME

############################
# 📅 AUTO UPDATE
############################
systemctl enable apt-daily.timer

############################
# 💾 FINAL SYNC
############################
sync

############################
# ✅ DONE
############################
echo ""
echo "✅ FULLPAGEOS PI4 INSTALLIERT"
echo "➡️ REBOOT NOW"
echo ""
