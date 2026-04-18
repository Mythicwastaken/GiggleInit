#!/bin/bash

# --- GIGGLE-INIT v1.3 ---
# Bourne again out of pure sh chaos.

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
mount -t proc proc /proc 2>/dev/null
mount -t sysfs sys /sys 2>/dev/null
mount -t devtmpfs dev /dev 2>/dev/null
mount -t tmpfs tmp /run 2>/dev/null
mount -t tmpfs tmp /tmp 2>/dev/null
mount -o remount,rw /

echo "[GiggleInit] Scanning hardware (mdev)..."
mdev -s
echo "[GiggleInit] Loading VirtualBox network drivers..."
modprobe e1000 2>/dev/null || echo "[GiggleInit] e1000 load failed (already loaded?)"

echo "GiggleBox" > /proc/sys/kernel/hostname
hostname GiggleBox 2>/dev/null

echo "[GiggleInit] Activating eth0..."
ip link set lo up
ip link set eth0 up
sleep 1 

echo "[GiggleInit] Requesting DHCP lease..."
udhcpc -i eth0 -b


echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf


mkdir -p /run/dbus
dbus-daemon --system --address=unix:path=/run/dbus/system_bus_socket 2>/dev/null &

echo ""
echo "****************************************"
echo "* GIGGLE-INIT v1.3 IS ACTIVE           *"
echo "* Hostname: GiggleBox                  *"
echo "* Network: eth0 (UP)                   *"
echo "****************************************"
echo ""


reap_and_monitor() {
    while true; do
        wait -n 2>/dev/null
    done
}
trap 'reboot' SIGINT
trap 'poweroff' SIGUSR1


export HOSTNAME=GiggleBox
setsid bash -l < /dev/tty1 > /dev/tty1 2>&1 &


reap_and_monitor
