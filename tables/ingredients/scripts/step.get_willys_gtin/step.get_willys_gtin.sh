#!/bin/bash

cat > $OUTDIR/tmp.step1a.mainstream

cat $OUTDIR/tmp.step1a.mainstream |\
  grep '"ean" *: *"' |\
  awk -F'"' '{OFS="\"";printf("%d", NR); printf(""); printf("%s",$4);for(w=5;w<=NF-1;w++){printf("\"%s",$(w));};printf("\n");}' |\
  cat > $OUTDIR/tmp1a.product_gtin_table.raw

cat $OUTDIR/tmp.step1a.mainstream
rm $OUTDIR/tmp.step1a.mainstream

exit 0

