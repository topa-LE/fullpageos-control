# FullPageOS Wiki – Detaillierte Dokumentation für Raspberry Pi 2 bis Pi5

## Links:
- [FullPageOS Wiki (detaillierte Dokumentation)](docs/wiki.md)

## Übersicht

Dieses Wiki bietet eine **umfassende, detaillierte Anleitung** für das Setup und die Konfiguration von **FullPageOS** auf den **Raspberry Pi 2**, **Pi 3**, **Pi 4** und **Pi 5**. FullPageOS ist ein leichtgewichtiges Betriebssystem, das Chromium im Kiosk-Modus ausführt. Es eignet sich hervorragend für den Einsatz in Kiosk-Anwendungen oder digitalen Anzeigetafeln. 

Die Konfiguration umfasst:
- Installation von **FullPageOS** auf einem Raspberry Pi
- **Optimierung für Grafana-Dashboards** zur Verwendung auf digitalen Anzeigetafeln
- **Automatische Updates** und Wartungsverfahren
- **Fehlerbehebung** und Troubleshooting-Methoden

---

## Systemanforderungen

Bevor du mit der Installation beginnst, stelle sicher, dass du die folgenden Anforderungen erfüllst:

### Hardware-Anforderungen:
- **Raspberry Pi 2**, **Pi 3**, **Pi 4**, **Pi 5** (je nach Modell)
- **SD-Karte** (mindestens 8 GB, vorzugsweise 16 GB oder mehr)
- Ein **Monitor** (HDMI-kompatibel) für die Anzeige im Kiosk-Modus
- **Ethernet-Verbindung** oder **Wi-Fi** (je nach verfügbarer Netzwerkverbindung)

### Software-Anforderungen:
- **Raspbian Trixie (32 Bit)** als Basis-Image
- **Git** für das Klonen und Abrufen von Repositories
- **SSH** für die Remote-Verwaltung des Raspberry Pi

---

## Vorbereitung des Systems

Bevor du FullPageOS installieren kannst, musst du die folgenden Schritte ausführen:

### 1. Basis-Image herunterladen und auf die SD-Karte flashen
   
1. **Lade das Basis-Image** für **Raspbian Trixie (32 Bit)** von der offiziellen [Raspberry Pi Website](https://www.raspberrypi.org/software/).
2. **Flash das Image** auf eine SD-Karte mit einem Tool wie [Balena Etcher](https://www.balena.io/etcher/).
   - **Empfohlene SD-Kartengröße**: Mindestens **8 GB**, vorzugsweise **16 GB oder mehr**.
   
3. **SSH-Datei erstellen**:
   - Nachdem du das Image auf die SD-Karte geflasht hast, öffne die **Boot-Partition** der SD-Karte und erstelle eine leere Datei mit dem Namen **`ssh`** (ohne Erweiterung). Dies aktiviert den SSH-Zugang beim ersten Booten.

4. **Passwort und Benutzer**:
   - Der Standardbenutzer ist **`pi`**.
   - Das Standardpasswort ist **`raspberry`**.

### 2. Netzwerkverbindung

1. **Ethernet**: Sollte automatisch erkannt werden, wenn der Raspberry Pi mit dem Netzwerk verbunden ist.
2. **Wi-Fi**: Bearbeite die **`wpa_supplicant.conf`** Datei, um dein WLAN-Netzwerk zu konfigurieren. Du kannst diese Datei direkt in der Boot-Partition der SD-Karte einfügen.

---

## Installation und Setup von FullPageOS

### 1. Repository klonen

1. Um mit der Installation zu beginnen, klone das **FullPageOS-Setup-Repository** auf deinen Raspberry Pi:

   ```bash
   git clone git@github.com:topa-LE/fullpageos-control.git
   cd fullpageos-control
