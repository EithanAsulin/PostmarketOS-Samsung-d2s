#!/bin/sh

# Persisted_Capsules.bin is huge (70 MB) and can cause boot-deploy failures
# when doing transactions that do large modifications to `/boot/`, such as
# switching kernel packages. Persisted_Capsules.bin is recreated on reboot
# and we do not use it for anything currently, so it is safe to remove in a
# hook.

printf "Removing Persisted_Capsules.bin...\n"
rm -f /boot/Persisted_Capsules.bin  >/dev/null 2>&1
