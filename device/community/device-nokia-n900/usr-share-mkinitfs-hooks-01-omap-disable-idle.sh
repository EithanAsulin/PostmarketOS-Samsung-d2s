#!/bin/busybox ash

# Disable OMAP 3430 SoC OFF mode. It is currently unreliable and leads to
# system lockup and crashes.
mount -t debugfs none /sys/kernel/debug || true
echo 0 > /sys/kernel/debug/pm_debug/enable_off_mode || true
