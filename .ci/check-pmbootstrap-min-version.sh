#!/bin/sh -e
# Description: Ensure that we're not depending on a too new pmbootstrap version.
# https://postmarketos.org/pmb-ci

if [ "$(id -u)" = 0 ]; then
	set -x
	apk -q add coreutils curl jq
	exec su "${TESTUSER:-build}" -c "sh -e $0"
fi

pmbootstrap_min_age_days="30"
pmbootstrap_min_version_field="$(grep pmbootstrap_min_version= pmaports.cfg)"
pmbootstrap_min_version="${pmbootstrap_min_version_field#*=}"

tag_date=$(curl -s "https://gitlab.postmarketos.org/api/v4/projects/postmarketOS%2Fpmbootstrap/repository/tags/$pmbootstrap_min_version" \
	| jq -r ".created_at")

tag_age_timestamp=$(date -d "$tag_date" +"%s")
acceptable_age_timestamp=$(date -d "$pmbootstrap_min_age_days days ago" +"%s")

echo "NOTE: pmbootstrap versions must be at least $pmbootstrap_min_age_days days old to be the minimum required version"

if [ "$tag_age_timestamp" -ge "$acceptable_age_timestamp" ]; then
	echo "ERROR: pmbootstrap version '$pmbootstrap_min_version' is too new!"
	exit 1
else
	echo "PASS: pmbootstrap version '$pmbootstrap_min_version' is acceptable"
	exit 0
fi
