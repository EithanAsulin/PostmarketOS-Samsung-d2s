#!/usr/bin/env python3
# Copyright 2026 Alexandre MINETTE
# SPDX-License-Identifier: GPL-3.0-or-later
# Extract jflte ICE4 FPGA firmware blobs from downstream source into a mainline .bin firmware file.
# https://raw.githubusercontent.com/LineageOS/android_kernel_samsung_jf/refs/heads/lineage-18.1/drivers/barcode_emul/barcode_emul_ice4.h

from __future__ import annotations

import argparse
import hashlib
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]

ARRAY_RE = re.compile(
    r"const\s+u8\s+(?P<name>\w+)\s*\[\]\s*=\s*\{(?P<body>.*?)\s*\};",
    re.S,
)

OUTPUT_NAMES = {
    ("spiword_24m", 1): "ice4-dcm-spiword-24m.bin",
    ("spiword_24m", 2): "ice4-non-dcm-spiword-24m.bin",
    ("spiword_i2c", 1): "ice4-spiword-i2c.bin",
    ("spiword", 1): "ice4-spiword.bin",
    ("spiword_legacy", 1): "ice4-spiword-legacy.bin",
    ("spiword_irda", 1): "ice4-spiword-irda.bin",
    ("spiword_irda_serrano", 1): "ice4-spiword-irda-serrano.bin",
}
DEFAULT_FIRMWARE = "ice4-non-dcm-spiword-24m.bin"
DEFAULT_OUTPUT = "ice4.bin"


def parse_arrays(header: str) -> list[tuple[str, int, bytes]]:
    counts: dict[str, int] = {}
    blobs = []

    for match in ARRAY_RE.finditer(header):
        name = match.group("name")
        counts[name] = counts.get(name, 0) + 1
        occurrence = counts[name]
        values = [
            int(value, 16)
            for value in re.findall(r"0x([0-9A-Fa-f]{1,2})", match.group("body"))
        ]
        blobs.append((name, occurrence, bytes(values)))

    return blobs


def output_name(name: str, occurrence: int) -> str:
    try:
        return OUTPUT_NAMES[(name, occurrence)]
    except KeyError:
        suffix = f"-{occurrence}" if occurrence > 1 else ""
        fallback = name.replace("_", "-")
        return f"ice4-{fallback}{suffix}.bin"


def write_blob(path: Path, data: bytes) -> None:
    path.write_bytes(data)
    digest = hashlib.sha256(data).hexdigest()
    print(f"wrote {path} ({len(data)} bytes, sha256 {digest})")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Extract all downstream ICE4 firmware arrays as raw blobs."
    )
    parser.add_argument(
        "header",
        type=Path,
        help=f"downstream barcode_emul_ice4.h path",
    )
    parser.add_argument(
        "-o",
        "--output-dir",
        type=Path,
        help=f"output directory",
    )
    args = parser.parse_args()

    blobs = parse_arrays(args.header.read_text())
    if not blobs:
        raise ValueError("no ICE4 firmware arrays found")

    args.output_dir.mkdir(parents=True, exist_ok=True)
    by_output: dict[str, bytes] = {}

    for name, occurrence, data in blobs:
        filename = output_name(name, occurrence)
        by_output[filename] = data
        write_blob(args.output_dir / filename, data)

    default = by_output[DEFAULT_FIRMWARE]
    write_blob(args.output_dir / DEFAULT_OUTPUT, default)


if __name__ == "__main__":
    main()
