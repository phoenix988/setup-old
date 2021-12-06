#!/usr/bin/env bash 
# 
# Using bash in the shebang rather than /bin/sh, which should
# be avoided as non-POSIX shell users (fish) may experience errors.

lxsession &

#Compositor
picom -b --config  $HOME/.config/qtile/picom-jona.conf
#nitrogen --restore &

#Set wallpaper
~/.fehbg &
#feh --randomize --bg-fill /home/karl/Pictures/Anime/* &

#urxvtd -q -o -f &
#/usr/bin/emacs --daemon &
nm-applet &
#mailspring -b &
#xrandr --output DP-4 --mode 2560x1440 --rate 143.91
#pamac-tray &
ckb-next -b &
xfce4-screensaver &
volumeicon &
conky -c /home/karl/.config/conky/main &
flameshot &
steam &
discord &
whatsapp-nativefier &   
#whatsapp-for-linux &
whatsdesk &   
lutris &


#sudo ~/.mount.sh &



#sleep 5

#killall electron

