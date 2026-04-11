#!/bin/bash

echo "🔁 AUTORESTART MODUL START"

cat <<EOF > /usr/local/bin/fullpageos-watchdog.sh
#!/bin/bash

while true; do

if ! pgrep -f chromium > /dev/null; then
    echo "⚠️ Chromium nicht aktiv – restart"
    pkill -f chromium
fi

sleep 30

done
EOF

chmod +x /usr/local/bin/fullpageos-watchdog.sh

cat <<EOF > /etc/systemd/system/fullpageos-watchdog.service
[Unit]
Description=FullpageOS Watchdog

[Service]
ExecStart=/usr/local/bin/fullpageos-watchdog.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable fullpageos-watchdog
systemctl start fullpageos-watchdog

echo "✅ AUTORESTART AKTIV"
