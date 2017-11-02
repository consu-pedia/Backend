#!/bin/bash
# this one is to expand lists BEFORE cutting on the comma
# example:
# vitaminer (c, e, niacin, pantotensyra, b1, a, b6, b2, folsyra, k, d, biotin),
# => 


# HACK HACK don't know how to do this better, sorry ...
# echo 'vitaminer (c, e, niacin, pantotensyra, b1, a, b6, b2, folsyra, k, d, biotin),' |\

# l. 3: transform vitaminer tiamin, niacin. to vitaminer (tiamin, niacin). instead of parens use U+001C and U+001D to protect
# l. 4: in case of tiamin (b1) change it to tiamin \x1cb1\x1d for now
# the tr command at the end changes them back (octal \034 = 0x1c = U+001C)
# l. 4-5, 6-7, 8-9 protect prens around each vitamin name
# l. 9 replace beginning and end parens ONLY if after vitaminer came a (

cat |\
  sed -e 's/vitaminer:* */vitaminer /' |\
  sed -e 's/vitaminer \([^(][^.]*\)./vitaminer \x1c\1\x1d./' |\
  sed -e 's/vitaminer \([^(.]*\)(/vitaminer \1\x1c/' |\
  sed -e 's/vitaminer \([^).]*\))/vitaminer \1\x1d/' |\
  sed -e 's/vitaminer \([^(.]*\)(/vitaminer \1\x1c/' |\
  sed -e 's/vitaminer \([^).]*\))/vitaminer \1\x1d/' |\
  sed -e 's/vitaminer \([^(.]*\)(/vitaminer \1\x1c/' |\
  sed -e 's/vitaminer \([^).]*\))/vitaminer \1\x1d/' |\
  sed -e 's/vitaminer \x1c\([^.]*\)\x1d./vitaminer (\1)./' |\
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
  sed -e 's/__ /__/g; s/vitaminer ( *\([^)]*\))/vitamin \1/;s/__VITAMINER__(__\([^_]*\)__)/vitamin \1/g;' |\
  tr '\034\035' '()' |\
  cat

# tr '\034\035' '()' |cat;exit 0

exit 0

