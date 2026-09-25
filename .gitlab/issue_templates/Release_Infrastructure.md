<!--
    This template is for creating a new postmarketOS stable release.

    Name this issue "vYY.MM Infrastructure".
-->

Person in charge of the release (doesn't have to do all the work, but has to
push it forward):
<!-- Put your usename here and assign yourself to this issue -->

### 0. Preparation
- [ ] Create the gitlab milestone for the release
- [ ] Add this infrastructure issue to the milestone
- [ ] Update the
      [timeline](https://docs.postmarketos.org/policies-and-processes/development/releases/current-timeline.html)
      for the next release

### 1. Pre-Build phase

This phase is to get some extra time for building packages. The branch will be rebased once in the branch phase.

#### Requirements

- [ ] Alpine's main repository must be built and published
- [ ] Alpine's community repository must be built and published
      <small>Without this, bpo won't be able to build packages but steps before
      that can be done already.</small>

#### pmbootstrap: adjust config
- [ ] Update `pmb/config/__init__.py:apk_tools_min_version`. This should be a
  trivial change, push it directly to main.
- [ ] (can be done later, at start of test phase) make a new [pmbootstrap
  release](https://wiki.postmarketos.org/wiki/Pmbootstrap_release) <small>bpo
  uses the main branch, so it will be fine without a release, however users
  will want to try out the new release and may not run main.</small>

#### pmaports: create branch and initial changes
- [ ] `git checkout -b vYY.MM main`
- [ ] Create a `=== Branch vYY.MM from main ===` commit
  - Remove channels.cfg (should only be in main)
  - Adjust `pmaports.cfg`: Change `channel=edge` to `channel=vYY.MM`
  - Adjust `pmaports.cfg`: Change `supported_arches` to `x86_64,aarch64,armv7`
  - Delete `.ci/build-*` scripts for other arches
    <small>`pmbootstrap ci` reads these</small>
- [ ] `git push`
- [ ] Ensure the branch is protected in the
      [repository settings](https://gitlab.postmarketos.org/postmarketOS/pmaports/-/settings/repository)

#### pmaports: update main branch
- [ ] `git checkout main`
- [ ] Add the new branch to
  [channels.cfg](https://wiki.postmarketos.org/wiki/Channels.cfg_reference):
  - [Example](https://gitlab.postmarketos.org/postmarketOS/pmaports/-/commit/c43571ceaf9b8155519bc9fb760bdeccd96e7e9c)
  - Check if you need to set `branch_aports=master` initially if the stable
    branch does not exist yet.
- [ ] `git push`

#### pmaports: update os-release / remove packages / aportgen
- [ ] `git checkout vYY.MM`
- [ ] Update `postmarketos-base`:
  - [ ] Set version info for `/usr/lib/os-release` in
    `main/postmarketos-base/rootfs-usr-lib-os-release`
    (`PRETTY_NAME="postmarketOS vYY.MM"`, `VERSION_ID="vYY.MM"`,
    `VERSION="vYY.MM"`)
  - `pmbootstrap pkgrel_bump postmarketos-base`
  - `pmbootstrap config mirrors.pmaports none`
  - `pmbootstrap config mirrors.systemd none`
  - `pmbootstrap checksum postmarketos-base`
  - `git commit -s` (`Remove packages that we don't have in stable`)
- [ ] Remove packages:
  - `cross/*-armhf` and other unsupported arches in cross dir (keep `gcc-x86` and `musl-dev-x86`, `systemd-boot-x86`)
  - `gcc4*` and `gcc6*` from main and cross dirs
  - `device/downstream`, `device/archived`
  - `extra-repos/systemd/postmarketos-repo-nightly`
- [ ] Run `pmbootstrap aportgen` for packages in cross:
  - `cd cross; PMB_APK_FORCE_MISSING_REPOSITORIES=1 pmbootstrap aportgen musl-* grub-efi-x86`
  - `git commit -s` (`cross: regenerate for vYY.MM`)
- [ ] `git push`

#### bpo: adjust config
- [ ] Add the branch to the
  [build.postmarketos.org](https://gitlab.postmarketos.org/postmarketOS/build.postmarketos.org)
  config in `bpo/config/const/__init__.py:branches` below `branches["main"]`,
  so it builds with lower priority than main until it's released. Set `ignore_errors` to `True`.
- [ ] Make a merge request, wait until CI passes, merge it (or if you can directly push to main that's also fine since it's a trivial change)
- [ ] Roll it out/ask somebody who can do that
- [ ] Restart bpo, it will start building `x86_64` packages

#### Bootstrap of binary packages
- [ ] Fix all failing `x86_64` packages (Remember: patches need to go through
      edge first, then get backported to the stable branch!)
  - Try to get build fixes merged to edge quickly, ask for reviews in
    #postmarketos-devel, and consider merging trivial fixes right after they
    pass CI.
  - Devices in testing and archived categories that don't build: consider
    trying to fix them, or just delete them from the branch
- [ ] Wait until all packages for `x86_64` (main repository, we don't need to
      wait for the systemd repository before continuing) are built and
      published
- [ ] Enable arm repositories in the BPO config
- [ ] Get all packages to build without errors

#### Wallpaper poll
- [ ] Team meeting: make a short list of 4 wallpapers from [the
  pool](https://gitlab.postmarketos.org/postmarketOS/artwork/-/tree/main/wallpapers/2024)
- [ ] Make a poll on the wallpapers on mastodon
  ([example](https://fosstodon.org/@postmarketOS/113624366198561582))
  - Make sure to thank the wallpaper authors (usually dikasp) for the amazing
    work on the wallpapers
  - Put the names of the wallpapers on top of the wallpapers for easier voting
    and as alt text
  - Create a comment with poll options

#### Adjust CI
- [ ] Make sure pmaports.git CI runs through on the new branch (run
  `pmbootstrap ci`). Examples of why it might fail:
  - One postmarketos-ui package has a package from alpine testing in their
    _pmb_recommends.
    - Remove the UI if it is not used much (can bring it back on demand) or
      fork the package to the new branch
    - Consider fixing it in edge, so we don't run into this with the next
      release
- [ ] Adjust
  [upstream-compat](https://gitlab.postmarketos.org/postmarketOS/continuous-testing/upstream-compat)
  to run on the new release and make sure it passes
  ([example](https://gitlab.postmarketos.org/postmarketOS/continuous-testing/upstream-compat/-/merge_requests/10))

#### Adjust release upgrade script
- [ ] Add the new release to `upgrade.sh` in [postmarketos-release-upgrade](https://gitlab.postmarketos.org/postmarketOS/postmarketos-release-upgrade/)
- [ ] Bump `SCRIPT_VERSION`, tag a new release
- [ ] Package it for edge (make MR), backport it to the new release, but NOT to
  the old release yet (otherwise users may upgrade by accident, without
  realizing that the new version is not out yet!)
- [ ] Adjust CI of postmarketos-release-upgrade to test the new release too
  (`git grep` for the previous release to see what needs to be adjusted)

#### Update the wallpaper
- [ ] Set the wallpaper that won in the poll in edge, backport this change to
  the stable release branch

### 2. Branch phase

#### Rebase on main
- [ ] `git checkout vYY.MM`
- [ ] `git rebase -i origin/main`
- [ ] Temporarily enable force-push for the `vYY.MM` branch
- [ ] `git push --force-with-lease`
- [ ] Disable force-push for the `vYY.MM` branch again

#### Update BPO config
- [ ] Update bpo's images config to build images for the new branch for all
  devices in community and main
- [ ] bpo: configure the new branch to be not WIP anymore
- [ ] Roll-out bpo changes

#### pmb release done?
- [ ] Ensure that a pmbootstrap release been made with the apk-tools min
  version change

#### aports stable branch set?
* [ ] Check if a stable branch exists in `aports` for the new release, and that
      it is being used in `channels.cfg` (might still be set to `master` if it
      did not exist during the Pre-Branch phase).

### 3. Test phase
- [ ] Create an issue in pmaports with a checklist of devices and UIs in main
  and community (see previous issue for reference)
  - Tag the testers of each device and UI
  - Ask to verify that the images work as expected
  - Release upgrade script: when coming from the previous release, grab it from
    main: `wget https://gitlab.postmarketos.org/postmarketOS/postmarketos-release-upgrade/-/raw/main/upgrade.sh`
- [ ] Announce the new phase in the testing chat - and ask them to do the
  testing within one week, as in the timeline.
- Prioritize merging fixes from maintainers (they do the heavy lifting in the
  testing and fixing phase, see timetable)
- Make sure to properly cherry pick fixes from MRs to edge, if they are
  intended for the upcoming release
- [ ] Add new version to the pmaports gitlab issue template (.gitlab dir)

### 4. Release phase
- [ ] Did a reasonable amount of devices get tested? (we may consider dropping
  devices that were not tested)
- [ ] Make sure all fixes are in
- [ ] Make sure new images are generated *with* the fixes (unless it's a fix
  for something that doesn't impact the experience much and is fine to get with
  the first update after installing)
- [ ] Announce the new phase in the testing chat, together with the planned
  date of blog post release (and testing)

#### Write blog post
- [ ] Write a blog post for the new release in `postmarketos.org.git`:
  - Look at the previous release blog post and try to make the new one
    consistent with it
  - Highlight major changes since the last release
    (see the release notes issue)
  - Mention new devices, and total list of devices
    - Count devices that have their own wiki page as separate device
    - E.g. OnePlus 6, 6T are two devices (two wiki pages), but variants of
      "Samsung Galaxy A3 (2015)" are one device (one wiki page)
    - Don't count/list devices for which we don't build images (e.g.
      qemu-amd64)
  - Adjust the homepage config to point to the new release in the downloads
    page
    - update `config/download.py`:
      - `latest_release`
      - update devices and categories. only list the ones where we actually build images.
  - Add some cool photos
  - Submit the blog post as MR to postmarketos.org.git.
  - Let the blog post MR close the current release notes issue.
  - Ask for reviews.

#### Release!
- [ ] Backport the new postmarketos-release-upgrade version that allows
  upgrading to the new release, to the previous release (don't do this before
  the release is tested and ready! During the testing phase, we can use
  postmarketos-release-upgrade from main directly: `wget
  https://gitlab.postmarketos.org/postmarketOS/postmarketos-release-upgrade/-/raw/main/upgrade.sh`)
- [ ] Add the branch to pkgs.postmarketos.org
- [ ] Merge the blog post
- [ ] Edit channels.cfg, change descriptions:
  - New release: "Latest release / Recommended for best stability"
  - Old release: "Old release (supported until YYYY-MM-DD)" (one month from date of the release)
- [ ] Create a milestone for the next release
- [ ] Create an issue for the next release notes and attach it to that milestone
- [ ] Update the [Releases](https://docs.postmarketos.org/pmaports/main/releases.html) page
  - Move the new release to the list of active releases, link to the blog post
  - Update the announcement and title for the release
  - Add a new upcoming release below
- [ ] Update [Template:Latest stable release](https://wiki.postmarketos.org/wiki/Template:Latest_stable_release) on the wiki with the new version
- [ ] Update "Default description template for issues" in pmaports (.gitlab dir)
  - In "On what postmarketOS version did you encounter the issue?", change:
    - previous release: add " (supported until YYYY-MM-DD)"
    - add the new release
- [ ] Put a reminder in recurring-admin-tasks to drop support for the old release
