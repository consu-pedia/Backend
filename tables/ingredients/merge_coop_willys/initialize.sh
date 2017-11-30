#!/bin/bash
# run this BEFORE process_ingredients.sh
# 
# This is a bit more complicated than it should be.
# I want to take the latest data (output directory) from both Willys and Coop;
# glue them together at/before step 100;
# create a tmp.ingredients from the beginning

whereami=$( pwd )
HERE=/home/frits/github/git/Backend/Backend/tables/ingredients/merge_coop_willys

if [ ! "$whereami" = "$HERE" ]; then
  echo "$0: ERROR: this step is sensitive to from which directory you execute it, please edit."
  exit 1
fi

lastcoopdir=$( ls -td ../preprocessing/outdir.* |head -n 1 )
echo "DBG lastcoopdir=$lastcoopdir"

lastwillysdir=$( ls -td ../willys/preprocessing/outdir.* |head -n 1 )
echo "DBG lastwillysdir=$lastwillysdir"

echo "Merging COOP and Willys out.100 to new inp ..."
rm -i inp inp.manifest

nc=$( cat $lastcoopdir/out.100 | wc -l )
cp $lastcoopdir/out.100 inp
echo "$nc records for COOP" | tee -a inp.manifest

nw=$( cat $lastwillysdir/out.100 | wc -l )
cat $lastwillysdir/out.100 >> inp
echo "$nw records for Willys" | tee -a inp.manifest
ntot=$( cat inp | wc -l )
echo "$ntot records total" | tee -a inp.manifest

exit 0

