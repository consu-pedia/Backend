#!/bin/bash
# N.B. in order to parse the numeric information, I had to do the following
# preparation:
# manually make a SQL table temporarynuts with field textincludingunits
# has the numeric info replaced by one of 2 placeholders 
# __QUANTITY__ (1 value) or
# __QUANTITY_RANGE__ (2 values).
# if these placeholders aren't there then there is no numeric information.
# in that table, I also replaced the units, creating a field I called template.
# so we have:
# output from step 4 (U+001F replaced by comma for readability)
137,1,    0 => 'Energi 369 kJ',
# corresponding rough table value as output tmp.nuts.sql from step 2:
# before editing:
INSERT INTO temporarynuts SET id=17, textincludingunits="Energi QUANTITY kJ", template="Energi QUANTITY kJ", unittext="kJ   ";
# after editing to temporarynuts.sql:
INSERT INTO temporarynuts SET id=17, textincludingunits="Energi QUANTITY kJ", template="Energi QUANTITY kJ", unittext="kJ";

# for this script step # 5 to work, this table temporarynuts has to manually
# be converted to a second table nutritionscantemplates
# where I modified the templates to a scanf formatting string.
# Because the units are also filtered out, this reduces the 121 records table
# temporarynuts to 84 in nutritionscantemplates.

# to make things a bit easier (hah!) I then used units.sql and nutritionscantemplates.sql and temporarynuts.sql to make temporarynuts2.sql.


if [ "$OUTDIR" = "" ]; then OUTDIR="."; fi

cat |\
  cat

exit 0

