#!/bin/sh
# When adding new paths to trigger on here, make sure to also add them in
# triggers= in the APKBUILD.

printf "Running systemd-tmpfiles --create...\n"
systemd-tmpfiles --create

exit 0
