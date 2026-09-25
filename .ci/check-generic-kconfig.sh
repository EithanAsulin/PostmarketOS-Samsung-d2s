#!/bin/sh

if [ "$(id -u)" = 0 ]; then
	set -x
	wget "https://gitlab.postmarketos.org/postmarketOS/ci-common/-/raw/main/install_pmbootstrap.sh"
	sh ./install_pmbootstrap.sh
	exec su "${TESTUSER:-pmos}" -c "sh -e $0"
fi

KERNELS="linux-postmarketos-lts linux-postmarketos-stable linux-postmarketos-mainline"
ARCHS="aarch64 armv7 loongarch64 ppc64le riscv64 x86_64"

TOTAL=0
PASSED=0
FAILED=0

echo "============================================"
echo "KERNELS: $KERNELS"
echo "ARCHS:   $ARCHS"
echo "============================================"

for kernel in $KERNELS; do
	for arch in $ARCHS; do
		TOTAL=$((TOTAL + 1))
		LOGFILE="kconfig-${kernel}-${arch}.log"
		STATUSFILE="status-${kernel}-${arch}.txt"

		echo "################################################################"
		echo "# TEST ${TOTAL}: Generating config for ${kernel} on ${arch}"
		echo "################################################################"

		# skip pmb's log and capture output to a separate log file for each test so
		# they can be presented as separate CI job artifacts
		if pmbootstrap --details-to-stdout kconfig generate "$kernel" --arch "$arch" > "$LOGFILE" 2>&1; then
			echo "✓ SUCCESS: ${kernel} on ${arch}"
			PASSED=$((PASSED + 1))
			echo "PASS" > "$STATUSFILE"
		else
			echo "✗ FAILED: ${kernel} on ${arch}"
			grep "ERROR:" "$LOGFILE"
			FAILED=$((FAILED + 1))
			echo "FAIL" > "$STATUSFILE"
		fi
		echo "################################################################"
		echo ""
	done
done

echo "============================================"
echo "SUMMARY"
echo "Total: ${TOTAL}, Passed: ${PASSED}, Failed: ${FAILED}"
echo "============================================"

if [ ${FAILED} -gt 0 ]; then
	echo ""
	echo "############################################"
	echo "# FAILED TESTS #"
	echo "############################################"

	for kernel in $KERNELS; do
		for arch in $ARCHS; do
			STATUSFILE="status-${kernel}-${arch}.txt"
			if [ -f "$STATUSFILE" ]; then
				STATUS=$(cat "$STATUSFILE")
				if [ "$STATUS" = "FAIL" ]; then
				echo ""
				echo ">>> FAILED TEST: ${kernel}:${arch} <<<"
				echo "See this artifact for details: kconfig-${kernel}-${arch}.log"
				echo "------------------------------------------------"
				fi
			fi
		done
	done
	exit 1
else
	echo "All tests passed!"
fi
