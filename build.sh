#!/bin/bash

echo "🚀 FULLPAGEOS BUILD SYSTEM"

PI_MODEL=$1

if [ -z "$PI_MODEL" ]; then
  echo "❌ Nutzung: ./build.sh pi2|pi3|pi4|pi5"
  exit 1
fi

BASE_DIR="/home/build/fullpageos"

echo "➡️ Ziel: $PI_MODEL"

# -----------------------------
# CORE
# -----------------------------
echo "🔧 Core wird ausgeführt..."
bash $BASE_DIR/core/install.sh

# -----------------------------
# MODULES
# -----------------------------
echo "📦 Module werden installiert..."
bash $BASE_DIR/modules/install.sh

# -----------------------------
# HARDWARE
# -----------------------------
echo "🧠 Hardware Setup..."
bash $BASE_DIR/hardware/$PI_MODEL/setup.sh

# -----------------------------
# BOOT CONFIG
# -----------------------------
echo "💾 Boot Config setzen..."

BOOT_SRC="$BASE_DIR/config/boot/$PI_MODEL/config.txt"
BOOT_TARGET="/boot/firmware/config.txt"

cp $BOOT_TARGET ${BOOT_TARGET}.bak_$(date +%F_%H-%M-%S)
cp $BOOT_SRC $BOOT_TARGET

echo "✅ Build abgeschlossen für $PI_MODEL"
