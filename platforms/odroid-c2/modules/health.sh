#!/bin/bash

echo "❤️ Health Check gestartet"

while true; do

    if ! ping -c 1 1.1.1.1 >/dev/null 2>&1; then
        echo "🌐 Netzwerk Problem → Fix"
        echo "nameserver 1.1.1.1" > /etc/resolv.conf
    fi

    sleep 30

done
