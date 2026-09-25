<!-- Use this template to notify community kernel maintainers that their
     kernels are out-of-date and start the timer for moving them to testing.

     Please title the issue:
     Current community kernels not meeting version requirement (yyyy-mm-dd)
-->

Hi, as per our
[device categorization requirements for the community category](https://docs.postmarketos.org/pmaports/main/device-categorization.html#community),
devices in the community category may not use a kernel version older than 6
months.

As of today (yyyy-mm-dd), the following kernels do not meet this requirement:

* kernel-pkgname: kernel-pkgver, version-release-date (maintainers: @ ...)

This issue is an attempt to notify you (the maintainers) of the situation so
that you can update the packages. As per the rules, you have two weeks to
update the packages or reply with a request for more time, up to one month
of time from the moment this issue is opened. If that time passes and the
devices still no longer meet the requirements, they will be moved to testing.

/label ~"device-category::community"
/label ~kernel
/label ~"type::policy"
