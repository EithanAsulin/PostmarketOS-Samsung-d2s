#!/bin/sh

xfconf-query -c xsettings -p /Gdk/WindowScalingFactor --create -t int -s 2
xfconf-query -c xsettings -p /Xft/DPI --create -t int -s 144
xfconf-query -c xfwm4 -p /general/theme --create -t string -s Default-xhdpi
xfconf-query -c xfwm4 -p /general/use_compositing --create -t bool -s false

# top panel
xfconf-query -c xfce4-panel -p /panels/panel-1/size --create -t int -s 56
xfconf-query -c xfce4-panel -p /panels/panel-1/length --create -t int -s 100
xfconf-query -c xfce4-panel -p /panels/panel-1/length-adjust --create -t bool -s true
xfconf-query -c xfce4-panel -p /panels/panel-1/position --reset
