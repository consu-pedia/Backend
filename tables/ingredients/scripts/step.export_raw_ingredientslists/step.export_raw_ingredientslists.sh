#!/bin/bash

shopname=$( basename $( pwd ) )

mkdir -p $OUTDIR/export

cat > $OUTDIR/export/export.$shopname.raw_ingredientslists

wc -l $OUTDIR/export/export.$shopname.raw_ingredientslists

cp -p $OUTDIR/gtin_table.sql $OUTDIR/export/export.$shopname.gtin_table.sql

exit 0

