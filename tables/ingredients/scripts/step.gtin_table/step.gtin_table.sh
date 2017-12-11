#!/bin/bash

# split GTIN table handling into 2 pieces
# this involves a bit of gluing, since we take into account a "beginning
# record number" that can come from another dataset.

eecho()
{
  ( echo $* 1>&2 ) > /dev/null
}


cat > $OUTDIR/tmp.gtin_table.mainstream

if [ ! -f $OUTDIR/tmp.gtin.list ]; then
  msg="step.gtin_table.sh ERROR: this step can only be run after tmp.gtin.list has been created (1 record per line, 2 fields GTIN and shop, field separator 0x1f)" > $OUTDIR/tmp.gtin_table.mainstream
  eecho "$msg"
  echo "$msg" > $OUTDIR/tmp.gtin_table.mainstream
  exit 1
fi


if [ ! -f ../index.gtin_table ]; then
  msg="step.gtin_table.sh ERROR: file ../index.gtin_table not found; initialize it with index value 0."
  eecho "$msg"
  echo "$msg" > $OUTDIR/tmp.gtin_table.mainstream
  exit 1
fi

# yes, this is primitive. so what?
startidx=$( cat ../index.gtin_table )

cat $OUTDIR/tmp.gtin.list |\
  awk -v"i=$startidx" '{printf("%d%s%s\n", i + NR, "", $0);}' |\
  cat > $OUTDIR/gtin_table.raw

# convert gtin table to SQL
cat $OUTDIR/gtin_table.raw |\
  awk -F'' '{ printf("INSERT INTO gtintable VALUES ( %d, \"%s\", \"%s\" );\n", $1, $3, $2);}' |\
  cat > $OUTDIR/gtin_table.sql

# save copy of index.gtin_table in the $OUTDIR
echo "$startidx" > $OUTDIR/index.gtin_table  # N.B. "working copy" in $OUTDIR

# update index.gtin_table so that the next dataset can use it
nl=$( cat $OUTDIR/gtin_table.raw | wc -l )
endidx=$(( $startidx + $nl ))
echo "$endidx" > ../index.gtin_table  # N.B. *NOT* in $OUTDIR but 2 above
eecho "step.gtin_table.sh: INFO: updated index.gtin_table from $startidx to $endidx"


cat $OUTDIR/tmp.gtin_table.mainstream
rm $OUTDIR/tmp.gtin_table.mainstream

exit 0

