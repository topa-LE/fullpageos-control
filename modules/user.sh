#!/bin/bash

echo "👤 USER SETUP"

############################
# BUILD USER
############################
if ! id "build" &>/dev/null; then
    useradd -m -s /bin/bash build
    echo "build:build" | chpasswd
    usermod -aG sudo build
    echo "✅ build user erstellt"
else
    echo "✔ build user existiert"
fi

############################
# KIOSK USER
############################
if ! id "kiosk" &>/dev/null; then
    useradd -m -s /bin/bash kiosk
    echo "kiosk:kiosk" | chpasswd
    usermod -aG sudo kiosk
    echo "✅ kiosk user erstellt"
else
    echo "✔ kiosk user existiert"
fi
