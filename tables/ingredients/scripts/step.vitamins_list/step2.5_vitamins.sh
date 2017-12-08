#!/bin/bash
# this one is to expand lists BEFORE cutting on the comma
# example:
# vitaminer (c, e, niacin, pantotensyra, b1, a, b6, b2, folsyra, k, d, biotin),
# => 


# HACK HACK don't know how to do this better, sorry ...
# echo 'vitaminer (c, e, niacin, pantotensyra, b1, a, b6, b2, folsyra, k, d, biotin),' |\


cat |\
  sed -e 's/vitaminer:* */vitaminer /' |\
  sed -e 's/vitaminer (\([^,)]*\),/__VITAMINER__ (__\1__), vitaminer (/g' |\
  sed -e 's/vitaminer (\([^,)]*\),/__VITAMINER__ (__\1__), vitaminer (/g' |\
  sed -e 's/vitaminer (\([^,)]*\),/__VITAMINER__ (__\1__), vitaminer (/g' |\
  sed -e 's/vitaminer (\([^,)]*\),/__VITAMINER__ (__\1__), vitaminer (/g' |\
  sed -e 's/vitaminer (\([^,)]*\),/__VITAMINER__ (__\1__), vitaminer (/g' |\
  sed -e 's/vitaminer (\([^,)]*\),/__VITAMINER__ (__\1__), vitaminer (/g' |\
  sed -e 's/vitaminer (\([^,)]*\),/__VITAMINER__ (__\1__), vitaminer (/g' |\
  sed -e 's/vitaminer (\([^,)]*\),/__VITAMINER__ (__\1__), vitaminer (/g' |\
  sed -e 's/vitaminer (\([^,)]*\),/__VITAMINER__ (__\1__), vitaminer (/g' |\
  sed -e 's/vitaminer (\([^,)]*\),/__VITAMINER__ (__\1__), vitaminer (/g' |\
  sed -e 's/vitaminer (\([^,)]*\),/__VITAMINER__ (__\1__), vitaminer (/g' |\
  sed -e 's/vitaminer (\([^)]*\),/__VITAMINER__ (__\1__), vitaminer (/g' |\
  sed -e 's/__ /__/g; s/vitaminer (\([^)]*\))/vitamin \1/;s/__VITAMINER__(__\([^_]*\)__)/vitamin \1/g;' |\
  sed -e 's/vitamin vitamin /__V2__/g;' |\
  sed -e 's/__V2__/vitamin /g;' |\
  cat

exit 0

