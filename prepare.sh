#!/bin/bash

echo "Maintainer : Duck Inc. (Eithan Asulin) [https://github.com/EithanAsulin]"
echo ""

# This Is Based On The Official S10 + (Beyond2lte) Downstream Files.
echo "Tested With pmbootstrap Version 3.8.0"

echo ""

echo "Copying Device Samsung d2s To Pmaports" 

echo ""

cp -r device-samsung-d2s ~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/


echo "Copying Linux Samsung d2s To Pmaports" 

cp -r linux-samsung-d2s ~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/
echo ""

echo "Running pmbootstrap init"
echo "Vendor : Samsung"
echo "Device : d2s"
echo "Y, And Then Just Hold Enter"

pmbootstrap zap
pmbootstrap zap
pmbootstrap init


echo "Starting Build!"
pmbootstrap checksum linux-samsung-d2s
pmbootstrap build linux-samsung-d2s --force
pmbootstrap install

echo "From This Point Follow This :"
echo "---> Reboot To Download Mode"
echo "-------> Run > pmbootstrap flasher flash_kernel"
echo "---> Immediately Go Back To Download Mode"
echo "-------> Run > pmbootstrap flasher flash_rootfs"
