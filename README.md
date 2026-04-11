![License](https://img.shields.io/badge/license-MIT-green)

# 🚀 FULLPAGEOS CONTROL – KIOSK SYSTEM (PI2–PI5)

Willkommen im FullPageOS Control Setup-Repository!  
Dieses Repository enthält alles, was du benötigst, um ein vollständiges Kiosk-System auf Raspberry Pi (Pi2–Pi5) zu installieren und zu betreiben.

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
- OS: Trixie Lite
- SD-Karte flashen

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
## 4.1 Grund-Setup erweitern - Base-Image

```bash
cd base-image
sudo ./setup.sh
```

👉 Optional: Base-Image Backup erstellen

---

## 5. Repository klonen

```bash
apt install git -y
cd /opt
git clone https://github.com/topa-LE/fullpageos-control.git
cd fullpageos-control
```

---

## 6. Build ausführen

Beispiel Pi4:

```bash
cd hardware/pi4
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

# 🚀 FULLPAGEOS CONTROL

👉 Stabil, reproduzierbar und modular aufgebaut.


---


## 📜 Lizenz

Dieses Projekt steht unter der MIT-Lizenz.

Copyright (c) 2026 topa-LE

Die Nutzung, Änderung und Weitergabe der Software ist erlaubt. Die Software wird ohne jegliche Garantie bereitgestellt. Weitere Details siehe LICENSE-Datei.
