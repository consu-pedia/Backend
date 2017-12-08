#!/bin/bash

cat > $OUTDIR/tmp.step1b.mainstream

# WARNING Willys-specific (and a bit breakable)
cat $OUTDIR/tmp.step1b.mainstream |\
  grep '^   "name" *: *"' |\
  awk -F'"' '{OFS="\"";printf("%d", NR); printf(""); printf("%s",$4);for(w=5;w<=NF-1;w++){printf("\"%s",$(w));};printf("\n");}' |\
  cat > $OUTDIR/tmp1b.product_productname_table.raw

cat $OUTDIR/tmp.step1b.mainstream
rm $OUTDIR/tmp.step1b.mainstream

exit 0

