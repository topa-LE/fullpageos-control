#!/bin/bash

echo "🍓 PI2 CONFIG"

BOOT_CONFIG="/boot/config.txt"
[ -f /boot/firmware/config.txt ] && BOOT_CONFIG="/boot/firmware/config.txt"

cat <<'EOF' > $BOOT_CONFIG
dtparam=audio=on
camera_auto_detect=1
display_auto_detect=1
auto_initramfs=1

dtoverlay=vc4-fkms-v3d

gpu_mem=128
max_framebuffers=2

hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=82

disable_overscan=1
arm_boost=1

[all]
EOF
