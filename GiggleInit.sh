#!/bin/bash

# --- THE GIGGLE-INIT MONSTROSITY ---
# A Bash-based PID 1 replacement for Alpine Linux

# 1. MOUNT ESSENTIALS
# The kernel gives us rootfs, but we need these for anything to work.
mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t devtmpfs dev /dev
mount -t tmpfs tmp /run
mount -t tmpfs tmp /tmp

# Remount root as Read-Write (Kernel usually starts it as Read-Only)
mount -o remount,rw /

echo ""
echo "****************************************"
echo "* GIGGLE-INIT IS NOW IN CONTROL     *"
echo "* Zombies, beware. Maybe.        *"
echo "****************************************"
echo ""

# 2. THE ZOMBIE REAPER (The "Wait" Loop)
# We run this in the foreground later to keep PID 1 alive.
reap_and_monitor() {
    echo "[GiggleInit] Monitoring processes..."
    while true; do
        # Wait for any process to change state
        # In a real init, we'd check which PID died and restart it.
        # Here, we just reap it to prevent ghosts in the machine.
        wait -n 2>/dev/null
        
        # If we reach here, a child died. 
        # Let's just output a snarky comment.
        echo "[GiggleInit] A child process exited. RIP."
    done
}

# 3. SIGNAL HANDLING
# We must catch these or the kernel might panic on a Ctrl+Alt+Del
trap 'echo "[GiggleInit] Reboot signal received!"; reboot' SIGINT
trap 'echo "[GiggleInit] Poweroff signal received!"; poweroff' SIGUSR1

# 4. START SERVICES
# Note: We background them with & so we don't get stuck.
echo "[GiggleInit] Starting Syslog..."
syslogd &

echo "[GiggleInit] Starting Network (lo)..."
ifconfig lo up &

echo "[GiggleInit] Starting Emergency Shell on tty1..."
# We use 'setsid' so the shell gets its own session
setsid bash < /dev/tty1 > /dev/tty1 2>&1 &

# 5. KEEP PID 1 ALIVE
# If this script exits, the kernel panics. 
reap_and_monitor

# 6. THE NUCLEAR OPTION
echo 1 > /proc/sys/kernel/sysrq
echo b > /proc/sysrq-trigger
