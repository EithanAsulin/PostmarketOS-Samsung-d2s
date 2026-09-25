#!/bin/sh
#
# WindowMaker will wait until this script finishes, so if you run any
# commands that take long to execute (like a xterm), put a ``&'' in the
# end of the command line.
#
# This file must be executable.
#

# Start svkbd if installed and not already running
if command -v svkbd-mobile-intl && ! pgrep svkbd-mobile-intl; then
	svkbd-mobile-intl &
fi

if command -v unclutter-xfixes; then
	unclutter-xfixes --start-hidden --hide-on-touch &
fi
