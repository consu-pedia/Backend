#!/bin/bash

# N.B. new reserved keyword: __DELETED__

# this step must be done before step.remove_ingredienser_word.sh

# line 2: change coop empty records to __DELETED__ and remove "^ 0 => "
cat |\
  sed -e 's/^ *0 => \x27\x27,$/__DELETED__/;s/^ *0 => //g;s/^\x27//;s/\x27,$//;' |\
  cat

exit 0

