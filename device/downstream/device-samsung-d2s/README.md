# Maintainer : Eithan Asulin [https://github.com/EithanAsulin]

# / -------- Terms And Conditions ---------- /
>					This Was Tested On
>					The N975F Exynos 9825
>					If Bricked I Am Not At Fault.
# / -------- Terms And Conditions ---------- /

> If You Are Interested In Helping With Development DM This Discord User : duck_ae


# Installation

see https://wiki.postmarketos.org/wiki/Installation/Using_pmbootstrap

when running `pmbootstrap init`, select:
Vendor: samsung
Device: d2s

then:
```
pmbootstrap build linux-samsung-d2s --force
pmbootstrap install
```

From This Point Follow This :
---> Reboot To Download Mode"
-------> Run > pmbootstrap flasher flash_kernel
---> Immediately Go Back To Download Mode
-------> Run > pmbootstrap flasher flash_rootfs


Status : Booting Detected By USB As Samsung d2s, Failing To Load Display Or SSH.

Device Codename : d2s

This Is Based On The S10+ (beyond2lte) downstream port.



# Working :

> BOOT

> USB (lsusb > Google Inc. Nexus 4 (fastboot))

>  ^^^ [Not Actually In Fastboot And Displays As samsung d2s In Dock] ^^^

> DISPLAY

> TWRP

> KERNEL

# Not Working :

> GUI

> /system_root Partition Detection (Fixed Via Odin)

> SSH

# Untested :

> Touch

> Wifi

> Bluetooths

> Modem/SIM

> Power Management

> Gestures

> Brightness Control

> Wayland Support
 
