#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# --- GIGGLE-INIT v1.1: THE NETWORKING UPDATE ---

# 1. MOUNT ESSENTIALS
# We ignore errors if they are already mounted by the kernel
mount -t proc proc /proc 2>/dev/null
mount -t sysfs sys /sys 2>/dev/null
mount -t devtmpfs dev /dev 2>/dev/null
mount -t tmpfs tmp /run 2>/dev/null
mount -t tmpfs tmp /tmp 2>/dev/null
mount -o remount,rw /

# 2. IDENTITY & NETWORKING
# Fixes the "(none)" prompt and gets us online
echo "GiggleBox" > /proc/sys/kernel/hostname
hostname -F /etc/hostname 2>/dev/null || hostname GiggleBox

ifconfig lo up
ifconfig eth0 up
udhcpc -i eth0 -b

# 3. DAEMONS
# D-Bus is the "glue" for Fastfetch and Plasma
mkdir -p /run/dbus
dbus-daemon --system --address=unix:path=/run/dbus/system_bus_socket 2>/dev/null &

echo ""
echo "****************************************"
echo "* GIGGLE-INIT: NETWORK & D-BUS ACTIVE  *"
echo "* Welcome to GiggleBox                 *"
echo "****************************************"
echo ""

# 4. THE REAPER FUNCTION
reap_and_monitor() {
    while true; do
        wait -n 2>/dev/null
    done
}

# 5. SIGNAL TRAPS
trap 'reboot' SIGINT
trap 'poweroff' SIGUSR1

# 6. EMERGENCY SHELL
# We export the hostname so the sub-shell knows who it is
export HOSTNAME=GiggleBox
setsid bash -l < /dev/tty1 > /dev/tty1 2>&1 &

# Keep PID 1 alive forever
reap_and_monitor
