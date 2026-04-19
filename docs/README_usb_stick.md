## 🔧 Tools

### 🚀 Debian USB Boot Stick Creator

Create a bootable Debian 12 / 13 server USB stick directly from a Linux build server.

Supports:
- Debian 12 (Bookworm)
- Debian 13 (Trixie)
- Netinstall (minimal server setup)

---

### ⚡ Quick Start

sudo ./tools/usb_boot_stick_debian_12_13_lite_server.sh

---

### 🤖 Auto Server Install (Hands-off)

Fully automated Debian 12 server installation (no GUI, SSH enabled).

Features:
- No desktop environment
- SSH server installed
- Auto partitioning (entire disk)
- Preconfigured users

Default credentials:

root: debian  
user: ace  
password: debian  

---

### ⚡ Auto Install Usage

sudo ./tools/usb_boot_stick_debian_12_auto_server.sh

---

### ⚠️ Notes

- ⚠️ All data on the target USB device will be destroyed
- ⚠️ Auto install will wipe the target disk completely
- 💡 Designed for homelab / server environments

---

### 🧠 Use Cases

- Homelab server deployment
- Fast provisioning of new systems
- Docker / VM base systems
- Test environments

---

### 📁 Structure

tools/
 ├── usb_boot_stick_debian_12_13_lite_server.sh
 └── usb_boot_stick_debian_12_auto_server.sh
