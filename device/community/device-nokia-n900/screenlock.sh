#!/bin/sh
set -e

kbd_backlight() {
	# The keyboard backlighting setup is based on 6 LEDs located above the
	# Ctrl, Q, and E keys on the left and O, comma, and Backspace on the
	# right. Thus the outermost keys are lit brighter than the innermost
	# keys when the brightness value is set equally, and this worsens as
	# the device ages, since the plastic diffuser deteriorates. Thus, set a
	# higher brightness for the innermost LEDs to get even lighting on all
	# keys.
	for i in $(seq 1 3); do
		pair=$((7 - i ))
		brightness=$(( i * $1 ))
		busctl call org.freedesktop.login1 /org/freedesktop/login1/session/auto \
		    org.freedesktop.login1.Session SetBrightness ssu \
		    "leds" "lp5523:kb$i" "$brightness"
		busctl call org.freedesktop.login1 /org/freedesktop/login1/session/auto \
		    org.freedesktop.login1.Session SetBrightness ssu \
		    "leds" "lp5523:kb$pair" "$brightness"
	done
}

x11_unlock() {
	export DISPLAY=:0
	xset dpms 0 0 0
	xset dpms force on
	xinput enable "TSC2005 touchscreen"
	xautolock -enable
}

x11_lock() {
	export DISPLAY=:0
	xautolock -disable
	xinput disable "TSC2005 touchscreen"
	xset dpms force off
	xset dpms 0 0 3
	kbd_backlight 0
}

sway_unlock() {
	SWAYSOCK="$(find /run/user/ -maxdepth 2 -name "*sway-ipc*")"
	export SWAYSOCK
	swaymsg output DPI-1 power on
	# Workaround wlroots bug, https://gitlab.freedesktop.org/wlroots/wlroots/-/work_items/4026
	swaymsg output DPI-1 power on
	swaymsg exec "swayidle timeout 120 'swaymsg exec screenlock.sh lock'"
	swaymsg input "0:2005:TSC2005_touchscreen" events enabled
}

sway_lock() {
	SWAYSOCK="$(find /run/user/ -maxdepth 2 -name "*sway-ipc*")"
	export SWAYSOCK
	swaymsg input "0:2005:TSC2005_touchscreen" events disabled
	swaymsg output DPI-1 power off
	pkill -f swayidle
	kbd_backlight 0
}

get_environment() {
	environment="unknown"
	if pgrep -nf Xorg > /dev/null; then
		environment="x11"
	elif pgrep -nf sway$ > /dev/null; then
		environment="sway"
	else
		# add other environments here
		exit 0
	fi
	echo "$environment"
}

toggle() {
	case "$(get_environment)" in
	x11)
		export DISPLAY=:0
		touch_state=$(xinput list-props "TSC2005 touchscreen" | grep "Device Enabled" | tr -d "\t" | cut -d ":" -f 2)
		;;
	sway)
		SWAYSOCK="$(find /run/user/ -maxdepth 2 -name "*sway-ipc*")"
		export SWAYSOCK
		touch_state=$(swaymsg -t get_inputs | jq -r '.[] | select (.identifier == "0:2005:TSC2005_touchscreen") | .libinput.send_events')
		;;
	esac

	case "$touch_state" in
	disabled)
		sway_unlock
		;;
	enabled)
		sway_lock
		;;
	0)
		x11_unlock
		;;
	1)
		x11_lock
		;;
	esac
}

if [ "$#" -ge 1 ]; then
	case "$1" in
		*lock)
			env="$(get_environment)"
			eval "$env"_"$1"
			;;
		kbd_backlight)
			shift 1
			kbd_backlight "$1"
			;;
	esac
else
	toggle
fi
