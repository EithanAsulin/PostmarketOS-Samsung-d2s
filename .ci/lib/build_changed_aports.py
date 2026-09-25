#!/usr/bin/env python3
# Copyright 2021 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later
import os
import pathlib
import sys

# Same dir
import common

# pmbootstrap
import pmb.parse
import pmb.parse._apkbuild
from pmb.core.arch import Arch
from pmb.core.context import get_context


def build_packages(packages, arch: Arch):
    common.run_pmbootstrap(["build_init"])
    # We set the timeout to 1 hour because linking the Linux kernel with
    # ThinLTO on our aarch64 runners takes slightly over 30 minutes
    common.run_pmbootstrap(
        [
            "--details-to-stdout",
            "--no-ccache",
            "--timeout",
            "3600",
            "build",
            "--force",
            "--arch",
            str(arch),
        ]
        + list(packages)
    )


if __name__ == "__main__":
    # Architecture to build for (as in build-{arch})
    if len(sys.argv) != 2:
        print("usage: build_changed_aports.py ARCH")
        sys.exit(1)
    arch = Arch(sys.argv[1])

    # Full paths of changed packages, keeping the repo location
    # (e.g. "temp/foo" or "extra-repos/systemd/foo"), which is used to derive
    # which repo the package is in
    pkg_paths = common.get_changed_packages(skip_archived=True, keep_dir=True)

    # Load context
    sys.argv = ["pmbootstrap.py", "chroot"]
    args = pmb.parse.arguments()
    context = get_context()

    # Two groups, determined purely by path:
    #   packages --> default repos, built with systemd disabled
    #   systemd_pkgs --> extra-repos/systemd, built with systemd enabled
    # FIXME: this should probably be more generic, if other repos are added later?
    packages: list[str] = []
    systemd_pkgs: list[str] = []

    for path in pkg_paths:
        # path is relative to the pmaports root
        if path.startswith("extra-repos/systemd/"):
            group = systemd_pkgs
        else:
            group = packages

        apkbuild = pmb.parse._apkbuild.apkbuild(pathlib.Path(path, "APKBUILD"))
        if arch not in Arch.from_arch_field(apkbuild["arch"]):
            print(f"{path}: not enabled for {arch}, skipping")
            continue

        package = os.path.basename(path)
        # we are assuming that path will never end up with a trailing `/`, but
        # if for some reason it does then basename will return an empty string
        # and we need to guard against that
        assert package != ""
        group.append(os.path.basename(path))

    if packages:
        common.run_pmbootstrap(["config", "service_manager", "openrc"])
        build_packages(packages, arch)
    else:
        print(f"main: no packages changed, which can be built for {arch}")

    # Build packages in extra-repos/systemd (systemd must be enabled first)
    if systemd_pkgs:
        common.run_pmbootstrap(["config", "service_manager", "systemd"])
        # Fix "Chroot 'native' is for the 'edge' channel..." error by
        # auto-zapping misconfigured chroots.
        common.run_pmbootstrap(["config", "auto_zap_misconfigured_chroots", "yes"])
        build_packages(systemd_pkgs, arch)
    else:
        print(f"systemd: no packages changed, which can be built for {arch}")
