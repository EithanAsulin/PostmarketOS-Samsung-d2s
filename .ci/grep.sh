#!/bin/sh -e

# shellcheck shell=busybox

# Description: check various bad patterns with grep
# https://postmarketos.org/pmb-ci

exit_code=0

if [ "$(id -u)" = 0 ]; then
	set -x
	apk -q add git grep
	exec su "${TESTUSER:-build}" -c "sh -e $0"
fi

# Find CHANGEMEs in APKBUILDs
if grep -qr '(CHANGEME!)' -- *; then
	echo "ERROR: Please replace '(CHANGEME!)' in the following files:"
	grep --color=always -r '(CHANGEME!)' -- *
	exit_code=1
fi

# DTBs installed to /usr/share/db
# shellcheck disable=SC2016
if grep -qr 'INSTALL_DTBS_PATH="$pkgdir"/usr/share/dtb' device/; then
	echo 'ERROR: Please do not install dtbs to /usr/share/dtb!'
	echo 'ERROR: Unless you have a good reason not to, please put them in /boot/dtbs'
	echo 'ERROR: Files that need fixing:'
	# shellcheck disable=SC2016
	grep --color=always -r 'INSTALL_DTBS_PATH="$pkgdir"/usr/share/dtb' device/
	exit_code=1
fi


# Find old mkinitfs paths (pre mkinitfs 2.0)
if grep -qr '/etc/postmarketos-mkinitfs' -- *; then
	echo "ERROR: Please replace '/etc/postmarketos-mkinitfs' with '/usr/share/mkinitfs' in the following files:"
	grep --color=always -r '/etc/postmarketos-mkinitfs' -- *
	exit_code=1
fi
if grep -qr '/usr/share/postmarketos-mkinitfs' -- *; then
	echo "ERROR: Please replace '/usr/share/postmarketos-mkinitfs' with '/usr/share/mkinitfs' in the following files:"
	grep --color=always -r '/usr/share/postmarketos-mkinitfs' -- *
	exit_code=1
fi

# Direct sourcing of deviceinfo
if grep --exclude='source_deviceinfo' -qEr 'source /etc/deviceinfo|\. /etc/deviceinfo' -- *; then
	echo 'ERROR: Please source the source_deviceinfo script instead of sourcing deviceinfo directly!'
	grep --color=always --exclude='rootfs-usr-share-misc-source_deviceinfo' -Er 'source /etc/deviceinfo|\. /etc/deviceinfo' -- *
	exit_code=1
fi

# Removed deviceinfo variable
if grep -qr 'deviceinfo_modules_initfs' -- *; then
	echo 'ERROR: deviceinfo_modules_initfs variable has been removed. Use "modules-initfs" file instead.'
	grep --color=always -r 'deviceinfo_modules_initfs' -- *
	exit_code=1
fi

POSTMARKETOS_WALLPAPER_PATH='/usr/share/wallpapers/postmarketos.jpg'
# See https://gitlab.postmarketos.org/postmarketOS/pmaports/-/issues/2529
if grep -qr $POSTMARKETOS_WALLPAPER_PATH --exclude-dir='archived' -- device; then
	echo "ERROR: Please don't include configuration files that set the default wallpaper in device-specific packages!"
	grep --color=always -r $POSTMARKETOS_WALLPAPER_PATH --exclude-dir='archived' -- device
	exit_code=1
fi

OPENRC_SERVICE_FILES=$(find . -name '*.initd')
# shellcheck disable=SC2086
if grep -q 'before wpa_supplicant' $OPENRC_SERVICE_FILES; then
	echo "ERROR: Please use 'before wlan' in OpenRC service files! This ensures compatibility with both wpa_supplicant and iwd."
	grep --color=always 'before wpa_supplicant' $OPENRC_SERVICE_FILES
	exit_code=1
fi

if grep -qEr 'PMOS_NO_OUTPUT_REDIRECT' -- *; then
	echo "ERROR: PMOS_NO_OUTPUT_REDIRECT is deprecated and doesn't do anything."
	echo "Please remove it from the following files:"
	grep --color=always -Er 'PMOS_NO_OUTPUT_REDIRECT' -- *
	exit_code=1
fi

if grep -qEr '^deviceinfo_kernel_cmdline.*[\"\s]console=null' -- device/; then
	echo "ERROR: Do not use console=null in the kernel command line."
	echo "Use these params to quiet console on boot: quiet loglevel=2"
	echo "For more information, see: https://gitlab.postmarketos.org/postmarketOS/pmaports/-/issues/2989"
	exit_code=1
fi

# Disallow installation of files to /etc/modules-load.d and /etc/modprobe.d
if grep -qr '/etc/modules-load.d' --exclude-dir='device-samsung-golden-downstream' -- *; then
	echo "ERROR: Please replace '/etc/modules-load.d' with '/usr/lib/modules-load.d' in the following files:"
	grep --color=always -r '/etc/modules-load.d' --exclude-dir='device-samsung-golden-downstream' -- *
	exit_code=1
fi
# n900 is excluded because the string is in a comment linking to a repo.
# No other non-archived devices should be excluded.
if grep -qr '/etc/modprobe.d' --exclude-dir='archived' \
		--exclude-dir='device-nokia-n900' -- *; then
			echo "ERROR: Please replace '/etc/modprobe.d' with '/usr/lib/modprobe.d' in the following files:"
			grep --color=always -r '/etc/modprobe.d' --exclude-dir='device-nokia-n900' \
				--exclude-dir='archived' -- *
	exit_code=1
