#!/bin/bash
# N.B. this script leaves the main dataset and the ingredients list alone
# it only works on the Levenshtein pair lists (tmp7.pairs.x.sql)
# to make them a bit smaller.

cat > $OUTDIR/tmp8.mainstream

# 3 tricks:
######################################################################
# trick 1: 2 e-nummers that are similar. A lot of the dist-2 and 3 are like this
######################################################################
# trick 2: 2 strings, one with hyphen space, the other with hyphen (dist 1)
#   example: 8168
# grep 8168 tmp7.pairs.?.sql
# tmp7.pairs.1.sql:INSERT INTO compare_ingredients VALUES ( 8168 , 7046 , "ingredienser: gris- och nötkött" , 7047 , "ingredienser: gris-och nötkött" , 1 , 4 , 0 );
# trick 3: 2 strings, edit distance 1, one with a space removed => keep the one with the space

eecho()
{
  ( echo $* 1>&2 ) > /dev/null
}

msg=$( wc -l tmp7.pairs.?.sql 2>&1 )
eecho "$msg"

#DBG# grep nötkött tmp4.01.in*

for dist in 1 2 3; do
  rm -f $OUTDIR/tmp.work.$dist
  rm -f $OUTDIR/tmp.discard.$dist
  intable=$OUTDIR/tmp7.pairs.$dist.sql

  if [ ! -f $intable ] || [ ! -s $intable ]; then
    eecho "WARNING $intable empty or not existant"
    continue
  fi # not empty

  cat $intable |\
    grep '^INSERT INTO' |\
    cat > tmp.reduce

  nlinesbefore=$( cat tmp.reduce | wc -l )
  nlinesafter="$nlinesbefore"

  #DBG# less tmp.reduce

  E1="^E(1[0-9][0-9][0-9]|[1-9][0-9][0-9])"
  E2="$E1"
  for li in $( seq 1 $nlinesbefore ); do
    ll=$( cat tmp.reduce | head -n $li | tail -n 1 )
    w1=$( echo "$ll" | cut -d'"' -f2 )
    w2=$( echo "$ll" | cut -d'"' -f4 )

    m1=$( echo "$w1" | egrep -c "$E1" )
    m2=$( echo "$w2" | egrep -c "$E2" )

    # delete if both different E-nummer, but NOT if same e-nummer
    # because then, I want to see the difference in the context.

    if [ $m1 -eq 1 ] && [ $m2 -eq 1 ]; then
      eecho "DBG consider delete 2-e-nummers $w1 $w2 in $ll"
    else
      echo "$ll" >> $OUTDIR/tmp.work.$dist
      continue
    fi

    helpstring1=$( echo "$w1" |cut -c1-4 )
    helpstring2=$( echo "$w2" |cut -c1-4 )
    if [ "$helpstring1" = "$helpstring2" ]; then
      # SPECIAL CASE: both strings are about e-nummers, but the actual
      # e-nummer is THE SAME, so there is some other, possibly significant,
      # difference. 
      # ACTION: leave it in.
      eecho "DBG KEEP same enummer $helpstring1 $helpstring2 for $m1 , $m2"
      echo "$ll" >> $OUTDIR/tmp.work.$dist
      continue
    fi

    # ignore this table entry; assume all digits of E-nummers significant and never wrongly spelled...
#DBG#    eecho "DBG edit distance=$dist delete 2-e-nummers $w1 $w2 in $ll"
    echo "$ll" >> $OUTDIR/tmp.discard.$dist
    nlinesafter=$(( $nlinesafter - 1 ))

  done # next line


  eecho "edit distance = $dist table reduced from $nlinesbefore to $nlinesafter"

  # echo "stop here for now"; exit 0

done # next dist

for dist in 1 2 3; do
  eecho ""
  eecho $( mv -v $OUTDIR/tmp.work.$dist $OUTDIR/tmp8.pairs.$dist.sql )
  eecho $( mv -v $OUTDIR/tmp.discard.$dist $OUTDIR/tmp8.pairs.discard.$dist.sql )
  eecho $( wc -l $OUTDIR/tmp7.pairs.$dist.sql )
  eecho $( wc -l $OUTDIR/tmp8.pairs.$dist.sql $OUTDIR/tmp8.pairs.discard.$dist.sql )
done

cat $OUTDIR/tmp8.mainstream
rm $OUTDIR/tmp8.mainstream

exit 0

