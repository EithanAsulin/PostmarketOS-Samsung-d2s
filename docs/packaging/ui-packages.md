# UI Packages

UIs (otherwise referred to as desktops or 'DE's) are the primary graphical way
that users interact with their systems. On postmarketOS, these UIs are packaged
in `postmarketos-ui-*` packages under `main/` in pmaports. The UI packages do not
include the projects that make up a UI, as those are instead packaged in
Alpine Linux's aports. The purpose of a UI package in postmarketOS is to
combine the individual components of a UI, alongside postmarketOS-specific
configuration, to create a functional out-of-the-box experience for users.

## How to add a new UI

To add a new UI, its components must first be packaged separately and
upstreamed to Alpine Linux's aports. Once this is complete, a new package
called `postmarketos-ui-<UI Name>` can be created under the `main/` directory
in pmaports. If there is more than one UI that uses the same configuration,
it is also possible to create a `postmarketos-base-ui-<UI Name>` package and
have the individual UIs depend upon it.

After adding a UI, add it to:
https://wiki.postmarketos.org/wiki/Category:Interface

## Requirements for UI packages

- UIs are not required to support both OpenRC and systemd. While it is
  recommended to support both to allow user choice, it is up to the UI
  maintainers whether they support a service manager or not. Declaring which
  service managers are supported and which is the default is done via
  [APKBUILD options](ui-packages-apkbuild-options).
- UIs shall work out-of-the-box on first initialization, meaning that they
  should not require user intervention to start or require external
  configuration.
- UI packages shall attempt to comply with the upstream project's vision
  for the UI. This is excepted when changes are made to work better with a
  different device form-factor, to modify basic branding, or to comply with
  any other requirements.
- A UI shall be rejected if its inclusion would be a risk to community
  cohesion through the actions of the UIs upstream community, non-postmarketOS
  userbase, and/or other outstanding factors that make it obvious that a UI's
  inclusion would damage the project in some way.

## Recommendations for UI packages

- Only depend upon the minimal amount of packages needed to have a functional
  desktop as recommended by the upstream. For packages that are not core to
  the functionality of the desktop, these should be put into
  [`_pmb_recommends`](pmb-recommends) to allow the user to uninstall them if
  need-be.
- Create an `$pkgname-extras` subpackage to store the packages (usually apps)
  that are nice to have, but are not needed for a full experience of the
  desktop. Apps that could go here are multimedia apps, ebook readers, etc.
  Remember to put these packages in [`_pmb_recommends`](pmb-recommends) in the
  subpackage to allow the user to uninstall them.
- If a UI supports the ability to set a wallpaper, it is expected that the
  default wallpaper of postmarketOS is set by default. This is not a strict
  rule, as this is sometimes not possible due to technical constraints.

```{eval-rst}
.. toctree::
   :hidden:

   ui-packages/apkbuild-metadata
```
