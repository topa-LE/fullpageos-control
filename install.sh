#!/bin/bash

echo "🚀 FULLPAGEOS INSTALLER"

TARGET=$1

if [ -z "$TARGET" ]; then
    echo "❌ Usage: ./install.sh pi2|pi3|pi4"
    exit 1
fi

echo "🎯 INSTALL TARGET: $TARGET"

############################
# USER
############################
bash modules/user.sh

############################
# CORE
############################
bash core/core.sh

############################
# MODULES
############################
bash modules/kiosk.sh
bash modules/api.sh

############################
# TARGET
############################
case $TARGET in
    pi2)
        bash targets/pi2/pi2.sh
        ;;
    *)
        echo "❌ Unknown target"
        exit 1
        ;;
esac

echo "✅ INSTALL COMPLETE"
