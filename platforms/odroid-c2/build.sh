#!/bin/bash
set -e

echo "🚀 FULLPAGEOS ODROID-C2 BUILD START (DIETPI)"

############################
# RECHTE SICHERN
############################
chmod +x ./base.sh
chmod +x ./core.sh

############################
# BASE
############################
echo "📦 Starte base.sh..."
bash ./base.sh

############################
# CORE
############################
echo "🧠 Starte core.sh..."
bash ./core.sh

############################
# FINAL
############################
echo "✅ BUILD KOMPLETT FERTIG"
echo "➡️ System kann jetzt rebootet werden"
