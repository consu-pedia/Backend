#!/bin/bash
SHOP="willys"

cat > $OUTDIR/tmp.step1a.mainstream

cat $OUTDIR/tmp.step1a.mainstream |\
  grep '"ean" *: *"' |\
#TOO COMPLICATED  awk -F'"' -v"shop=$SHOP" '{OFS="\"";printf("%d", NR); printf(""); printf("%s",$4);for(w=5;w<=NF-1;w++){printf("\"%s",$(w));};printf("\"%s\n", shop);}' |\
  awk -F'"' -v"shop=$SHOP" '{printf("%d%s%s\n", NR, $4, shop);}' |\
  cat > $OUTDIR/gtin_table.raw

# convert gtin table to SQL
cat $OUTDIR/gtin_table.raw |\
  awk -F'' '{ printf("INSERT INTO gtintable VALUES ( %d, \"%s\", \"%s\" );\n", $1, $3, $2);}' |\
  cat > $OUTDIR/gtin_table.sql

cat $OUTDIR/tmp.step1a.mainstream
rm $OUTDIR/tmp.step1a.mainstream

exit 0

