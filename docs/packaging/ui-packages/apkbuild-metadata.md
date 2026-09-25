# APKBUILD Metadata

The UI packages have additional metadata specified via custom APKBUILD
variables and options.

## Variables

- **_pmb_groups**
  - Groups to which the default user should be added to during the
    installation.
(pmb-recommends)=
- **_pmb_recommends**
  - Packages to install together with the UI, which can be uninstalled by the
     user.
- **_pmb_select**
  - Let `pmbootstrap init` display a prompt for each package in the given list
    of packages to choose which provider to use for each package.
- **_pmb_default**
  - Define the package to display as default during a `pmbootstrap init`
    `_pmb_select` prompt. Without this, the package with the highest priority
    will list as default .
- **pkgdesc**
  - The same as a normal APKBUILD's `pkgdesc`, but it is also shown during
    `pmbootstrap init` beside the UI's name.

(ui-packages-apkbuild-options)=
## Options

The following can be added to the `options` variable:

- **pmb:drm**
  - Adding this to the `options` variable will mark the UI as requiring DRM
    support to function, hiding it from devices that do not support DRM on
    `pmbootstrap init`.
- **pmb:default-systemd**
  - Adding this to the `options` variable will declare systemd as the default
    service manager for the UI.
- **pmb:support-systemd**
  - Adding this to the `options` variable will allow selecting the UI with
    systemd during `pmbootstrap init`. Requires a `pmb:default-*` option.
- **pmb:default-openrc**
  - Adding this to the `options` variable will declare OpenRC as the default
    service manager for the UI.
- **pmb:support-openrc**
  - Adding this to the `options` variable will allow selecting the UI with
    OpenRC during `pmbootstrap init`. Requires a `pmb:default-*` option.
