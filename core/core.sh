#!/bin/bash

echo "🚀 FULLPAGEOS CORE START"
echo "🧠 CPU: $(uname -m)"
echo "🖥️ MODEL: $PI_MODEL"
echo ""

############################
# 🔧 VARS
############################
KIOSK_USER="kiosk"
KIOSK_HOME="/home/$KIOSK_USER"
URL_FILE="$KIOSK_HOME/url.txt"
START_URL="https://internet-artikel.de"

############################
# 📦 INSTALL
############################
apt update -y && apt upgrade -y

apt install -y \
xserver-xorg \
x11-xserver-utils \
xinit \
openbox \
unclutter \
chromium \
python3

############################
# 👤 USER
############################
if ! id "$KIOSK_USER" &>/dev/null; then
    useradd -m -s /bin/bash $KIOSK_USER
    echo "$KIOSK_USER:$KIOSK_USER" | chpasswd
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
# 🖥️ HARDWARE CONFIG
############################
BOOT_CONFIG="/boot/config.txt"
[ -f /boot/firmware/config.txt ] && BOOT_CONFIG="/boot/firmware/config.txt"

if [ "$PI_MODEL" == "pi4" ]; then

cat <<EOF > $BOOT_CONFIG
dtoverlay=vc4-kms-v3d
gpu_mem=256
hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=82
hdmi_drive=2
EOF

fi

############################
# 🌐 URL DEFAULT
############################
echo "$START_URL" > $URL_FILE

############################
# 🧠 API SERVER
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

            os.system("pkill chromium")

            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"URL updated")

        elif self.path == "/api/v1/status":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK")

        else:
            self.send_response(404)
            self.end_headers()

HTTPServer(("0.0.0.0", 3000), Handler).serve_forever()
EOF

############################
# ⚙️ OPENBOX
############################
mkdir -p $KIOSK_HOME/.config/openbox

cat <<'EOF' > /home/kiosk/.config/openbox/autostart
#!/bin/bash

python3 /home/kiosk/api_server.py &

xset s off
xset -dpms
xset s noblank

unclutter -idle 0 &

sleep 2

while true; do

URL=$(cat /home/kiosk/url.txt)

chromium --kiosk "$URL"

sleep 2

done
EOF

chmod +x /home/kiosk/.config/openbox/autostart

############################
# 🧾 STARTX
############################
cat <<EOF > $KIOSK_HOME/.bash_profile

if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    startx
fi

EOF

############################
# 🔐 PERMS
############################
chown -R $KIOSK_USER:$KIOSK_USER $KIOSK_HOME

echo "✅ CORE DONE"
