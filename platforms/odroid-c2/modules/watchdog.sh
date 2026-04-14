#!/bin/bash

echo "🛡️ Watchdog gestartet"

while true; do

    if ! pgrep -x chromium > /dev/null; then
        echo "⚠️ Chromium abgestürzt → Neustart"
        pkill chromium
        sleep 2
    fi

    sleep 10

done
