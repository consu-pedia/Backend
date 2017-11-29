#!/bin/bash

cd /home/frits/github/git/Backend/Backend/tables/ingredients/willys/preprocessing/outdir.2017-11-27T14:01 || exit 1

if [ ! -d ff ]; then
  echo "ERROR need ff as test output dir"
  exit 1
fi
export OUTDIR=ff
du $OUTDIR/

export CURINP_INGREDIENTS=../tmp.ingredients
if [ ! -f $CURINP_INGREDIENTS ]; then
  echo "ERROR CURINP_INGREDIENTS not set right, not found"
  exit 1
fi

cat out.150_I | time ../step.second_version_product_ingredients_table/step.second_version_product_ingredients_table.sh > blurp
rc=$?

exit 0


