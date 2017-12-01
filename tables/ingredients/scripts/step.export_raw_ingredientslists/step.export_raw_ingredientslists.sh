#!/bin/bash

shopname=$( basename $( pwd ) )

mkdir -p $OUTDIR/export

cat > $OUTDIR/export/export.$shopname.raw_ingredientslists

wc -l $OUTDIR/export/export.$shopname.raw_ingredientslists

cp -p $OUTDIR/gtin_table.sql $OUTDIR/export/export.$shopname.gtin_table.sql

if [ -s $OUTDIR/tmp1.productnames ]; then
  cp -p $OUTDIR/tmp1.productnames $OUTDIR/export/export.$shopname.productnames.txt
# TODO else, make a dummy file so the rows stay aligned when I glue the various shops' products records
fi

exit 0

