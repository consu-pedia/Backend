#!/bin/bash
PATH_TO_LEVENSHTEIN="../../../toolkit/levenshtein"
LEVENSHTEIN=$PATH_TO_LEVENSHTEIN/levenshtein
PRINTMINDIST=$PATH_TO_LEVENSHTEIN/printmindist
PAIRSCUTOFF=4

cat > $OUTDIR/tmp6.mainstream

if [ ! -x $LEVENSHTEIN ]; then
  echo "$STEPNAME cannot find path to $LEVENSHTEIN, did you remember to compile it?"
  exit 1
fi

eecho()
{
  ( echo $* 1>&2 ) > /dev/null
}

cp -p tmp.ingredients $OUTDIR/tmp7.ingredients.in
cp -p tmp.ingredients wordlist # I know, i know. TODO.

time $LEVENSHTEIN $OUTDIR/tmp7.ingredients.in > $OUTDIR/tmp7.levenshtein_matrix


# next dump the pairs list
time  $PRINTMINDIST $PAIRSCUTOFF wordlist < $OUTDIR/tmp7.levenshtein_matrix > $OUTDIR/tmp7.pairs.upto$PAIRSCUTOFF

for dist in $( seq 1 $PAIRSCUTOFF ); do
  #OBSOLETE cat $OUTDIR/tmp7.pairs.upto$PAIRSCUTOFF | grep '^'"$dist"'	' > $OUTDIR/tmp7.pairs.$dist
  # unfortunately, $PRINTMINDIST now outputs SQL.
  # example:
  # INSERT INTO compare_ingredients VALUES ( 945 , 1181 , "cayennepeppar" , 3755 , "kajennpeppar" , 3 , 4 , 0 );
  cat $OUTDIR/tmp7.pairs.upto$PAIRSCUTOFF | awk -v"dist=$dist" '{if((NF>5)&&($(NF-5)==dist)){print}}' > $OUTDIR/tmp7.pairs.$dist
  eecho $( wc -l $OUTDIR/tmp7.pairs.$dist )
done


# return
cat $OUTDIR/tmp6.mainstream
rm $OUTDIR/tmp6.mainstream

exit 0

