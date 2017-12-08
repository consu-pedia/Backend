#!/bin/bash
# NOT A FILTER!
# pass-thru for the ingredientslist stream
# this edits the ingredients table

if [ "$OUTDIR" = "" ] || [ "$CURINP_INGREDIENTS" = "" ] || [ "$CUROUT_INGREDIENTS" = "" ]; then
  echo "ERROR UNDEFINED OUTDIR=$OUTDIR CURINP_INGREDIENTS=$CURINP_INGREDIENTS /CUROUT_INGREDIENTS =$CUROUT_INGREDIENTS"
  exit 1
fi

# line 2: remove beginning and ending spaces
cat $CURINP_INGREDIENTS |\
  sed -e 's/^  *//;s/  *$//' |\
  cat > $OUTDIR/tmp4.01.ingredients

cat $OUTDIR/tmp4.01.ingredients | sort | uniq > $CUROUT_INGREDIENTS


# pass-thru on main data stream
cat

exit 0

