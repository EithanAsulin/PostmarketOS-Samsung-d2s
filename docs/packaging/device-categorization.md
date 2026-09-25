# Device Categorization

There are a [lot of devices](https://wiki.postmarketos.org/wiki/Devices) that
can boot postmarketOS. These devices are divided into different categories. The
categorization serves to provide users with information about what to expect in
the present and future from a specific device. Therefore, the categories provide
information about a minimum set of working features, but also about the expected
level of support and stability that those features will have in the future.

## Categories

Although there are distinct categories, device support on-paper might not match
reality. Especially in regards to device features: some devices in lower
categories might match the requirements of higher categories, but the commitment
or support from maintainers might be lower than what higher categories require.

### Main

Main devices should be usable in the most common use-cases for which the device
is designed. They are also expected to be reliable and have few regressions in
functionality. One can expect some level of support from the postmarketOS team,
always respecting the volunteer nature of the project. See
[state](https://postmarketos.org/state/) to understand what that means.

Requirements:
* The [postmarketOS team](https://postmarketos.org/team) must endorse the new
  device.
* A device maintainer team of at least 5 people, of which the majority are
  part of the [postmarketOS team](https://postmarketos.org/team).
* The postmarketOS team and device maintainer teams must cover their
  responsibilities as listed below. Within the teams, they must figure out
  themselves who covers what responsibilities.
* Hardware CI in at least two locations for (in total) at least 3 devices.
* Boot via UEFI.
* Must use
  [generic postmarketOS kernels](https://docs.postmarketos.org/pmaports/main/generic-kernels.html)
* Must not depend on forked device-specific packages, such as forks of
  `alsa-ucm-conf`.
* Must use a generic device package for the target architecture.
* Everything from community (see below).

Responsibilities for the postmarketOS team:
* Regularly checking if requirements are still fulfilled, and if not:
  * Discuss with the device maintainers team.
  * Make calls for help early to e.g. find new members for the device
    maintainers team.
* Remove the device from main after 6 months of having the requirements
  unfulfilled.

Responsibilities for the device maintainer team:
* `device-$vendor-$codename.md`:
  * Maintain a file inside pmaports that
    explains what features are working, and which ones are not.
  * The working features should allow to use the device in most common use
    cases. A phone for example would typically have calls, SMS, mobile data,
    Wi-Fi, audio, battery charging, Bluetooth and camera. Exceptions can be
    made by the device maintainer team, together with reasoning why they are
    necessary (e.g. fingerprint reader is not working because the driver is
    missing). The postmarketOS team decides if the port is complete enough for
    the main category based on that list.
* Organize regular meetings with device maintainers.
* Organize regular meetings with vendors (if we have contacts there).
* Long-term commitment for the device.
  * People can step down as needed of course, if possible try to give an
    advance notice.
  * Please don't try to get a device in main if you plan to be away soon.
* Kernel maintenance (Fixing regressions on the kernel side, new kernel
  developments).
* Triage issues found by the community and HW CI regressions.
* Documentation for this device.
* Making sure Hardware CI works (wires are connected, preparing CI).
* Manual testing where necessary.

### Community

Community devices have a reasonable set of features enabled, although there is
not a fixed feature set: users should not assume that everything works and are
expected to look at the device wiki page. Community devices have generally
received a lot of work and should, in general, remain working quite
well. However, there is no commitment from the postmarketOS team, and it can
happen that maintainers are unable to continue working on them, leading to them
eventually getting demoted. The team will always notify the community about such
changes through the standard communication channels: Fediverse and blog posts.

Requirements:

* Well documented installation instructions on device wiki page
* Close-to-mainline kernel
* Kernel must pass `pmbootstrap kconfig check --community`, which includes
  working firewall
  ([#1119](https://gitlab.postmarketos.org/postmarketOS/pmaports/-/issues/1119))
* Automatic kernel upgrades must work <!-- TODO: move the list below elsewhere
  and reference it to make this list shorter -->
  * When upgrading the kernel, the new kernel must be used on reboot
  * Android devices where a new `boot.img` must be flashed after upgrade need
    `deviceinfo_flash_kernel_on_update=true`.
  * For other devices which directly boot a kernel from a boot partition, or
    which use lk2nd, usually nothing needs to be done.
* Maintainer(s) must take part in the workflow for new postmarketOS releases:
  * Join the [testing
    channel](https://wiki.postmarketos.org/wiki/Matrix_and_IRC) coordinate the
    release
  * Testing their device and related fixing issues, according to the
    [timeline](https://wiki.postmarketos.org/wiki/Creating_a_release_branch#Timeline)
    (test yourself/coordinate with the
    [Testing Team](https://wiki.postmarketos.org/wiki/Testing_Team); testing
    one device per SoC is enough for community devices, but of course more is
    better)
* Kernel must at least have been upgraded through 3 kernel releases
* Kernel version used by the device may not be older than 6 months. The age of
  the kernel version is determined by the date the release was
  [tagged](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/refs/tags)
  upstream by Linus Torvalds or the stable kernel maintainers.
  For e.g. version 6.12.3, the date would be that of the specific patch release,
  not that of the initial 6.12 release

### Testing

Testing devices cover devices with close-to-mainline kernels and other minimal
requirements. Devices on this category might have few, or many features enabled,
and there are no expectations on maintainers regarding user support. In
consequence, users of testing devices must consider that their devices could be
archived at any time and without notice.

Requirements:

* Must run a close-to-mainline kernel as new or newer than the oldest supported LTS release
  * The kernel version does not need to be the latest released patch version
* Kernel must be compiled with LLVM
* Port and dependencies build
* The device boots

### Downstream

Device ports using vendor/downstream kernels. These kernels and devices are only
advised to be used as a step towards using mainline, at which point they would
be moved to testing. Depending on downstream ports as an user can be
problematic, as kernels and devices in this category might be moved to archived
at any time. This will happen if the port no longer builds, lacks a maintainer,
or the maintainer is unresponsive. Downstream ports are also often unable to
support modern userspace components like Docker or systemd.

Requirements:

* Port and dependencies build
* The device boots

(device-category-archived)=
### Archived

A port might be in archived if the port has been replaced with a better
alternative (e.g. ports using downstream kernels when a functional mainline port
exists), the port no longer boots with the current version of postmarketOS,
or it became unmaintained.

The archived category exists to simplify bringing back old ports (so new
maintainers don't have to dig through the git history), and for specific
situations where it is useful for developers to share a non-recommended
downstream kernel. Therefore, archived ports aren't listed in `pmbootstrap init`
and binary packages are not built for them. However, they can still be manually
selected and built by entering the device codename. Although, doing this will display
a warning with the reason why they have been archived.

This category was formerly called *unmaintained*
([!1912](https://gitlab.postmarketos.org/postmarketOS/pmaports/-/merge_requests/1912),
[!5046](https://gitlab.postmarketos.org/postmarketOS/pmaports/-/merge_requests/5046)).

## Official Images

Official images are built by [BPO](https://build.postmarketos.org). We
configure the images as follows:

* Build images for _all_ devices in main and community
* Build images for _some_ devices in testing, maintainers may
  [enable building images](https://wiki.postmarketos.org/wiki/Bpo#Image_configuration) if:
  * The port runs a mainline kernel.
  * The port is actively maintained.
  * The maintainer has been active for some time (~6 months).

We may adjust these rules again, e.g. depending on how many testing devices will
be added over time. Testing images may be removed again, e.g. if they don't
build anymore because of device specific problems.

## Maintainers

A device maintainer must own the device and be able to test changes. They must
make sure that the device port stays in good shape.

## Moving between categories

### Moving to a higher category

Moving from testing to community, from community to main or even from testing
straight to main.

#### Request process

* Make sure that the device fulfills all requirements for the new category (see
  table above).
* Create a new merge request in which you move the files.
* Add new maintainers to the device's APKBUILD, if necessary.

#### Review process

* Everyone should be given the chance to look at the entire device port again,
  to identify issues/possible improvements. Therefore the MR should not be
  merged before a *minimum time of one week* passed. Usually, the MR should be
  in good shape when opened, and only minor fixups should need to be done
  before merging. If that is the case, then it is one week after the MR was
  opened. Otherwise, one week after there were the last significant changes.
* Reviewers should look at all files that were moved and add comments as
  necessary. (GitLab currently doesn't allow in-line comments for moved files
  ([#213446](https://gitlab.com/gitlab-org/gitlab/-/issues/213446)), so
  just add comments below the merge request.)
* Reviewers should verify that the device fulfills all requirements for the new
  category (see table above).
* Reviewers should pay special attention to consistency issues, as outlined in
  [postmarketos#24](https://gitlab.postmarketos.org/postmarketOS/postmarketos/-/issues/24).
* Consistency issues/possible improvements in the existing features (not
  missing features) should be discussed and ideally fixed before merge.
  Consistency changes that require lots of work should be documented as issues
  an expect to be fixed in the future, but should not unnecessarily delay
  merge.
* Before merging, the MR must have at least *four approvals* from team members

#### After merge

* Change the category of the devices in the wiki
* When moved from testing to community:
  [enable building images](https://wiki.postmarketos.org/wiki/Bpo#Image_configuration)

### Moving to a lower category

If rules to keep a device in a category are no longer fulfilled, an attempt to
contact the device maintainers and make them aware of the situation must be
made. The maintainers then have two weeks to ensure the device meets the criteria
again. Maintainers can request additional time in response, but only up to one
more month from the time they were contacted. If a stable release is scheduled
for branching in that timeframe, additional time can only be requested up until
the date of the branching.

If the maintainers cannot be contacted, or if two weeks and any additionally
requested time pass and the device still does not meet the criteria, a merge
request to move them to the now appropriate category should be opened. If the
device being demoted is in the main or community category, the community shall
be notified through Fediverse and blog posts (edge blog post, release notes, or
next monthly blog post).

Merge requests moving a device to a lower category are subject to the standard
[pmaports approval rules](../merge-requests/approval-rules).

## See also

* [postmarketos#25](https://gitlab.postmarketos.org/postmarketOS/postmarketos/-/issues/25) requirements for devices in main
* [postmarketos#24](https://gitlab.postmarketos.org/postmarketOS/postmarketos/-/issues/24) requirements for devices in community
* [postmarketos#16](https://gitlab.postmarketos.org/postmarketOS/postmarketos/-/issues/16)
 Increase visibility of actively maintained devices
* [postmarketos#11](https://gitlab.postmarketos.org/postmarketOS/postmarketos/issues/11#get-serious-about-supported-devices)
  Get serious about supported devices