fi

# Disallow maintainer comments.
if grep -qr '# Maintainer:' -- *; then
	echo 'ERROR: Please use maintainer variables of the form maintainer="..." instead of maintainer comments of the form # Maintainer: ...'
	grep --color=always -r '# Maintainer:' -- *
	exit_code=1
fi

# Disallow sysadmin OpenRC files
if grep -qr '/etc/local.d' --exclude-dir='archived' -- *; then
	echo "ERROR: Please replace the '/etc/local.d' script with real OpenRC service files."
	echo "See https://gitlab.postmarketos.org/postmarketOS/pmaports/-/work_items/4360"
	grep --color=always -r '/etc/local.d' --exclude-dir='archived' -- *
	exit_code=1
fi

# Disallow installation of files to /etc/phoc.ini
if grep -qr '/etc/phoc.ini' --exclude-dir='archived' -- *; then
	echo "ERROR: Please replace '/etc/phoc.ini' with '/usr/share/phosh/phoc.ini'"
	echo "and add 'replaces=phosh' in the following files:"
	grep --color=always -r '/etc/phoc.ini' --exclude-dir='archived' -- *
	exit_code=1
fi

# Disallow contributor comments
if grep -qr '# Contributor:' --exclude-dir='docs' -- *; then
	echo 'ERROR: Please remove the contributor comment(s).'
	echo "See https://docs.postmarketos.org/pmaports/main/packaging.html"
	grep --color=always -r '# Contributor:' --exclude-dir='docs' -- *
	exit_code=1
fi

	# Disallow non-free firmware subpackages
if grep -qr 'pkgname-nonfree-firmware' --exclude-dir='archived' -- *; then
	echo "ERROR: Please remove the nonfree-firmware subpackage(s) and move the firmware to depends in the following APKBUILDs."
	echo "See https://docs.postmarketos.org/pmaports/main/packaging/firmware-packages.html"
	grep --color=always -r 'pkgname-nonfree-firmware' --exclude-dir='archived' -- *
	exit_code=1
fi

if [ -n "$CI_MERGE_REQUEST_DIFF_BASE_SHA" ]; then
	# Find all added, modified or renamed kernel APKBUILDs in main, community or testing
	MODIFIED_MAINLINE_KERNEL_PACKAGES=$(git show --pretty="" --name-only --diff-filter=AMR "$CI_MERGE_REQUEST_DIFF_BASE_SHA"..HEAD | grep "device/\(main\|community\|testing\)/linux-.*/APKBUILD" || true)

	if [ -n "$MODIFIED_MAINLINE_KERNEL_PACKAGES" ]; then
		if [ -n "$(grep -L LLVM=1 $MODIFIED_MAINLINE_KERNEL_PACKAGES || true)" ]; then
			echo "ERROR: A new or modified close-to-mainline kernel package is not being built with LLVM."
			echo "See https://postmarketos.org/edge/2025/11/11/kernels-llvm/ for more details"
			grep --color=always -L LLVM=1 $MODIFIED_MAINLINE_KERNEL_PACKAGES
			exit_code=1
		fi
	fi

	# Find all moved, added, or generally modified kernel APKBUILDs
	MODIFIED_KERNEL_PACKAGES=$(git show --pretty="" --name-only --diff-filter=AMR "$CI_MERGE_REQUEST_DIFF_BASE_SHA"..HEAD | grep "device/\(main\|community\|testing\|downstream\)/linux-.*/APKBUILD" || true)

	if [ -n "$MODIFIED_KERNEL_PACKAGES" ]; then
		# Disallow installing kernel modules outside /usr/
		_bad_module_path_packages=""
		for package in $MODIFIED_KERNEL_PACKAGES; do
			# Check for INSTALL_MOD_PATH being set
			if grep -qr 'INSTALL_MOD_PATH="$pkgdir"' "$package"; then
				# Check if INSTALL_MOD_PATH is set to install to usr
				if ! grep -qr 'INSTALL_MOD_PATH="$pkgdir"/usr' "$package"; then
					# If INSTALL_MOD_PATH doesn't include usr, add package to list and
					# setup failure
					_bad_module_path_packages="$_bad_module_path_packages $package"
					_module_error=1
				fi
			fi
		done
		# Fail with error and pretty print bad packages for logging
		if [ -n "$_module_error" ]; then
			echo "ERROR: Please set INSTALL_MOD_PATH to '\"\$pkgdir\"/usr'."
			for package in $_bad_module_path_packages; do
				printf "$package\n"
			done
			exit_code=1
		fi
	fi

	# Disallow adding packages without a maintainer set
	NEW_APKBUILDS=$(git show --pretty="" --name-only --diff-filter=A "$CI_MERGE_REQUEST_DIFF_BASE_SHA"..HEAD | grep APKBUILD || true)

	if [ -n "$NEW_APKBUILDS" ]; then
		if [ -n "$(grep -L '^maintainer="[^"]\+"$' $NEW_APKBUILDS || true)" ]; then
			echo "ERROR: A new package does not have a maintainer set."
			grep --color=always -L '^maintainer="[^"]\+"$' $NEW_APKBUILDS
			exit_code=1
		fi
	fi

	# Get latest commit message in MR
	case "$CI_COMMIT_DESCRIPTION" in
		*"[ci:skip-grep]"*)
			echo "WARNING: not checking packages with grep"
			echo " ([ci:skip-grep])!"
			exit_code=0
			;;
	esac
fi

exit "$exit_code"
