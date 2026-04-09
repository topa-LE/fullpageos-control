#!/bin/bash
set -e

# 1. Kiosk-Benutzer erstellen und konfigurieren
echo "Erstelle Kiosk-Benutzer..."
if ! id "kiosk" &>/dev/null; then
    useradd -m -s /bin/bash kiosk
    echo "kiosk:kiosk" | chpasswd
    usermod -aG sudo kiosk
    echo "root:meinSicheresPasswort" | chpasswd
fi

# 2. Notwendige Pakete installieren
echo "Installiere benötigte Pakete..."
apt-get update
apt-get install -y locales xserver-xorg xinit openbox unclutter chromium curl jq initramfs-tools openssh-server nginx

# 3. System-Optimierungen durchführen
echo "Deaktiviere unnötige Systemdienste und optimiere das System..."
systemctl mask systemd-remount-fs.service || true
systemctl disable systemd-remount-fs.service 2>/dev/null || true
systemctl mask dphys-swapfile.service || true
systemctl mask rpi-resize-swap-file.service || true
systemctl mask systemd-zram-setup@.service || true

# 4. Kiosk-Skript erstellen
if [ ! -f /usr/local/bin/kiosk.sh ]; then
    echo "Erstelle Kiosk-Skript..."
    cat << 'EOL' > /usr/local/bin/kiosk.sh
#!/bin/bash
set -e
export DISPLAY=:0
while true; do
    pgrep -x unclutter >/dev/null || unclutter -idle 0 -root &
    pgrep openbox >/dev/null || openbox &
    URL=$(jq -r '.url' /data/config.json 2>/dev/null || echo "https://google.de")
    pkill -x chromium 2>/dev/null || true
    chromium "$URL" \
        --kiosk \
        --no-sandbox \
        --incognito \
        --disable-infobars \
        --disable-session-crashed-bubble \
        --disable-dev-shm-usage \
        --disable-features=TranslateUI \
        --disable-extensions \
        --no-first-run \
        --disk-cache-dir=/tmp \
        --disk-cache-size=10000000 \
        --disable-software-rasterizer \
        --ignore-gpu-blocklist \
        --disable-gpu \
        --disable-accelerated-video-decode
    # Health Check für Chromium neu starten, falls es abstürzt
    echo "Chromium abgestürzt! Neustart..."
    sleep 2
done
EOL
    chmod +x /usr/local/bin/kiosk.sh
fi

# 5. Xinitrc für den kiosk Benutzer erstellen
if [ ! -f /home/kiosk/.xinitrc ]; then
    echo "Erstelle Xinitrc für den Kiosk..."
    cat <<EOL > /home/kiosk/.xinitrc
openbox-session &
exec /usr/local/bin/kiosk.sh
EOL
    chown kiosk:kiosk /home/kiosk/.xinitrc
fi

# 6. Kiosk-Systemd-Service erstellen
if [ ! -f /etc/systemd/system/kiosk.service ]; then
    echo "Erstelle Kiosk-Systemd-Service..."
    cat <<EOL > /etc/systemd/system/kiosk.service
[Unit]
After=network-online.target systemd-user-sessions.service local-fs.target
Wants=network-online.target

[Service]
User=kiosk
Group=kiosk
Environment=HOME=/home/kiosk
ExecStart=/usr/bin/startx -- -nocursor
Restart=always
RestartSec=5

TTYPath=/dev/tty1
StandardInput=tty
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOL
    systemctl enable kiosk.service
fi

# 7. Konfiguration für den Kiosk speichern
if [ ! -d /data ]; then
    echo "Erstelle /data Verzeichnis..."
    mkdir -p /data
fi

if [ ! -f /data/config.json ]; then
    echo "Speichere Kiosk-Konfiguration..."
    cat <<EOL > /data/config.json
{
  "url": "https://google.de",
  "refresh": 60
}
EOL
fi

# 8. nginx für URL-Änderung einrichten
echo "Konfiguriere nginx für URL-Änderung..."
cat <<EOL > /etc/nginx/sites-available/kiosk
server {
    listen 80;
    server_name localhost;

    # Dokument-Root
    root /var/www/html;

    # Alias für die Konfiguration
    location /config {
        alias /data/config.json;
        default_type application/json;
        try_files $uri =404;
    }

    # Standardindex
    index index.html index.htm index.php;

    # Fehlerseite
    error_page 404 /404.html;
    location = /404.html {
        root /usr/share/nginx/html;
    }

    # Weiterleitungen
    location / {
        try_files $uri $uri/ =404;
    }
}
EOL

# Erstelle symbolischen Link und aktiviere nginx
sudo ln -s /etc/nginx/sites-available/kiosk /etc/nginx/sites-enabled/

# 9. Health-Überwachungs-Skript erstellen
if [ ! -f /usr/local/bin/kiosk_health.sh ]; then
    echo "Erstelle Health-Überwachungs-Skript..."
    cat << 'EOL' > /usr/local/bin/kiosk_health.sh
#!/bin/bash
# Health-Check Skript: Überwacht den Chromium-Prozess und startet ihn neu, falls er nicht läuft

while true; do
    if ! pgrep -x chromium > /dev/null; then
        echo "Chromium-Prozess nicht gefunden! Neustart..."
        /usr/local/bin/kiosk.sh &
    fi
    sleep 60
done
EOL
    chmod +x /usr/local/bin/kiosk_health.sh
fi

# 10. Health-Überwachungs-Service einrichten
if [ ! -f /etc/systemd/system/kiosk-health.service ]; then
    echo "Konfiguriere Health-Überwachungs-Service..."
    cat <<EOL > /etc/systemd/system/kiosk-health.service
[Unit]
After=kiosk.service

[Service]
ExecStart=/usr/local/bin/kiosk_health.sh
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOL
    systemctl enable kiosk-health.service
fi

# 11. Autologin für den Benutzer kiosk einrichten
echo "Aktiviere Autologin für kiosk..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
cat <<EOL | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --noclear --autologin kiosk %I $TERM
EOL

# 12. System anpassen und Caches bereinigen
echo "Bereinige das System und aktualisiere Initramfs..."
update-initramfs -u
apt-get clean

# 13. Reboot einbauen
echo "Setup abgeschlossen! Das System wird nun neu gestartet."
reboot