#!/bin/bash


sed -n '/START_KEYS/,/END_KEYS/p' ~/.config/qtile/config.py | \
         grep  -e 'Key'  \
         -e 'KEYS_GROUP' | \
          sed -e 's/^[ \t]*//' \
              -e 's/#KEYS_GROUP/\n/' |  \
              grep  -v "^#" |  \
              grep   -v "^desc" | \
              grep   -v "^KeyChord" | \
              sed -e 's/],/  /' \
                  -e 's/"/ /g' \
                  -e 's/,/ /g' \
                  -e 's/(\[/ /' \
                  -e 's/*[ \t]*//' \
                  -e 's/\[//g' \
                  -e 's/#//g' \
                  -e 's/Key//'   | \
                   yad --text-info  --back=#1e1f28 --fore=#bd92f8 --geometry=1200x800 
