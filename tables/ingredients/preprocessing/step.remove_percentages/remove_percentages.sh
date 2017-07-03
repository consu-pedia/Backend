#!/bin/bash

# TODO save percentages


# line 2: change empty records to __DELETED__ and remove "^ 0 => "
# line 4: remove percentages complicated case "3, 7 %"
# line 4: remove percentages
# line 5: if original was  " (25%)" remove the " ( )"
# line 6: remove single quotes and trailing spaces (now 12198 entries left)
cat |\
  sed -e 's/^ *0 => \x27\x27,$/__DELETED__/;s/^ *0 => //g' |\
  sed -e 's/ *[0-9][0-9]* *, *[0-9][0-9]* *% */ /g' |\
  sed -e 's/ *[0-9][0-9]* *% */ /g' |\
  sed -e 's/ *( )//g' |\
  sed -e 's/^ *\x27//;s/ *//;s/ *\x27$//;s/^ *//;' |\
  cat

exit 0

