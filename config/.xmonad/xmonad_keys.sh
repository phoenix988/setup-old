#!/usr/bin/env bash
set -euo pipefail


sed -n '/START_KEYS/,/END_KEYS/p' ~/.xmonad/xmonad.hs | \
    grep -e ', ("' \
    -e '\[ (' \
    -e 'KB_GROUP' | \
    grep -v '\-\- , ("' | \
    sed -e 's/^[ \t]*//' \
    -e 's/, (/(/' \
    -e 's/\[ (/(/' \
    -e 's/-- KB_GROUP /\n/' \
    -e 's/", /"\t: /' | \
    yad --text-info --back=#1e1f28 --fore=#bd92f8 --geometry=1200x800
