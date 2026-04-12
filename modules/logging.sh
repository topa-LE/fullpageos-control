#!/usr/bin/env bash

echo "📝 LOGGING MODUL START"

LOG_FILE="/var/log/fullpageos.log"

touch $LOG_FILE
chmod 666 $LOG_FILE

echo "===== FULLPAGEOS LOG START $(date) =====" >> $LOG_FILE

echo "✅ LOGGING AKTIV → $LOG_FILE"
