#!/usr/bin/env bash

echo "🧹 CLEANUP MODUL START"

apt autoremove -y
apt clean

echo "✅ SYSTEM BEREINIGT"
