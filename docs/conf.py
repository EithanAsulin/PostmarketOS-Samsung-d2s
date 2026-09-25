# Configuration file for the Sphinx documentation builder.

import datetime
from pathlib import Path
import subprocess

project = "pmaports"
copyright = str(datetime.date.today().year) + ", postmarketOS contributors"
exclude_patterns = ["_build", "_out", "Thumbs.db", ".DS_Store", ".venv", "README.md"]

extensions = [
    "myst_parser",
    "sphinx.ext.autodoc",
    "sphinx.ext.autosummary",
    "sphinx.ext.doctest",
    "sphinx_reredirects",
    "sphinxcontrib.autoprogram",
    "sphinxcontrib.jquery",
]
myst_enable_extensions = ["colon_fence"]

html_theme = "pmos"
html_theme_options = {
    "source_edit_link": "https://gitlab.postmarketos.org/postmarketOS/pmaports/-/blob/main/docs/{filename}",
}

# Set the explicit title of the HTML output
html_title = "postmarketOS Packaging"

# Redirects for moved pages
redirects = {
    "approval-rules": "merge-requests/approval-rules.html",
    "ci-tags": "ci/ci-tags.html",
    "device-categorization": "packaging/device-categorization.html",
    "deviceinfo-reference": "packaging/device-packages/deviceinfo-reference.html",
    "firmware": "packaging/firmware-packages.html",
    "generic-device-packages": "packaging/device-packages/generic-device-packages.html",
    "generic-kernels": "packaging/kernel-packages/generic-kernel-packages.html",
    "hardware-ci": "ci/hardware-ci.html",
    "kconfig-fragments": "packaging/kernel-packages/kconfig-fragments.html",
    "kconfigcheck": "packaging/kernel-packages/kconfigcheck.html",
    "kernel-cmdline": "packaging/kernel-packages/kernel-cmdline.html",
    "kernel-versions": "packaging/kernel-packages/kernel-versions.html",
    "packaging-guidelines": "packaging.html",
    "releases/backporting": "merge-requests/stable-branches.html",
    "ui-packages": "packaging/ui-packages.html",
}

def run_dint_doc(app):
    docs_dir = Path(__file__).parent

    with docs_dir.joinpath("packaging/device-packages/deviceinfo-reference.md").open("w") as f:
        schema_path = docs_dir.parent / "deviceinfo_schema.toml"

        subprocess.run(["dint", "doc"], stdout=f, check=True, env={"DINT_SCHEMA_PATH": schema_path})


def setup(app):
    app.connect("builder-inited", run_dint_doc)
