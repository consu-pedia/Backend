#!/bin/bash


# line 2: change empty records to __DELETED__ and remove "^ 0 => "
cat |\
  sed -e 's/^ *0 => \x27\x27,$/__DELETED__/;s/^ *0 => //g' |\
  cat

exit 0

