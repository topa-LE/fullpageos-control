# FullPageOS Pi2 Setup

This repository contains all the necessary files and scripts to set up **FullPageOS** on a **Raspberry Pi 2**. FullPageOS is a lightweight operating system for kiosk applications, configured to run the Raspberry Pi with a web browser (Chromium).

## Requirements

- **Raspberry Pi 2** (or compatible versions)
- **Base Image**: **Raspbian Trixie (32 Bit)** must be flashed onto the SD card.
- **SSH File**: A blank **`ssh`** file must be placed in the boot partition to enable SSH on the first boot.
- **Git** and **SSH** for configuration and setup.

## Preparations

### 1. **Flash the Base Image onto the SD card**

1. **Download the Base Image** for **Raspbian Trixie (32 Bit)** from the official Raspberry Pi website.
2. **Flash the Image** onto an SD card (at least 8 GB in size) using a tool like [Balena Etcher](https://www.balena.io/etcher/).
3. **Create a blank SSH file**:
   - After flashing the base image, open the **boot partition** of the SD card.
   - Create an **empty file** named **`ssh`** (no extension) in the boot partition. This will enable SSH access on the first boot.

4. **Password and User**:
   - The default user is **`pi`**.
   - The default password is **`raspberry`**.

### 2. **Network Connection**

Make sure that the Raspberry Pi is connected to a network. If you are using Ethernet, this should already be set up. If you want to use Wi-Fi, you'll need to configure the **`wpa_supplicant.conf`** file (more on that below).

## Installation and Setup

### Step 1: Clone the GitHub Repository

1. **Clone the Repo**:
   - Clone the repository to your local machine or directly to the Raspberry Pi if you have SSH access:

     ```bash
     git clone git@github.com:topa-LE/fullpageos-control.git
     cd fullpageos-control
     ```

### Step 2: Run Pi2 Script

1. **Run the Pi2 Setup Script**:
   - Go to the `hardware/pi2` directory and run the **`kiosk_setup_script_pi2.sh`** script:

     ```bash
     cd hardware/pi2
     sudo bash kiosk_setup_script_pi2.sh
     ```

   - This script will install all the necessary dependencies and configure FullPageOS for the Raspberry Pi 2.

### Step 3: Configure Kiosk Mode

1. **Set Up Kiosk Mode**:
   - FullPageOS is configured to start the Chromium browser in Kiosk Mode on boot. The browser will display a pre-set URL, which you can change in the scripts.

2. **Make Adjustments**:
   - Open the configuration file **`/boot/config.txt`** to optimize hardware options, such as the display or GPU.

     Example of configuring the screen resolution:

     ```bash
     framebuffer_width=1920
     framebuffer_height=1080
     ```

### Step 4: Reboot and Test

1. **Reboot the Pi**:
   - Restart the Raspberry Pi:

     ```bash
     sudo reboot
     ```

2. **Check the Result**:
   - The Pi should now automatically start the Chromium browser in Kiosk Mode and display the configured webpage.

---

## Further Adjustments

- **Auto-start Applications**: You can configure applications to automatically start on boot by placing them in **`/home/pi/.config/autostart/`**.
- **Network and User Configurations**: Further adjustments like Wi-Fi configurations or user adjustments can be made in the respective configuration files.

---

## License

This project is licensed under the **MIT License**. See the **LICENSE.md** file for more details.
