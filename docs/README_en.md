![License](https://img.shields.io/badge/license-MIT-green)
![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-Supported-red)
![Debian](https://img.shields.io/badge/Debian-Trixie-red)
![Kiosk](https://img.shields.io/badge/Mode-Kiosk-blue)
![Auto Boot](https://img.shields.io/badge/AutoBoot-Enabled-success)
![Self Healing](https://img.shields.io/badge/System-Self--Healing-important)
![Watchdog](https://img.shields.io/badge/Watchdog-Active-blueviolet)

[![🇩🇪 Deutsch](https://img.shields.io/badge/lang-DE-blue)](../README.md)
[![🇬🇧 English](https://img.shields.io/badge/lang-EN-red)](./docs/README_en.md)

👉 🇩🇪 [Deutsche Version](../README.md)

# 🚀 FULLPAGEOS CONTROL – KIOSK SYSTEM (PI2–PI5)

Welcome to the FullPageOS Control setup repository!
This repository contains everything you need to install and run a complete kiosk system on Raspberry Pi (Pi2–PI5).

---

# 🧠 The Debian Self Build System

The FullpageOS Control system is based on a Debian self build system with:

- complete update procedure
- integrated crash protection
- automated setup via a one-time script execution

👉 Specifically developed for Grafana dashboards and monitoring systems.

---

# 🔥 Features

- Easy installation: A single script execution sets up the entire system
- Automated updates: System stays automatically up to date
- Crash protection: Automatic restart and stabilization
- Optimized for Grafana: Perfect for dashboards and monitoring
- API control: Change URL via HTTP
- Modular design: Extendable via module system

---

# 📦 Requirements

- Raspberry Pi 2, 3, 4 or 5
- Raspberry Pi OS (Trixie Lite) as base image
- SD card (minimum 8 GB recommended)
- Network connection (LAN recommended)
- SSH access

---

# 🧠 Concept

The system consists of two layers:

## 🟢 1. Base Image (Required)

- Raspberry Pi OS (Trixie Lite)
- 32bit (Pi2) / 64bit (Pi3–Pi5)
- SSH enabled

👉 Without a bootable Raspberry Pi OS the system will NOT work.

---

# 🚀 Installation

## 1. Flash Raspberry Pi OS

- Use Raspberry Pi Imager
- Pi OS: Trixie Lite
- Flash SD card (minimum 8GB)

---

## 2. Enable SSH

Create an empty file on the boot partition:

ssh

```bash
Login:
user: pi
password: raspberry
```

---

## 3. Connect via SSH

```bash
ssh pi@IP
sudo -i
```

---

## 4. (Optional) Prepare base system

```bash
apt update -y && apt upgrade -y
```bash

---

## 5. Clone repository

```bash
apt install git -y
cd /opt
git clone https://github.com/topa-LE/fullpageos-control.git
cd fullpageos-control
```

---

## 5.1 Setup Extension - Base Image

```bash
cd base-image
sudo ./setup.sh
sudo reboot
```

👉 Optional: Create base image backup

---

## 6. Run build

Example here for Pi4: (Pi2,Pi3,Pi5 - choose corresponding folder)

```bash
cd /opt/fullpageos-control/hardware/pi4
sudo ./build.sh
```

---

## 7. Reboot

```bash
reboot
```

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

```bash
curl "http://IP:3000/api/v1/url=https://example.com"
```

---

## Check status

```bash
curl http://IP:3000/api/v1/status
```

---

# 🧩 Module System

Modules can be centrally enabled or disabled:

```bash
config/modules.conf
```

---

# 📦 Architecture

core/core.sh        → main system
hardware/piX/       → entry point per Pi
modules/            → extensions
config/modules.conf → control

---

# 🚀 Download (Prebuilt Images)

Prebuilt images are available in the release section:

👉 https://github.com/topa-LE/fullpageos-control/releases

## 📦 Available Images

- Pi2 (32bit) → FullpageOS Kiosk Pi2 Image
- Pi3 (64bit) → FullpageOS Kiosk Pi3 Image
- Pi4 (64bit) → FullpageOS Kiosk Pi4 Image
- Pi5 (64bit) → FullpageOS Kiosk Pi5 Image


👉 Simply download, flash to SD card and start.

---

## ⚡ Quick Start

1. Download image
2. Flash with Raspberry Pi Imager or Balena Etcher
3. Insert SD card
4. Boot → done

---

👉 No setup required – plug & play

---

# 🚀 FULLPAGEOS CONTROL

👉 Stable, reproducible and modular design.

---

## 📜 License

This project is licensed under the MIT License.

Copyright (c) 2026 topa-LE

Permission is granted to use, modify and distribute the software.
The software is provided without any warranty.
See LICENSE file for details.
