#!/bin/bash

cat > $OUTDIR/tmp.productname.mainstream

# For Willys, use the altText of the image URL
# it occurs 2x: once in image: {} and once in thumbnail: {}
# the text for those two was identical in the set I had, except for a terminating comma.

# "altText" : "Ceylon Te 454g Kooh-i-noor"

cat $OUTDIR/tmp.productname.mainstream |\
  grep 'altText' |\
  sed -e 's/,$//' |\
  uniq |\
  cut -d '"' -f4 |\
  cat > $OUTDIR/tmp1.productnames

cat $OUTDIR/tmp.productname.mainstream
rm $OUTDIR/tmp.productname.mainstream

exit 0

