#!/bin/sh
# Stop hciattach before system suspend to not interfere with
# freshly reset card after resume.
#
# In theory, No need to start it back here as it gets restarted automatically
# because of RequiredBy relation in its systemd unit.
case "$1" in
	pre)
		systemctl stop l5-brcm-bt-enable.service;
		/usr/bin/killall -q hciattach;
		;;
	post)
		# without this sleep hack, bluetooth hardly ever comes back
		/usr/bin/sleep 1;
		systemctl start --no-block l5-brcm-bt-enable.service;
		;;
esac
