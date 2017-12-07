#!/bin/bash

# this list is hardcoded for now
# SHOPS="coop willys"
SHOPS="oldcoop"

WORKFILES="gtin_table.raw gtin_table.sql raw_ingredientslists productnames.txt"

totrecords=0
rm -rf gluedir
mkdir gluedir
touch gluedir/manifest
mkdir gluedir/shops

# first sanity check
sanity=1
for shop in $SHOPS; do
  lastshopdir=$( ls -td ../$shop/outdir.* |head -n 1 )
  if [ ! -d "$lastshopdir" ]; then sanity=0; fi
done # next shop

if [ $sanity -eq 0 ]; then
  echo "glue_shops_together.sh: ERROR: one or more shops is MISSING, cannot continue."
fi

touch gluedir/shopcolumn.txt
for shop in $SHOPS; do
  lastshopdir=$( ls -td ../$shop/outdir.* |head -n 1 )
  # assume lastshopdir hasn't disappeared in the meantime

  exportdir=$lastshopdir/export

  missing=""
  sanity=1
  for workf in $WORKFILES; do
    if [ ! -s $exportdir/export.$shop.$workf ]; then
      echo "ERROR file $exportdir/export.$shop.$workf missing or empty"
      missing="$missing"" ""$exportdir/export.$shop.$workf"
      sanity=0
      continue
    fi

    cp -p $exportdir/export.$shop.$workf gluedir/shops/$shop.$workf
    wc -l gluedir/shops/$shop.$workf >> gluedir/manifest
    cat gluedir/shops/$shop.$workf >> gluedir/$workf
  done


  if [ ! "$missing" = "" ]; then
    echo "shop $shop is missing the following files:"
    echo "$missing"
    exit 1
  fi

  # make column filled with just the shop name
  shopnrec=$( wc -l gluedir/shops/$shop.raw_ingredientslists |awk '{print $1}' )
  # TODO PRIMITIVE AND SLOW
  echo "making $shopnrec shopcolumn.txt records"
  mkdir gluedir/tmp
  echo "$shop" > gluedir/tmp/shop.01
  cat gluedir/tmp/shop.01 gluedir/tmp/shop.01 > gluedir/tmp/shop.02
  cat gluedir/tmp/shop.02 gluedir/tmp/shop.02 > gluedir/tmp/shop.04
  cat gluedir/tmp/shop.04 gluedir/tmp/shop.04 > gluedir/tmp/shop.08
  cat gluedir/tmp/shop.08 gluedir/tmp/shop.08 > gluedir/tmp/shop.10
  cat gluedir/tmp/shop.10 gluedir/tmp/shop.10 > gluedir/tmp/shop.20
  cat gluedir/tmp/shop.20 gluedir/tmp/shop.20 > gluedir/tmp/shop.40
  cat gluedir/tmp/shop.40 gluedir/tmp/shop.40 > gluedir/tmp/shop.80
  cat gluedir/tmp/shop.80 gluedir/tmp/shop.80 > gluedir/tmp/shop.100
  pr1=0
  for r1 in $( seq 256 256 $shopnrec ); do
    cat gluedir/tmp/shop.100 >> gluedir/shopcolumn.txt
#DBG#     wc -l gluedir/shopcolumn.txt
#DBG#     echo "r1=$r1"
    pr1=$r1
  done
  rest=$(( $shopnrec % 256 ))
  cat gluedir/tmp/shop.100 | head -n $rest >> gluedir/shopcolumn.txt
#DBG#   wc -l gluedir/shopcolumn.txt
rm -rf gluedir/tmp

done # next shop

exit 0


