#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later

import os
import subprocess
import sys

import common
import tomllib

custom_valid_options = [
    "!pmb:crossdirect",
    "!pmb:kconfigcheck",
    "pmb:cross-native",
    "pmb:cross-native2",
    "pmb:default-openrc",
    "pmb:default-systemd",
    "pmb:drm",
    "pmb:generic-kernel",
    "pmb:support-openrc",
    "pmb:support-systemd",
]


def get_kconfigcheck_categories() -> list[str]:
    with open("kconfigcheck.toml", "rb") as kconfigcheck_config:
        kconfigcheck_data = tomllib.load(kconfigcheck_config)

    kconfigcheck_categories = []

    for category_name in kconfigcheck_data:
        if category_name == "aliases":
            for alias_name in kconfigcheck_data["aliases"]:
                kconfigcheck_categories.append(f"pmb:kconfigcheck-{alias_name}")
        else:
            kconfigcheck_categories.append(category_name)

    return [
        item.replace("category:", "pmb:kconfigcheck-")
        for item in kconfigcheck_categories
    ]


if __name__ == "__main__":
    if common.commit_message_has_string("[ci:skip-apkbuild-lint]"):
        print("WARNING: not linting deviceinfo files ([ci:skip-apkbuild-lint])")
        sys.exit(0)

    kconfigcheck_categories = get_kconfigcheck_categories()
    custom_valid_options += kconfigcheck_categories
    os.environ["CUSTOM_VALID_OPTIONS"] = " ".join(custom_valid_options)

    apkbuilds = {
        file
        for file in common.get_changed_files()
        if os.path.basename(file) == "APKBUILD"
    }
    if len(apkbuilds) < 1:
        print("No APKBUILDs to lint")
        sys.exit(0)

    apkbuilds_filtered = []
    for apkbuild in apkbuilds:
        if apkbuild.startswith(("temp/", "cross/")):
            print(f"NOTE: Skipping linting of {apkbuild}")
            continue
        apkbuilds_filtered.append(apkbuild)
    if len(apkbuilds_filtered) < 1:
        print("No APKBUILDs to lint")
        sys.exit(0)

    print("Running apkbuild-lint...")
    print()

    ret = 0
    for apkbuild in apkbuilds_filtered:
        try:
            cmd = ["apkbuild-lint", apkbuild]
            subprocess.run(cmd, text=True, check=True)
        except subprocess.CalledProcessError as exception:
            ret = exception.returncode

    print()
    if ret == 0:
        print("Success")

    sys.exit(ret)
