# Makes the Lomiri UI bigger
# Calculation : round(411ppi * 0.05236) = 21
# Reference: https://wiki.postmarketos.org/wiki/Lomiri
export GRID_UNIT_PX=21

# Lomiri sleeping is broken on mainline
# it expects an Android kernel
printf off > /sys/power/autosleep
