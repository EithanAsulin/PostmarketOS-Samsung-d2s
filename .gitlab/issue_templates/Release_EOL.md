<!--
    This template is for marking a postmarketOS stable release as EOL.

    Name this issue "vYY.MM EOL".
-->

When the release has reached its EOL date:

- [ ] `postmarketos-base-ui`: let it depend on
  `postmarketos-release-upgrade-notification` and bump pkgrel
  - [ ] ensure it builds locally with pmbootstrap
  - [ ] push it to the branch
  - [ ] make sure bpo built and released the updated packages
- [ ] drop the old release from
  [monitoring](https://gitlab.postmarketos.org/postmarketOS/monitoring)
- [ ] drop the "oldold -> old" release check from
  [postmarketos-release-upgrade](https://gitlab.postmarketos.org/postmarketOS/postmarketos-release-upgrade/)
  CI
- [ ] bpo: configure images so they don't get built for the old release anymore
- [ ] bpo: configure branches so we don't try to build packages for old
  branches anymore
  - e.g. on startup all branches are checked for new packages, we should keep
    the amount of branches that get checked minimal
- [ ] pmaports.git channels.cfg: change description:
  - "Old release (unsupported)"
- [ ] Update the [Releases](https://docs.postmarketos.org/pmaports/main/releases.html) page
  - Move the release from active to old
- [ ] Consider removing images for the previous releases to save disk space
  (people can build their own images with pmbootstrap if needed)
