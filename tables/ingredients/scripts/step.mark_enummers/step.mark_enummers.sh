#!/bin/bash

# N.B. the marker bytes are U+001F

# line 2 mark 3-digit E-numbers
# line 3 mark 4-digit E-numbers 1100..1599
# line 4 mark E160 a-f carotene, E161 a-j xanthin colours, E450-2 i .. iii phosphates, E471 mono/diglycerides, E472 a-g esters
# line 5 remove spaces in e-number name
cat |\
  sed -e 's?\(^\|[^a-z]\)e *\([1-9][0-9][0-9]\)\($\|[^0-9a-z]\)? ENUMMER_\2_ENUMMER ?g;' |\
  sed -e 's?\(^\|[^a-z]\)e *\([1-9][1-5][0-9][0-9]\)\($\|[^0-9a-z]\)? ENUMMER_\2_ENUMMER ?g;' |\
  sed -e 's?\(^\|[^a-z]\)e *\(160 *[a-fA-F]\|161 *[a-jA-J]\|45[012] *i*\|471 *[a-gA-G]\|472 *[a-gA-G]\)? ENUMMER_\2_ENUMMER ?g;' |\
  sed -e 's?ENUMMER_\([^ _]*\)  *\([^_]*\)_?ENUMMER_\1\2_?g;' |\
  cat
