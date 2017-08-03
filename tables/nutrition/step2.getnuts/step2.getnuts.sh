#!/bin/bash

if [ "$OUTDIR" = "" ]; then OUTDIR="."; fi

cat > $OUTDIR/tmp.placeholder

cat $OUTDIR/tmp.placeholder |\
  tr '\037' '\n' |\
  sed -e 's/^ *[0-9][0-9]* => //' |\
  sed -e 's/ [0-9][0-9,.]*|PIM_MULTIVALUE_SEPARATOR|[0-9][0-9,.]*\([^0-9]\)/ QUANTITY_RANGE\1/g' |\
  sed -e 's/ [0-9][0-9,.]*\([^0-9]\)/ QUANTITY\1/g' |\
  sort |\
  uniq > $OUTDIR/tmp.nuts
  


cat $OUTDIR/tmp.placeholder
