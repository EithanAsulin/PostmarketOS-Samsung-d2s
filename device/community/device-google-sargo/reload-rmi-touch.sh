#!/bin/sh
# Reload RMI touch driver on I2C errors.

trap 'exit 0' INT TERM

last_reload=0

while IFS= read -r line; do
	case "$line" in
	*"geni_i2c a84000.i2c:"*"failed"*)
		echo "I2C touch error detected on geni_i2c a84000.i2c"
		now=$(date +%s)
		# Debounce: only reload if it's been at least 30 seconds since the
		# last reload, in case errors come in bursts.
		if [ $((now - last_reload)) -ge 30 ]; then
			echo "Reloading RMI touch driver"
			modprobe -r rmi_i2c
			modprobe -r rmi_core
			modprobe rmi_core
			modprobe rmi_i2c
			last_reload=$(date +%s)
		fi
		;;
	esac
done < /dev/kmsg
