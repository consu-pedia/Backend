#!/bin/bash

# TODO save percentages


# line 3: remove percentages complicated case "3, 7 %"
# line 4: remove percentages case "3.7 %"
# line 5: remove percentages
# line 6: if original was  " (25%)" remove the " ( )"
# line 7: remove single quotes and trailing spaces (now 12198 entries left)
cat |\
  sed -e 's/QUANT_[^_]*_QUANT %//g' |\
  sed -e 's/ *[0-9][0-9]* *, *[0-9][0-9]* *% */ /g' |\
  sed -e 's/ *[0-9][0-9]* *\. *[0-9][0-9]* *% */ /g' |\
  sed -e 's/ *[0-9][0-9]* *% */ /g' |\
  sed -e 's/ *( )//g' |\
  sed -e 's/^ *\x27//;s/ *//;s/ *\x27$//;s/^ *//;' |\
  cat

exit 0

