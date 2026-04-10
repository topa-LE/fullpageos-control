#!/bin/bash

echo "🖥️ KIOSK SETUP"

KIOSK_HOME="/home/kiosk"

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
# STARTX
############################
cat <<EOF > $KIOSK_HOME/.bash_profile

if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    startx /usr/bin/openbox-session
fi

EOF

echo "https://internet-artikel.de" > /home/kiosk/url.txt
chown -R kiosk:kiosk /home/kiosk
