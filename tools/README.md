# 🛠 FullPageOS Tools

This directory contains utility scripts to manage, backup, restore and deploy FullPageOS systems.

All tools are designed to be:

- ✔ simple
- ✔ safe
- ✔ reusable across devices (Raspberry Pi & Odroid)
- ✔ production-ready

---

## 📦 Included Tools

### 🚀 flash_fullpageos.sh
Flash a FullPageOS image to an SD card or USB device.

**Features:**
- Supports `.img` and `.img.xz`
- Device selection
- Safety confirmation
- Auto unmount

**Usage:**
```bash
sudo ./flash_fullpageos.sh
```
---

💾 backup_fullpageos.sh

Create a full disk image backup of a running system.

Features:

Local backup storage (/media/backup)
Logging
Retention (keeps latest backups)
Safe execution with lockfile

**Usage:**
```bash
sudo ./backup_fullpageos.sh
```
---

🔄 restore_fullpageos.sh

Restore a previously created backup image to an SD card.

Features:

Interactive backup selection
Device selection
Safety confirmation
Clean unmount before restore

**Usage:**
```bash
sudo ./restore_fullpageos.sh
```
---

🧹 cleanup_sd.sh

Prepare a system for backup (recommended before imaging).

Features:

Removes logs, cache, temp files
Clears history
Zero-fill free space (better compression)

**Usage:**

```bash
sudo ./cleanup_sd.sh
```
---

🧪 sd_check.sh

Basic health check for SD cards.

Features:

Filesystem check
Write test
Quick diagnostics

**Usage:**
```bash
sudo ./sd_check.sh
```
---

🔁 Recommended Workflow

For creating a clean and optimized image:

1. cleanup_sd.sh
2. poweroff
3. backup_fullpageos.sh
4. pishrink
5. flash_fullpageos.sh (for deployment)

---

⚠️ Important Notes
All scripts require root privileges
Always double-check the target device (/dev/sdX)
Flashing will erase all data on the target device
❤️ Project

FullPageOS Control
https://github.com/topa-LE/fullpageos-control

A lightweight, self-healing kiosk system for Raspberry Pi and Odroid devices.


