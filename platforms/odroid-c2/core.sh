#!/bin/bash
set -e

############################
# HEADER
############################
echo "🚀 FULLPAGEOS ODROID-C2 CORE (FINAL)"
echo "🧠 CPU: $(uname -m)"
echo "💻 Hostname: $(hostname)"
echo "📅 $(date)"
echo ""

############################
# GLOBALS (V5)
############################
DEVICE_ID=$(cat /etc/machine-id)
SERVER_URL="http://YOUR-SERVER:3000"
HEARTBEAT_INTERVAL=30
LOG_FILE="/var/log/fullpageos.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" | tee -a $LOG_FILE
}

############################
# MODULE CONFIG
############################
CONFIG_FILE="$(dirname "$0")/config/modules.conf"
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

WATCHDOG=${WATCHDOG:-false}
CLEANUP=${CLEANUP:-false}
AUTOUPDATE=${AUTOUPDATE:-false}
HOSTNAME=${HOSTNAME:-false}
LOGGING=${LOGGING:-false}
HEALTH=${HEALTH:-false}
AUTORESTART=${AUTORESTART:-false}

############################
# MODULE LOADER
############################
run_module() {
    MODULE_FILE="$(dirname "$0")/modules/$1.sh"
    [ -f "$MODULE_FILE" ] && bash "$MODULE_FILE"
}

############################
# GPU FIX (ODROID C2)
############################
export LIBGL_ALWAYS_SOFTWARE=1
export MESA_LOADER_DRIVER_OVERRIDE=llvmpipe

############################
# USER SETUP
############################
KIOSK_USER="kiosk"
KIOSK_HOME="/home/$KIOSK_USER"
URL_FILE="$KIOSK_HOME/url.txt"
START_URL="${START_URL:-https://internet-artikel.de}"

if ! id "$KIOSK_USER" &>/dev/null; then
    useradd -m -s /bin/bash $KIOSK_USER
    echo "$KIOSK_USER:$KIOSK_USER" | chpasswd
fi

usermod -aG video,tty,input $KIOSK_USER

############################
# HOSTNAME SETZEN
############################
NEW_HOSTNAME="fullpageOS"

echo "🖥️ Setze Hostname: $NEW_HOSTNAME"

hostnamectl set-hostname $NEW_HOSTNAME

# /etc/hosts fix
sed -i "s/127.0.1.1.*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts || true

############################
# AUTOLOGIN
############################
mkdir -p /etc/systemd/system/getty@tty1.service.d

cat <<EOF > /etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $KIOSK_USER --noclear %I \$TERM
EOF

############################
# URL FILE
############################
mkdir -p $KIOSK_HOME
echo "$START_URL" > $URL_FILE
chown $KIOSK_USER:$KIOSK_USER $URL_FILE
chmod 666 $URL_FILE

############################
# CHROMIUM RESET
############################
rm -rf $KIOSK_HOME/.config/chromium

############################
# XAUTH FIX
############################
touch $KIOSK_HOME/.Xauthority
chown $KIOSK_USER:$KIOSK_USER $KIOSK_HOME/.Xauthority

############################
# NETWORK CHECK + SELF HEAL
############################
check_network() {
    ping -c 1 1.1.1.1 >/dev/null 2>&1
}

self_heal() {
    log "🛠 Self-Heal gestartet"
    systemctl restart networking || true
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    rm -rf $KIOSK_HOME/.cache/chromium
}

############################
# API SERVER (FIXED)
############################
cat <<EOF > /usr/local/bin/kiosk-api.py
#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import os, urllib.parse

URL_FILE = "$URL_FILE"

class Handler(BaseHTTPRequestHandler):

    def do_GET(self):

        if self.path.startswith("/api/v1/url="):
            raw = self.path.split("=",1)[1]
            url = urllib.parse.unquote(raw)

            if not url.startswith("http"):
                self.send_response(400)
                self.end_headers()
                self.wfile.write(b"INVALID URL\\n")
                return

            with open(URL_FILE, "w") as f:
                f.write(url)

            os.system("pkill chromium")

            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK\\n")

        elif self.path == "/api/v1/status":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"RUNNING\\n")

        else:
            self.send_response(404)
            self.end_headers()

HTTPServer(("0.0.0.0", 3000), Handler).serve_forever()
EOF

chmod +x /usr/local/bin/kiosk-api.py

cat <<EOF > /etc/systemd/system/kiosk-api.service
[Unit]
Description=Kiosk API
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
# OPENBOX AUTOSTART
############################
mkdir -p $KIOSK_HOME/.config/openbox

cat <<EOF > $KIOSK_HOME/.config/openbox/autostart
#!/bin/bash

export DISPLAY=:0
export XAUTHORITY=/home/kiosk/.Xauthority

xset s off
xset -dpms
xset s noblank

unclutter -idle 0 &

sleep 2

while true; do

URL=\$(cat $URL_FILE)

chromium \
--no-sandbox \
--disable-gpu \
--disable-software-rasterizer \
--disable-dev-shm-usage \
--disable-infobars \
--disable-session-crashed-bubble \
--disable-translate \
--disable-features=Translate \
--disable-features=TranslateUI \
--disable-features=TranslateBubble \
--disable-features=LanguageDetection \
--disable-features=OptimizationHints \
--disable-features=MediaRouter \
--disable-component-update \
--disable-default-apps \
--disable-sync \
--disable-background-networking \
--disable-client-side-phishing-detection \
--disable-hang-monitor \
--disable-prompt-on-repost \
--disable-domain-reliability \
--disable-pinch \
--autoplay-policy=no-user-gesture-required \
--overscroll-history-navigation=0 \
--kiosk \
--incognito \
--no-first-run \
--window-position=0,0 \
--window-size=1920,1080 \
"\$URL" &

PID=\$!
wait \$PID

sleep 1

done
EOF

chmod +x $KIOSK_HOME/.config/openbox/autostart

############################
# STARTX AUTOLOGIN
############################
cat <<EOF > $KIOSK_HOME/.bash_profile
if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    startx /usr/bin/openbox-session
fi
EOF

############################
# PERMISSIONS
############################
chown -R $KIOSK_USER:$KIOSK_USER $KIOSK_HOME

############################
# MODULES (V5 READY)
############################
[ "$WATCHDOG" = true ] && run_module "watchdog"

############################
# DONE
############################
echo ""
echo "✅ CORE INSTALL FERTIG (FINAL)"
echo "➡️ REBOOT NOW"
echo ""
