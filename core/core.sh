#!/bin/bash

echo "🚀 FULLPAGEOS MASTER CORE"
echo "🚀 FULLPAGEOS KIOSK V1 BUILD (${PI_MODEL^^} TRIXIE)"
echo "🧠 CPU: $(uname -m)"
echo "🖥️ MODEL: $PI_MODEL"
echo "📅 $(date)"
echo ""

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
# HARDWARE CONFIG
############################
BOOT_CONFIG="/boot/config.txt"
[ -f /boot/firmware/config.txt ] && BOOT_CONFIG="/boot/firmware/config.txt"

if [ "$PI_MODEL" == "pi4" ] || [ "$PI_MODEL" == "pi5" ]; then

cat <<EOF > $BOOT_CONFIG
dtoverlay=vc4-kms-v3d
gpu_mem=256
hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=82
hdmi_drive=2
disable_overscan=1
EOF

fi

############################
# URL
############################
echo "$START_URL" > $URL_FILE

############################
# API
############################
cat <<EOF > $KIOSK_HOME/api_server.py
from http.server import BaseHTTPRequestHandler, HTTPServer
import os

URL_FILE = "$URL_FILE"

class Handler(BaseHTTPRequestHandler):

    def do_GET(self):

        if self.path.startswith("/api/v1/url="):
            new_url = self.path.split("=",1)[1]

            with open(URL_FILE, "w") as f:
                f.write(new_url)

            os.system("pkill -f chromium")

            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK RELOAD\n")

        elif self.path == "/api/v1/status":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"RUNNING\n")

        else:
            self.send_response(404)
            self.end_headers()

HTTPServer(("0.0.0.0", 3000), Handler).serve_forever()
EOF

############################
# AUTOSTART
############################
mkdir -p $KIOSK_HOME/.config/openbox

cat <<EOF > $KIOSK_HOME/.config/openbox/autostart
#!/bin/bash

export DISPLAY=:0
export XAUTHORITY=/home/kiosk/.Xauthority

python3 $KIOSK_HOME/api_server.py &

xrandr --auto

xset s off
xset -dpms
xset s noblank

unclutter -idle 0 &

sleep 2

while true; do

URL=\$(cat $URL_FILE)

chromium \\
--no-sandbox \\
--disable-dev-shm-usage \\
--kiosk \\
--start-fullscreen \\
--noerrdialogs \\
--disable-infobars \\
--disable-session-crashed-bubble \\
--no-first-run \\
--disable-translate \\
--disable-features=Translate \\
--disable-pinch \\
--overscroll-history-navigation=0 \\
--window-position=0,0 \\
--window-size=1920,1080 \\
"\$URL" &

PID=\$!
wait \$PID

sleep 1

done
EOF

chmod +x $KIOSK_HOME/.config/openbox/autostart

############################
# STARTX
############################
cat <<EOF > $KIOSK_HOME/.bash_profile
if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    startx
fi
EOF

############################
# PERMS
############################
chown -R $KIOSK_USER:$KIOSK_USER $KIOSK_HOME

############################
# DONE
############################
echo "✅ CORE DONE"
