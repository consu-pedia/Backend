#!/bin/bash

# this script has 2 outputs:
# the normal stream, and a list of ingredients tmp.ingredients

cat |\
  tee tmp.mainstream |\
  tr ',' '\n' |\
  sed -e 's/^  *//' |\
  sort | uniq > tmp.ingredients

cat tmp.mainstream
rm tmp.mainstream

exit 0

