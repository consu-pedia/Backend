#!/bin/bash

# N.B. the marker bytes are U+001F

# line 2 marks 1 1/2 msk etc.
# line 3 marks 1/4 msk etc.
# line 4 marks ½ gul lök etc.
# line 5 marks 1 ½ morot etc.
# line 6 marks 28 000 etc.
# line 7 marks rest of the numbers
# line 8 parses formal (SI) units directly after a number
# line 9 parses informal units
# line 10 parses formal (SI) units after a number and a space
# line 11 parses combination units such as mg/kg
# line 12 TODO parses "56 mg/100 ml", "8 g / 100 g" etc.
# line 13: if there are no units, put a space back
cat |\
  sed -e 's?\(^\|[^a-z]\)\([1-9][0-9]*\)  *\([1-9]/[1-9]\) ?QUANT_\2_\3_QUANT?g;' |\
  sed -e 's?\(^\|[^a-z]\)\([1-9]/[1-9]\) ?QUANT_\2_QUANT?g;' |\
  sed -e 's?\(^\|[^a-z0-9]\)\(¼\|½\|¾\)? QUANT_\2_QUANT?g;' |\
  sed -e 's?\(^\|[^a-z]\)\([1-9][0-9]*\) *\(¼\|½\|¾\)? QUANT_\2\3_QUANT?g;' |\
  sed -e 's?\(^\|[^a-z0-9]\)\([0-9][0-9]*\) \([0-9][0-9]*\)\([^0-9]\|$\)? QUANT_\2\3_QUANT\4?g;' |\
  sed -e 's?\(^\|[^a-z0-9]\)\([0-9][0-9]*\) *, *\([0-9][0-9]*\)\([^0-9]\|$\)? QUANT_\2,\3_QUANT\4?g;' |\
  sed -e 's?\(^\|[^a-z]\)\([1-9][0-9]*\) ? QUANT_\2_QUANT?g;' |\
  sed -e 's?\(^\|[^a-z]\)\([1-9][0-9]*\) *\(g\|mg\|kg\|ml\|dl\)\( \|[^0-9a-z]\)? QUANT_\2_QUANT UNIT_\3_UNIT\4?g;' |\
  sed -e 's/QUANT *\(msk\|tsk\|skvätt\|stor klick\|klyfta\|st\) /QUANT UNIT_\1_UNIT /g;' |\
  sed -e 's/QUANT *\(ml\|dl\|mg\|g\|kg\|liter\)\( \|[^0-9a-z]\)/QUANT UNIT_\1_UNIT \2/g;' |\
   sed -e 's?UNIT /\(kg\|ml\|dl\)?UNIT UNITFRAC_\1_UNITFRAC ?g' |\
  sed -e 's/QUANT\([^ ]\)/QUANT \1/g' |\
  cat

#   sed -e 's?UNIT/ *[0-9]* *\(kg\|ml\|dl\)?UNIT UNITFRAC_\1_UNITFRAC ?g' |\

exit 0

