#!/bin/bash
set -e

############################
# HEADER
############################
echo "🚀 FULLPAGEOS MASTER CORE"
echo "🚀 FULLPAGEOS KIOSK V1 BUILD (${PI_MODEL^^} TRIXIE)"
echo "🧠 CPU: $(uname -m)"
echo "💻 Hostname: $(hostname)"
echo "🖥️ MODEL: $PI_MODEL"
echo "📅 $(date)"
echo ""

############################
# V5 GLOBALS
############################
DEVICE_ID=$(cat /etc/machine-id)
SERVER_URL="http://YOUR-SERVER:3000"
HEARTBEAT_INTERVAL=30
LOG_FILE="/var/log/fullpageos.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" | tee -a $LOG_FILE
}

############################
# MODULE CONFIG LADEN
############################
CONFIG_FILE="$(dirname "$0")/../config/modules.conf"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "⚠️ modules.conf nicht gefunden – verwende defaults"
fi

# 🔒 DEFAULTS (WICHTIG!)
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
    MODULE_NAME=$1
    MODULE_FILE="$(dirname "$0")/../modules/$MODULE_NAME.sh"

    if [ -f "$MODULE_FILE" ]; then
        echo "🔧 Lade Modul: $MODULE_NAME"
        bash "$MODULE_FILE"
    else
        echo "⚠️ Modul fehlt: $MODULE_NAME"
    fi
}

############################
# VARS
############################
KIOSK_USER="kiosk"
KIOSK_HOME="/home/$KIOSK_USER"
URL_FILE="$KIOSK_HOME/url.txt"
START_URL="https://internet-artikel.de"

############################
# SYSTEM
############################
apt update -y && apt upgrade -y

############################
# PACKAGES
############################
apt install -y \
xserver-xorg \
x11-xserver-utils \
xinit \
openbox \
unclutter \
chromium \
python3

############################
# USER
############################
if ! id "$KIOSK_USER" &>/dev/null; then
    useradd -m -s /bin/bash $KIOSK_USER
    echo "$KIOSK_USER:$KIOSK_USER" | chpasswd
fi

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
# 🔥 CONFIG.TXT FULL OVERWRITE (V5)
############################

BOOT_CONFIG="/boot/config.txt"
[ -f /boot/firmware/config.txt ] && BOOT_CONFIG="/boot/firmware/config.txt"

echo "🧠 Schreibe optimierte config.txt für $PI_MODEL → $BOOT_CONFIG"

cat <<EOF > $BOOT_CONFIG
############################################
# FULLPAGEOS OPTIMIZED CONFIG
############################################

[all]
disable_overscan=1
dtparam=audio=off
hdmi_force_hotplug=1
hdmi_drive=2

############################################
# PI2 / PI3 (LEGACY FKMS)
############################################
[pi2]
dtoverlay=vc4-fkms-v3d
gpu_mem=128

[pi3]
dtoverlay=vc4-fkms-v3d
gpu_mem=128

############################################
# PI4 (KMS)
############################################
[pi4]
dtoverlay=vc4-kms-v3d
max_framebuffers=2
gpu_mem=256

############################################
# PI5 (NEXT GEN)
############################################
[pi5]
dtoverlay=vc4-kms-v3d
max_framebuffers=2

EOF

############################
# URL + RECHTE (FIXED)
############################
mkdir -p $KIOSK_HOME
echo "$START_URL" > $URL_FILE
chown $KIOSK_USER:$KIOSK_USER $URL_FILE
chmod 666 $URL_FILE

############################
# CHROMIUM POLICY
############################
mkdir -p /etc/chromium/policies/managed

cat <<EOF > /etc/chromium/policies/managed/kiosk.json
{
  "TranslateEnabled": false
}
EOF

############################
# PROFILE RESET (WICHTIG!)
############################
rm -rf $KIOSK_HOME/.config/chromium

############################
# XAUTH FIX (WICHTIG!)
############################
touch $KIOSK_HOME/.Xauthority
chown $KIOSK_USER:$KIOSK_USER $KIOSK_HOME/.Xauthority

############################
# V5 FUNCTIONS
############################

check_network() {
    ping -c 1 1.1.1.1 >/dev/null 2>&1
}

self_heal() {
    log "🛠 Self-Heal gestartet"
    systemctl restart networking || true
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    rm -rf $KIOSK_HOME/.cache/chromium
    log "✅ Self-Heal fertig"
}

watchdog_loop() {
    while true; do
        if ! pgrep -x "chromium" >/dev/null; then
            log "❌ Chromium nicht aktiv -> Openbox Loop übernimmt Restart"
        fi
        sleep 10
    done
}

heartbeat_loop() {
    while true; do
        STATUS="online"
        check_network || STATUS="offline"

        curl -s -X POST "$SERVER_URL/api/heartbeat" \
        -H "Content-Type: application/json" \
        -d "{\"device_id\":\"$DEVICE_ID\",\"status\":\"$STATUS\"}" >/dev/null || true

        sleep $HEARTBEAT_INTERVAL
    done
}

remote_loop() {
    while true; do

        CMD=$(curl -s "$SERVER_URL/api/command/$DEVICE_ID" || echo "")

        case "$CMD" in
            reboot) reboot ;;
            self_heal) self_heal ;;
            restart) pkill chromium ;;
        esac

        sleep 10
    done
}

############################
# API SERVER (FINAL)
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
                return

            with open(URL_FILE, "w") as f:
                f.write(url)

            os.system("pkill chromium")

            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK RELOAD AND URL UPDATED\\n")

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
# AUTOSTART (OPENBOX)
############################
mkdir -p $KIOSK_HOME/.config/openbox

cat <<EOF > $KIOSK_HOME/.config/openbox/autostart
#!/bin/bash

export DISPLAY=:0
export XAUTHORITY=/home/kiosk/.Xauthority

xrandr --auto

xset s off
xset -dpms
xset s noblank

unclutter -idle 0 &

sleep 2

while true; do

URL=\$(cat $URL_FILE)

chromium \
--no-sandbox \
--disable-dev-shm-usage \
--kiosk \
--start-fullscreen \
--noerrdialogs \
--disable-infobars \
--disable-session-crashed-bubble \
--disable-restore-session-state \
--no-first-run \
--disable-translate \
--disable-features=Translate \
--disable-features=TranslateUI \
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
# MODULE SYSTEM
############################

[ "$WATCHDOG" = true ] && run_module "watchdog"
[ "$CLEANUP" = true ] && run_module "cleanup"
[ "$AUTOUPDATE" = true ] && run_module "autoupdate"
[ "$HOSTNAME" = true ] && run_module "hostname"
[ "$LOGGING" = true ] && run_module "logging"
[ "$HEALTH" = true ] && run_module "health"
[ "$AUTORESTART" = true ] && run_module "autorestart"

############################
# V5 BACKGROUND SERVICES
############################
watchdog_loop &
heartbeat_loop &
remote_loop &

############################
# DONE
############################
echo ""
echo "✅ FULLPAGEOS CORE INSTALL FERTIG"
echo "➡️ REBOOT NOW"
echo ""
