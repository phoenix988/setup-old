#!/bin/bash


 sed -n '/Keyboard shortcuts/,/End Keyboard shortcut/p' ~/.config/kitty/kitty.conf | \
       grep -v ^# | \
       grep -v clear | \
       sed  '/^$/d' | \
       sed -e 's/map/map\t/' \
           -e 's/map/\n/' \
           -e 's/^*//g' \
           -e 's/^[ \t]*//' | \
           sed -e 's/tab::/\t/g'  | \
           yad --text-info  --back=#1e1f28 --fore=#bd92f8 --geometry=1200x800
 


