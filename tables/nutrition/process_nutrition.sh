#!/bin/bash
LINKSDIR="links.d"

if [ ! -d $LINKSDIR ]; then
  echo "ERROR: this script should be run in the directory with filtering links $LINKSDIR"
  exit 1
fi

if [ ! -f inp ]; then
  echo "ERROR expect file inp with lists of nutrition"
  exit 1
fi

now=$( date "+%Y-%m-%dT%H:%M" )

OUTDIR="outdir.$now"
mkdir -p $OUTDIR
if [ ! -d $OUTDIR ]; then echo "oops no $OUTDIR"; exit 1; fi

steps=$( ls $LINKSDIR/* )
if [ "$steps" = "" ]; then
  echo "INTERNAL ERROR scripts links directory $LINKSDIR is EMPTY, remember to symlink your filters into it, sorted by sequence"
  exit 1
fi

# sort numerically
steps=$( echo "$steps" | sort -n -t/ -k2 )

echo "run $now going to use the following steps:"
ls -l $steps

CURINP="./inp"
CURINP_NUTRITION="tmp.nutrition"

for s in $steps; do
  STEPNAME=$( basename "$s" |cut -d/ -f2 )
  CUROUT="$OUTDIR/out.$STEPNAME"
  CUROUT_NUTRITION="$OUTDIR/nutrition.$STEPNAME"
  export CURINP CURINP_NUTRITION CUROUT CUROUT_NUTRITION OUTDIR STEPNAME

  realscript=$( ls -l $s |awk '{print $9" "$10" "$11}' )
  echo "now running $realscript to transform $CURINP to $CUROUT."
  # execute!

  # special flags:
  # _I = interactive, so DONT redirect stdin/stdout
  flag_interactive=$( echo "$STEPNAME" |grep -c '_I' )

  if [ $flag_interactive -eq 1 ]; then
    echo "the next one, $s, is interactive"
    $s
  else
    $s < $CURINP > $CUROUT
  fi

  wc $CUROUT
  CURINP="$CUROUT"

  if [ -s "$CUROUT_NUTRITION" ]; then
    wc tmp.nutrition $CUROUT_NUTRITION
    cp $CUROUT_NUTRITION tmp.nutrition
    CURINP_NUTRITION="$CUROUT_NUTRITION"
    # otherwise stays
  fi
done

exit 0

