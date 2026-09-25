# Generic Kernels

postmarketOS includes a couple of generic kernel packages in the `main` device
category: `linux-postmarketos-mainline`, `linux-postmarketos-stable`,
`linux-postmarketos-lts` and `linux-next`.

These are kernels intended to work on a wide variety of devices and are the
postmarketOS equivalents to Alpine kernels such as `linux-stable` or
`linux-lts`. Having these kernels in postmarketOS means that we have full
control over the kernel configuration and build process, which allows us to
integrate them with our [kernel configuration checks](./kconfigcheck).

In the long term, all devices using Alpine kernels should be migrated to the
postmarketOS generic kernels.

## Configuration

Since it would be very tedious to manually update the configuration for
multiple kernel packages individually, the configuration for the kernels is
automatically generated from two sources in pmaports:

* `kconfigcheck.toml`, to make sure that they pass our checks
* `kconfig-generic.toml`, a file to enable device-specific drivers and apply
  opinionated configurations

The former is a file used by pmbootstrap to verify the configuration of all
kernels in pmaports, the latter is a file specifically for the configuration of
the generic kernel packages.

`pmbootstrap kconfig generate` will look at both of these files and generate a
fragment for each of them, which are then merged with the default `defconfig`
for an architecture in the Linux kernel.

## Adding new options

If a required option for your device is missing in the generic kernels, take a
moment to consider whether this is an option that *all* kernels in postmarketOS
should have enabled. If that's the case, then you should open a MR to add it
to `kconfigcheck.toml`, see [the documentation](./kconfigcheck) on the topic
for further details.

If that's not the case, then it is probably a good fit for
`kconfig-generic.toml`. Suppose your device has an Omnivision 8856 camera and
you'd like to enable the driver for it: In Linux, this requires setting
`CONFIG_VIDEO_OV8856=m` in the kernel configuration.

Check whether `kconfig-generic.toml` has an existing category that seems to fit
this configuration option (for example, `category:video`). If not, add a new
one, otherwise add it to the existing category. Categories in this TOML file
only exist for grouping things together, no filtering is performed, so don't
think too much about it.

If this configuration option was only added recently, find out since when it
exists in Linux.

You can then add to `kconfig-generic.toml`:

```toml
["category:video".">=6.12_rc1"."all"]
VIDEO_OV8856 = "m"
```

This would result in `CONFIG_VIDEO_OV8856=m` being set for all generic kernels
newer than 6.12-rc1 and enable it on all architectures.

Before submitting your change in a GitLab MR for the generic kernel maintainers
to review, make sure:

- Architecture scoping is as broad as possible. The default should be `"all"`
  unless there is a specific reason to restrict it to one architecture. For
  example, `CONFIG_PINCTRL_AMD` only makes sense on `x86_64`, but a config
  option like `CONFIG_I2C_DESIGNWARE_CORE` is not architecture-specific and
  should use `"all"`. When in doubt, prefer `"all"`.
- Each option is not already enabled or pulled in by a dependency in the
  existing config. Check the Kconfig dependency chain in the Linux kernel
  source. If an option you are already enabling selects another option via
  `select` in Kconfig, adding the selected option explicitly is redundant. You
  can check dependencies using `make menuconfig` or by reading the relevant
  `Kconfig` files.
- Device drivers are set to `"m"` (built as modules). Subsystem infrastructure
  and platform or bus dependencies that are prerequisites for drivers (for
  example, `I2C_DESIGNWARE_CORE` or `PINCTRL`) should be set to `"y"` instead.
- Categories in the file are sorted alphabetically.
- Unrelated config changes are split into separate MRs. For example, don't
  combine enabling a WiFi driver for a device with also enabling generic
  cryptography configs. A single MR with multiple configs is fine as long as
  they are related, for example all the drivers needed for one device.
- You have run `pmbootstrap kconfig generate` for all supported architectures
  and verified that your options appear in the generated configs.

Please do **not** regenerate the kernel configurations; your change will be
included as part of the next kernel upgrade. Rebuilds of the kernel packages
take a long time and they get updated regularly, so you'll only need to wait a
few days until your change makes it into the released binaries.

## Policy for patches

The following types of patches can be temporarily added to the generic kernels:

* Backporting of patches that are in `linux-next` to our `-mainline` and
  `-stable` kernels (not to `-lts`).
* Reverting patches that broke something (while also following up upstream to
  get the patch fixed or reverted).
* Patches to build the kernel with our toolchains (while also making sure those
  get upstreamed eventually)

Generally speaking, out-of-tree patches or non-upstreamable patches are not
acceptable for the generic kernels.

## Device package template

For a consistent packaging setup, we recommend following this template when
using the generic kernels in a device package:

<!-- editorconfig-checker-disable -->
<!-- It will complain about tabs. See pma#4784 -->
```shell
subpackages="
	$pkgname-kernel-stable:kernel_stable
	$pkgname-kernel-lts:kernel_lts
	$pkgname-kernel-mainline:kernel_mainline
	"
...

kernel_stable() {
	pkgdesc="Stable kernel (recommended, best balance between stability and features)"
	depends="linux-postmarketos-stable"
	devicepkg_subpackage_kernel $startdir $pkgname $subpkgname
}

kernel_lts() {
	pkgdesc="Long-term maintenance kernel (most stability, not all security fixes & new features)"
	depends="linux-postmarketos-lts"
	devicepkg_subpackage_kernel $startdir $pkgname $subpkgname
}

kernel_mainline() {
	pkgdesc="Upstream development kernel (regular breakage, latest features)"
	depends="linux-postmarketos-mainline"
	devicepkg_subpackage_kernel $startdir $pkgname $subpkgname
}
```
<!-- editorconfig-checker-enable -->

The `linux-next` kernel doesn't have to be part of device packages, and is only
intended to be enabled by device packages that want to enable it, but none of
them have to.
