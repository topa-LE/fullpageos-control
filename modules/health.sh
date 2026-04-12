#!/usr/bin/env bash

echo "💓 HEALTH MODUL START"

cat <<EOF > /usr/local/bin/fullpageos-health.sh
#!/bin/bash

STATUS="OK"

if ! pgrep -f chromium > /dev/null; then
    STATUS="CHROMIUM_DOWN"
fi

if ! systemctl is-active --quiet kiosk-api; then
    STATUS="API_DOWN"
fi

echo $STATUS
EOF

chmod +x /usr/local/bin/fullpageos-health.sh

echo "✅ HEALTH CHECK INSTALLIERT"
