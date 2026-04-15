# ODROID-C2 – FULLPAGEOS KIOSK (LEGACY PLATFORM)

⚠️ **Hinweis:**
Der Odroid-C2 ist eine ältere, nicht mehr aktiv weiterentwickelte Plattform.
Dieses Setup dient als **Legacy Support** für bestehende Hardware.

---

## 📦 Download (DietPi Base-Image)

Das System basiert auf einem DietPi Basis Core-Image:

👉 [DietPi Odroid C2 (Trixie) herunterladen](https://dietpi.com/downloads/images/DietPi_OdroidC2-ARMv8-Trixie.img.xz)

- Image: DietPi Odroid C2 (ARMv8 / Trixie)
- Format: `.img.xz`
- Minimal & optimiert für SBCs :contentReference[oaicite:1]{index=1}

## 💽 Flashen (Linux)

👉 Einfach herunterladen und auf die SD-Karte flashen und booten.

---

## 🔑 Default Login

```bash
User: root
Password: odroid
```

👉 Nach dem ersten Login Passwort ändern:

```bash
passwd
```

---

## 🌐 Netzwerk

* Standard: DHCP über LAN
* Kein WLAN Setup notwendig

---

## 🧠 System Besonderheiten

* Kein `/boot/config.txt`
* Keine `dtoverlay` Unterstützung
* Kein Raspberry Pi Bootsystem
* Kernel: 3.16 (Hardkernel angepasst)
* Mali GPU (eingeschränkte Unterstützung)

---

## 📁 Projektstruktur

```bash
platforms/
└── odroid-c2/
    ├── base.sh
    ├── core.sh
    ├── build.sh
    ├── modules/
    └── config/
```

---

## 🚀 Build ausführen

```bash
cd platforms/odroid-c2
./build.sh
```

---

## ⚙️ Base Setup

Installiert u.a.:

* X Server
* Openbox
* Chromium (chromium-browser)
* Python3
* Netzwerktools

---

## 🖥️ Kiosk Verhalten

* Autologin auf tty1
* Start von X + Openbox
* Chromium im Kiosk-Modus
* automatische URL Steuerung
* Restart Loop bei Absturz

---

## 🔌 API Funktionen

* URL ändern:

```bash
http://IP:3000/api/v1/url=https://example.com
```

* Status prüfen:

```bash
http://IP:3000/api/v1/status
```

---

## 🔁 Self-Healing Features

* Netzwerk Check
* Chromium Restart
* Cache Cleanup

---

## ⚠️ Einschränkungen

* Begrenzte GPU Leistung
* Kein moderner WebGL Support
* Video Playback eingeschränkt
* Alte Kernelbasis

---

## ✅ Geeignete Use Cases

* Dashboard (Grafana, Home Assistant)
* Status Screens
* einfache Web-Anwendungen
* Informationsanzeigen

---

## ❌ Nicht geeignet für

* moderne Web-Apps mit hoher GPU Last
* Video Streaming
* komplexe Animationen

---

## 🧠 Empfehlung

Dieses Setup eignet sich ideal als:

* Secondary Display
* Monitoring Screen
* Kiosk für einfache Inhalte

Für neue Installationen wird empfohlen:

* Raspberry Pi 4 / 5
* oder x86 Systeme

---

## 🔒 Sicherheit

Nach Installation:

```bash
passwd
```

Optional:

```bash
apt update && apt upgrade -y
```

---

## 🧩 Module (optional)

Konfiguration über:

```bash
platforms/odroid-c2/config/modules.conf
```

Beispiele:

* watchdog
* cleanup
* autoupdate

---

## 📌 Fazit

Der ODROID-C2 bleibt eine solide Plattform für einfache Kiosk-Systeme,
sollte jedoch als **Legacy Hardware** betrachtet werden.

---
