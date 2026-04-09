#!/bin/bash

echo "🚀 FULLPAGEOS KIOSK V3 FINAL (PI3 64BIT TRIXIE)"

############################
# 🔧 VARIABLEN
############################
KIOSK_USER="kiosk"
KIOSK_HOME="/home/$KIOSK_USER"
START_URL="https://internet-artikel.de"
API_PORT="3000"
NEW_HOSTNAME="fullpageOS"

############################
# 🔄 SYSTEM
############################
apt update -y && apt upgrade -y

############################
# 📦 PAKETE
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
hostname \
unattended-upgrades \
cron

############################
# 👤 USER
############################
if ! id "$KIOSK_USER" &>/dev/null; then
    useradd -m -s /bin/bash $KIOSK_USER
    echo "$KIOSK_USER:$KIOSK_USER" | chpasswd
    usermod -aG sudo $KIOSK_USER
fi

############################
# 🔐 AUTOLOGIN
############################
mkdir -p /etc/systemd/system/getty@tty1.service.d

cat <<EOF > /etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $KIOSK_USER --noclear %I \$TERM
EOF

############################
# 🖥️ PI3 CONFIG (FULL REPLACE)
############################
BOOT_CONFIG="/boot/config.txt"
[ -f /boot/firmware/config.txt ] && BOOT_CONFIG="/boot/firmware/config.txt"

PI_MODEL=$(tr -d '\0' < /proc/device-tree/model)

echo "🔍 Gerät: $PI_MODEL"

if echo "$PI_MODEL" | grep -q "Raspberry Pi 3"; then

cat <<'EOF' > $BOOT_CONFIG
dtparam=audio=on
camera_auto_detect=1
display_auto_detect=1

dtoverlay=vc4-kms-v3d

gpu_mem=128
max_framebuffers=2

hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=82

disable_overscan=1

arm_boost=1
boot_delay=1

[all]
EOF

fi

############################
# 🖥️ X11 FIX
############################
mkdir -p /etc/X11/xorg.conf.d

cat <<EOF > /etc/X11/xorg.conf.d/10-monitor.conf
Section "Monitor"
    Identifier "HDMI-1"
    Option "PreferredMode" "1920x1080"
EndSection
EOF

############################
# 🔒 CHROMIUM POLICY
############################
mkdir -p /etc/chromium/policies/managed

cat <<EOF > /etc/chromium/policies/managed/kiosk.json
{
  "TranslateEnabled": false,
  "TranslateUIEnabled": false
}
EOF

############################
# 🧹 PROFILE RESET
############################
rm -rf $KIOSK_HOME/.config/chromium

############################
# ⚙️ OPENBOX AUTOSTART
############################
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
    --disable-features=Translate,TranslateUI,OptimizationHints \
    --lang=de-DE \
    --disable-sync \
    --disable-background-networking \
    --disable-default-apps \
    --disable-extensions \
    --disable-component-update \
    --disable-prompt-on-repost \
    --no-default-browser-check \
    --disable-pinch \
    --overscroll-history-navigation=0 \
    --window-position=0,0 \
    --window-size=1920,1080 \
    "$URL"

    sleep 2

done
EOF

chmod +x /home/kiosk/.config/openbox/autostart

############################
# 🧾 STARTX
############################
cat <<EOF > $KIOSK_HOME/.bash_profile

if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    startx /usr/bin/openbox-session
fi

EOF

############################
# 🌐 URL DEFAULT
############################
echo "$START_URL" > $KIOSK_HOME/url.txt

############################
# 🔐 RECHTE
############################
chown -R $KIOSK_USER:$KIOSK_USER $KIOSK_HOME

############################
# 🌐 API (FIXED VERSION)
############################
cat <<'EOF' > /usr/local/bin/kiosk-api.py
#!/usr/bin/env python3

from http.server import BaseHTTPRequestHandler, HTTPServer
import os, json, urllib.parse

PORT = 3000
URL_FILE = "/home/kiosk/url.txt"

class Handler(BaseHTTPRequestHandler):

    def do_GET(self):
        path = self.path

        if path.startswith("/api/v1"):
            path = path.replace("/api/v1","",1)

        # 🔥 FIX: sauberes URL Handling
        if path.startswith("/url="):
            raw = path.split("=",1)[1]

            # URL sauber decodieren
            url = urllib.parse.unquote(raw)

            # Validierung (minimal)
            if not url.startswith("http"):
                return self._json({"error":"invalid url"})

            open(URL_FILE,"w").write(url)
            os.system("pkill chromium")

            return self._json({"status":"updated","url":url})

        elif path == "/reload":
            os.system("pkill chromium")
            return self._json({"status":"reloaded"})

        elif path == "/status":
            url = open(URL_FILE).read().strip()
            return self._json({"status":"ok","url":url})

        elif path == "/health":
            r=os.system("pgrep chromium > /dev/null")
            return self._json({"status":"ok","chromium":"running" if r==0 else "stopped"})

        elif path == "/reboot":
            self._json({"status":"rebooting"})
            os.system("reboot")

        else:
            return self._json({"service":"kiosk-api","version":"v3.0"})

    def _json(self,data):
        self.send_response(200)
        self.send_header("Content-Type","application/json")
        self.end_headers()
        self.wfile.write((json.dumps(data,indent=2)+"\n").encode())

    def log_message(self,*args):
        return

HTTPServer(("",PORT),Handler).serve_forever()
EOF

chmod +x /usr/local/bin/kiosk-api.py

############################
# 🔁 SERVICE
############################
cat <<EOF > /etc/systemd/system/kiosk-api.service
[Unit]
Description=Kiosk API V3
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/kiosk-api.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kiosk-api
systemctl restart kiosk-api

############################
# ✅ HOSTNAME
############################
hostnamectl set-hostname $NEW_HOSTNAME
echo $NEW_HOSTNAME > /etc/hostname
sed -i 's/127.0.1.1.*/127.0.1.1\t'$NEW_HOSTNAME'/' /etc/hosts

############################
# 📅 AUTO UPDATE
############################
apt install -y unattended-upgrades
systemctl enable apt-daily.timer
systemctl start apt-daily.timer

############################
# ✅ DONE
############################
echo ""
echo "✅ FULLPAGEOS PI3 FINAL V3 INSTALLIERT"
echo "🌐 URL: $START_URL"
echo ""
echo "➡️ REBOOT NOW"
