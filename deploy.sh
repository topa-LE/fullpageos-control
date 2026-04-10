#!/bin/bash

echo "🚀 DEPLOY START"

TARGET_IP=$1

if [ -z "$TARGET_IP" ]; then
    echo "❌ Usage: ./deploy.sh <IP>"
    exit 1
fi

echo "📡 Target: $TARGET_IP"

############################
# DATEIEN KOPIEREN
############################
echo "📦 Copy files..."

scp -r core modules targets install.sh pi@$TARGET_IP:/home/pi/fullpageos

############################
# REMOTE INSTALL
############################
echo "⚙️ Start remote install..."

ssh pi@$TARGET_IP << 'EOF'

cd /home/pi/fullpageos

chmod +x install.sh

sudo ./install.sh pi2

EOF

echo "✅ DEPLOY COMPLETE"
