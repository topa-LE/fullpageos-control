# 🚀 FULLPAGEOS CONTROL – KIOSK SYSTEM (PI2–PI5)

Welcome to the FullPageOS Control setup repository!  
This repository contains everything you need to deploy a complete kiosk system on Raspberry Pi (Pi2–Pi5).

---

# 🧠 Debian Self Build System

FullpageOS Control is based on a Debian self-build system with:

- full update automation  
- crash recovery mechanisms  
- one-run setup process  

👉 Designed specifically for Grafana dashboards and monitoring systems.

---

# 🔥 Features

- Easy installation: One script run installs the entire system  
- Automated updates: System stays up-to-date  
- Crash recovery: Automatic restart and stabilization  
- Optimized for Grafana dashboards  
- API control: Change URLs remotely  
- Modular design: Extend via modules  

---

# 📦 Requirements

- Raspberry Pi 2, 3, 4 or 5  
- Raspberry Pi OS (Trixie) base image  
- SD card (minimum 8 GB recommended)  
- Network connection (LAN recommended)  
- SSH access  

---

# 🧠 Concept

The system is built on two layers:

## 🟢 1. Base Image (Required)

- Raspberry Pi OS (Trixie)
- 32bit (Pi2) / 64bit (Pi3–Pi5)
- SSH enabled

👉 Without a bootable OS, the system will NOT work.

---

# 🚀 Installation

## 1. Flash Raspberry Pi OS

- Use Raspberry Pi Imager
- OS: Trixie Lite
- Flash SD card

---

## 2. Enable SSH

Create an empty file on the boot partition:

ssh

Login:
user: pi
password: raspberry

---

## 3. Connect via SSH

ssh pi@IP
sudo -i

---

## 4. (Optional) Update system

apt update -y && apt upgrade -y

---

## 5. Clone repository

cd /opt
git clone https://github.com/topa-LE/fullpageos-control.git
cd fullpageos-control

---

## 6. Run build

Example Pi4:

cd hardware/pi4
sudo ./build.sh

---

## 7. Reboot

reboot

---

# 💥 Result

After boot:

- Autologin enabled  
- X starts automatically  
- Chromium in kiosk mode  
- API running on port 3000  
- Modules active  

---

# 🌐 API Usage

## Change URL

curl "http://IP:3000/api/v1/url=https://example.com"

---

## Check status

curl http://IP:3000/api/v1/status

---

# 🧩 Module System

Modules can be enabled or disabled:

config/modules.conf

---

# 📦 Architecture

core/core.sh        → main system  
hardware/piX/       → entry point per device  
modules/            → extensions  
config/modules.conf → configuration  

---

# 🚀 FULLPAGEOS CONTROL

👉 Built for stability, simplicity and scalability.
