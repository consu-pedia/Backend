#!/bin/bash

# step 1 get rid of multiple .. at end
# step 2 protect special exceptions with ..
# step 3 remove . at end
cat |\
  sed -e 's/\.\.*$/./' |\
  sed -e 's/ \(ca\)\.$/ \1../' |\
  sed -e 's/\.$//' |\
  cat


exit 0

