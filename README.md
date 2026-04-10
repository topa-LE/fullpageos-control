# FullPageOS Setup für Raspberry Pi 2 bis Pi5

Willkommen im FullPageOS-Setup-Repo! Dieses Repository enthält alles, was du benötigst, um **FullPageOS** auf verschiedenen **Raspberry Pi**-Modellen (Pi2, Pi3, Pi4, Pi5) zu installieren und zu konfigurieren.

## Das Debian Self Build System

Das **Debian Self Build System** mit einer vollständigen Updateprozedur und Crash-Sicherung, speziell für **Grafana-Dashboards** erstellt, bringt eine ganze Menge an Features durch den einmaligen Script-Durchlauf mit sich. **Ihr werdet Eure Freude haben ;-)**

### Features:
- **Einfache Installation**: Einmaliger Durchlauf des Skripts für die vollständige Installation.
- **Automatisierte Updates**: Updates für das System werden regelmäßig durchgeführt, um sicherzustellen, dass es immer auf dem neuesten Stand bleibt.
- **Crash-Sicherung**: Das System ist mit einem Mechanismus ausgestattet, der den Betrieb auch im Falle eines Fehlers stabilisiert.
- **Optimiert für Grafana**: Speziell optimiert für den Einsatz mit Grafana-Dashboards, um eine exzellente Visualisierung und Überwachung zu gewährleisten.

## Anforderungen

- **Raspberry Pi 2, 3, 4, 5** (je nach Modell)
- **Raspbian Trixie (32 Bit)** als Basis-Image
- **SD-Karte** (mindestens 8 GB)
- **Git** und **SSH** für die Konfiguration

## Vorbereitungen

Bevor du mit der Installation von FullPageOS beginnst, musst du das **Basis-Image** für **Raspbian Trixie (32 Bit)** auf die SD-Karte flashen.

### 1. **Basis-Image auf die SD-Karte flashen**

1. **Lade das Basis-Image** für **Raspbian Trixie (32 Bit)** von der offiziellen Raspberry Pi Website herunter.
2. **Flashen** Sie das Image auf eine SD-Karte (mindestens 8 GB groß) mit einem Tool wie [Balena Etcher](https://www.balena.io/etcher/).
3. **Erstelle eine leere SSH-Datei**:
   - Wenn das Basis-Image geflasht wurde, öffne die **Boot-Partition** der SD-Karte.
   - Erstelle eine **leere Datei** mit dem Namen **`ssh`** (keine Erweiterung) in der Boot-Partition. Dies aktiviert den SSH-Zugang beim ersten Boot.

4. **Passwort und Benutzer**:
   - Der Standardbenutzer ist **`pi`**.
   - Das Standardpasswort ist **`raspberry`**.

### 2. **Netzwerkverbindung**

Stelle sicher, dass der Raspberry Pi mit einem Netzwerk verbunden ist. Wenn du Ethernet verwendest, sollte dies bereits der Fall sein. Wenn du WLAN verwenden möchtest, musst du die WLAN-Konfiguration in der **`wpa_supplicant.conf`** Datei anpassen (mehr dazu weiter unten).

## Installation und Setup

### Schritt 1: GitHub-Repository klonen

1. **Repo klonen**:
   - Klone das Repository auf deinen lokalen Rechner oder direkt auf den Raspberry Pi, wenn du SSH-Zugang hast:

     ```bash
     git clone git@github.com:topa-LE/fullpageos-control.git
     cd fullpageos-control
     ```

### Schritt 2: Pi2, Pi3, Pi4 oder Pi5 Skript ausführen

1. **Pi2 Setup Skript ausführen**:
   - Gehe ins `hardware/pi2` Verzeichnis und führe das **`kiosk_setup_script_pi2.sh`** Skript aus:

     ```bash
     cd hardware/pi2
     sudo bash kiosk_setup_script_pi2.sh
     ```

2. **Pi3 Setup Skript ausführen**:
   - Gehe ins `hardware/pi3` Verzeichnis und führe das **`kiosk_setup_script_pi3.sh`** Skript aus:

     ```bash
     cd hardware/pi3
     sudo bash kiosk_setup_script_pi3.sh
     ```

3. **Pi4 oder Pi5 Setup Skript (noch zu erstellen)**:
   - Für **Pi4** und **Pi5** werden ähnliche Skripte erstellt, um den Kiosk-Modus mit den richtigen GPU- und Display-Einstellungen zu konfigurieren.

### Schritt 3: Kiosk-Modus konfigurieren

1. **Kiosk-Modus einrichten**:
   - FullPageOS wird so konfiguriert, dass es beim Start den Chromium-Browser im Kiosk-Modus startet. Der Browser zeigt eine voreingestellte URL an, die du in den Skripten anpassen kannst.

2. **Anpassungen vornehmen**:
   - Öffne die Konfigurationsdatei **`/boot/config.txt`**, um Hardware-Optionen wie den Bildschirm oder die GPU zu optimieren, je nach Bedarf.

     Beispiel für die Konfiguration des Bildschirmmodi:

     ```bash
     framebuffer_width=1920
     framebuffer_height=1080
     ```

### Schritt 4: Neustart und Test

1. **Neustart durchführen**:
   - Starte den Raspberry Pi neu:

     ```bash
     sudo reboot
     ```

2. **Ergebnis überprüfen**:
   - Der Pi sollte nun automatisch den Chromium-Browser im Kiosk-Modus starten und die konfigurierte Webseite anzeigen.

---

## Weitere Anpassungen

- **Automatisches Starten von Anwendungen**: Du kannst das Startverhalten von Anwendungen über die **`/home/pi/.config/autostart/`** konfigurieren, um sie bei jedem Systemstart automatisch zu starten.
- **Netzwerk- und Benutzerkonfigurationen**: Weitere Anpassungen wie WLAN-Konfigurationen oder Benutzeranpassungen können in den entsprechenden Konfigurationsdateien vorgenommen werden.

---

## Lizenz

Dieses Projekt verwendet die **MIT-Lizenz**. Weitere Informationen findest du in der **LICENSE.md** Datei.
