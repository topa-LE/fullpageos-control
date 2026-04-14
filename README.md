![License](https://img.shields.io/badge/license-MIT-green)
![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-Supported-red)
![Debian](https://img.shields.io/badge/Debian-Trixie-red)
![Kiosk](https://img.shields.io/badge/Mode-Kiosk-blue)
![Auto Boot](https://img.shields.io/badge/AutoBoot-Enabled-success)
![Self Healing](https://img.shields.io/badge/System-Self--Healing-important)
![Watchdog](https://img.shields.io/badge/Watchdog-Active-blueviolet)
![Odroid C2](https://img.shields.io/badge/Odroid-C2-blue)
![Hardkernel](https://img.shields.io/badge/Board-Hardkernel-red)
![OS](https://img.shields.io/badge/OS-DietPi-blue?logo=debian&logoColor=white)
![Device](https://img.shields.io/badge/Device-Odroid%20C2-black)
![Mode](https://img.shields.io/badge/Mode-Kiosk-green)
![Status](https://img.shields.io/badge/Status-Stable-brightgreen)
![DietPi](https://img.shields.io/badge/DietPi-Kiosk%20Ready-green)
[![🇩🇪 Deutsch](https://img.shields.io/badge/lang-DE-blue)](./README.md)
[![🇬🇧 English](https://img.shields.io/badge/lang-EN-red)](./docs/README_en.md)


👉 🇬🇧 [English Version](./docs/README_en.md)


# 🚀 FULLPAGEOS CONTROL – KIOSK SYSTEM (PI2–PI5)

Willkommen im FullPageOS Control Setup-Repository!
Dieses Repository enthält alles, was du benötigst, um ein vollständiges Kiosk-System auf Raspberry Pi (Pi2–Pi5) sowie auf dem Odroid-C2 zu installieren und zu betreiben.


---

# 🧭 Unterstützte Plattformen
# 🍓 Raspberry Pi (Hauptplattform)
- Pi2, Pi3, Pi4, Pi5
- FullpageOS kompatibel
- Optimiert für Kiosk-Systeme

# 💻 Odroid-C2 (Alternative / Legacy Support)
- Basis: Armbian (Debian / Ubuntu)
- Kein FullpageOS Image verfügbar
- Setup erfolgt über eigene Scripts (platforms/odroid-c2)

👉 Hinweise:

Kein Raspberry Pi Bootsystem (config.txt, dtoverlay entfallen)
Moderner Kernel über Armbian notwendig (kein Hardkernel Ubuntu 20.04!)
Chromium wird direkt über apt installiert (kein Snap)

---

# 🧠 Das Debian Self Build System

Das FullpageOS Control System basiert auf einem Debian Self Build System mit:

- vollständiger Updateprozedur  
- integrierter Crash-Sicherung  
- automatisierter Einrichtung durch einen einmaligen Script-Durchlauf  

👉 Speziell entwickelt für Grafana-Dashboards und Monitoring-Systeme.

---

# 🔥 Features

- Einfache Installation: Ein einmaliger Script-Durchlauf richtet das komplette System ein  
- Automatisierte Updates: System bleibt automatisch aktuell  
- Crash-Sicherung: Automatischer Neustart und Stabilisierung  
- Optimiert für Grafana: Perfekt für Dashboards und Monitoring  
- API Steuerung: URL-Wechsel per HTTP  
- Modular aufgebaut: Erweiterbar über Module-System  

---

# 📦 Anforderungen

- Raspberry Pi 2, 3, 4 oder 5  
- Raspberry Pi OS (Trixie Lite) als Basis-Image  
- SD-Karte (mindestens 8 GB empfohlen)  
- Netzwerkverbindung (LAN empfohlen)  
- SSH Zugriff  

---

# 🧠 Konzept

Das System besteht aus zwei Ebenen:

## 🟢 1. Basis-Image (Pflicht)

- Raspberry Pi OS (Trixie Lite)
- 32bit (Pi2) / 64bit (Pi3–Pi5)
- SSH aktiviert

👉 Ohne ein bootfähiges Raspberry Pi OS funktioniert das System NICHT.

---

# 🚀 Installation

## 1. Raspberry Pi OS flashen

- Raspberry Pi Imager nutzen
- Pi OS: Trixie Lite
- SD-Karte flashen (mindestens 8GB)

---

## 2. SSH aktivieren

Auf der Boot-Partition eine leere Datei erstellen:

ssh

```bash
Login:
user: pi
password: raspberry
```

---

## 3. SSH Verbindung herstellen

```bash
ssh pi@IP
sudo -i
```

---

## 4. (Optional) Basis vorbereiten

```bash
apt update -y && apt upgrade -y
```
---

## 5. Repository klonen

```bash
apt install git -y
cd /opt
git clone https://github.com/topa-LE/fullpageos-control.git
cd fullpageos-control
```

---

## 5.1 Setup Erweiterung - Base Image

```bash
cd base-image
sudo ./setup.sh
sudo reboot
```

👉 Optional: Base-Image Backup erstellen

---

## 6. Build ausführen

Beispiel hier für Pi4: (Pi2,Pi3,Pi5 - entsprechend Ordner wählen)

```bash
cd /opt/fullpageos-control/hardware/pi4
sudo ./build.sh
```

---

## 7. Neustart

```bash
reboot
```
---

# 💥 Ergebnis

Nach dem Boot:

- Autologin aktiv
- X startet automatisch
- Chromium im Kiosk-Modus
- API läuft auf Port 3000
- Module aktiv

---

# 🌐 API Nutzung

## URL ändern

```bash
curl "http://IP:3000/api/v1/url=https://example.com"
```
---

## Status prüfen

```bash
curl http://IP:3000/api/v1/status
```
---

# 🧩 Modul-System

Module können zentral aktiviert oder deaktiviert werden:

```bash
config/modules.conf
```

---

# 📦 Architektur

core/core.sh        → Hauptsystem  
hardware/piX/       → Startpunkt je Pi  
modules/            → Erweiterungen  
config/modules.conf → Steuerung  

---

# 🚀 Download (Prebuilt Images)

Fertige Images stehen im Release zur Verfügung:

👉 https://github.com/topa-LE/fullpageos-control/releases

## 📦 Verfügbare Images

- Pi2 (32bit) → FullpageOS Kiosk Pi2 Image
- Pi3 (64bit) → FullpageOS Kiosk Pi3 Image
- Pi4 (64bit) → FullpageOS Kiosk Pi4 Image
- Pi5 (64bit) → FullpageOS Kiosk Pi5 Image


👉 Einfach herunterladen, auf SD-Karte flashen und starten.

---

## ⚡ Quick Start

1. Image herunterladen  
2. Mit Raspberry Pi Imager oder Balena Etcher flashen  
3. SD-Karte einlegen  
4. Booten → fertig  

---

👉 Kein Setup nötig – Plug & Play

---

# 🚀 FULLPAGEOS CONTROL

👉 Stabil, reproduzierbar und modular aufgebaut.


---


## 📜 Lizenz

Dieses Projekt steht unter der MIT-Lizenz.

Copyright (c) 2026 topa-LE

Die Nutzung, Änderung und Weitergabe der Software ist erlaubt. Die Software wird ohne jegliche Garantie bereitgestellt. Weitere Details siehe LICENSE-Datei.
