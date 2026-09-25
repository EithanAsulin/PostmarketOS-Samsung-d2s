# Copyright 2021 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later

from pathlib import Path

import common
import pmb.parse
from pmb.core.arch import Arch
from pmb.core.pkgrepo import pkgrepo_iglob


def test_aports_ui():
    """
    Raise an error if package in _pmb_recommends is not found
    """
    pmaports_cfg = pmb.config.pmaports.read_config()
    for arch_string in pmaports_cfg["supported_arches"].split(","):
        for path in common.get_changed_files():
            arch = Arch(arch_string)
            path = Path(path)

            if path.name != "APKBUILD":
                continue
            if not path.parent.name.startswith("postmarketos-ui"):
                continue

            apkbuild = pmb.parse.apkbuild(path)
            # Skip if arch isn't enabled
            if arch not in Arch.from_arch_field(apkbuild["arch"]):
                continue

            for package in apkbuild["_pmb_recommends"]:
                depend = pmb.helpers.package.get(package, arch, must_exist=False)
                if depend is None:
                    raise RuntimeError(
                        f"{path}: package '{package}' from"
                        f" _pmb_recommends not found for arch '{arch}'"
                    )

            # Check packages from "_pmb_recommends" of -extras subpackage if one exists
            if f"{apkbuild['pkgname']}-extras" in apkbuild["subpackages"]:
                apkbuild = apkbuild["subpackages"][f"{apkbuild['pkgname']}-extras"]
                for package in apkbuild["_pmb_recommends"]:
                    depend = pmb.helpers.package.get(package, arch, must_exist=False)
                    if depend is None:
                        raise RuntimeError(
                            f"{path}: package '{package}' from _pmb_recommends "
                            f"of -extras subpackage is not found for arch '{arch}'"
                        )


def test_aports_ui_service_manager():
    """
    Enforce we have valid systemd / openrc options in each UI package.
    https://docs.postmarketos.org/pmaports/main/packaging/ui-packages/apkbuild-metadata.html
    """
    for path in pkgrepo_iglob("main/postmarketos-ui-*/APKBUILD"):
        opts = pmb.parse.apkbuild(path)["options"]

        assert "pmb:default-systemd" in opts or "pmb:default-openrc" in opts, (
            f"{path}: must have either pmb:default-systemd or pmb:default-openrc"
        )

        assert "pmb:default-systemd" not in opts or "pmb:default-openrc" not in opts, (
            f"{path}: can't have both pmb:default-systemd and pmb:default-openrc"
        )

        if "pmb:default-systemd" in opts:
            assert "pmb:support-systemd" in opts, (
                f"{path}: pmb:default-systemd without pmb:support-systemd"
            )

        if "pmb:default-openrc" in opts:
            assert "pmb:support-openrc" in opts, (
                f"{path}: pmb:default-openrc without pmb:support-openrc"
            )
