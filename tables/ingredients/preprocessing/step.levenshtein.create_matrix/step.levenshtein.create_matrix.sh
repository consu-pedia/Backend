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

cp -p tmp.ingredients $OUTDIR/tmp7.ingredients.in
cp -p tmp.ingredients wordlist # I know, i know. TODO.

time $LEVENSHTEIN $OUTDIR/tmp7.ingredients.in > $OUTDIR/tmp7.levenshtein_matrix


# next dump the pairs list
time  $PRINTMINDIST $PAIRSCUTOFF wordlist < $OUTDIR/tmp7.levenshtein_matrix > $OUTDIR/tmp7.pairs.upto$PAIRSCUTOFF

for dist in $( seq 1 $PAIRSCUTOFF ); do
  cat $OUTDIR/tmp7.pairs.upto$PAIRSCUTOFF | grep '^'"$dist"'	' > $OUTDIR/tmp7.pairs.$dist
  wc -l $OUTDIR/tmp7.pairs.$dist
done


# return
cat $OUTDIR/tmp6.mainstream
rm $OUTDIR/tmp6.mainstream

exit 0

