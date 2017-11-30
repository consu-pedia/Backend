#!/bin/bash
# N.B. this script leaves the main dataset and the ingredients list alone
# it only works on the Levenshtein pair lists (tmp7.pairs.x.sql)
# to make them a bit smaller.

cat > $OUTDIR/tmp10.mainstream

#  input = tmp9.pairs.x.sql
# output = tmp10.pairs.x.sql

# 3 tricks:
# trick 1: 2 e-nummers that are similar. A lot of the dist-2 and 3 are like this
######################################################################
# trick 2: 2 strings, one with hyphen space, the other with hyphen (dist 1)
#   example: 8168
# grep 8168 tmp7.pairs.?.sql
# tmp7.pairs.1.sql:INSERT INTO compare_ingredients VALUES ( 8168 , 7046 , "ingredienser: gris- och nötkött" , 7047 , "ingredienser: gris-och nötkött" , 1 , 4 , 0 );
######################################################################
# trick 3: 2 strings, edit distance 1, one with a space removed => keep the one with the space
# I suspect that, when the label got scanned, it incorrectly glued two lines together.

eecho()
{
  ( echo $* 1>&2 ) > /dev/null
}

msg=$( wc -l tmp9.pairs.?.sql 2>&1 )
eecho "$msg"

#DBG# grep nötkött tmp4.01.in*

for dist in 1 ; do
  rm -f $OUTDIR/tmp.work.$dist
  rm -f $OUTDIR/tmp.discard.$dist
  intable=$OUTDIR/tmp9.pairs.$dist.sql
#DBG# intable=grisnotkott.sample

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

  for li in $( seq 1 $nlinesbefore ); do
    ll=$( cat tmp.reduce | head -n $li | tail -n 1 )
    w1=$( echo "$ll" | cut -d'"' -f2 )
    w2=$( echo "$ll" | cut -d'"' -f4 )

    len1=$( echo "$w1" | wc -c )
    len2=$( echo "$w2" | wc -c )


    # we're looking for the case where one of the sentences has a space extra
    longest=1
    shortstring="$w1"
    longstring="$w2"
    if [ $(( $len1 + 1 )) -eq $len2 ]; then
      longest=2
    else
      if [ $(( $len2 + 1 )) -eq $len1 ]; then
        longest=1
        shortstring="$w2"
        longstring="$w1"
      else
        # equally long can't be the right type of string
        echo "$ll" >> $OUTDIR/tmp.work.$dist
        continue
      fi
    fi

    # first match the text "-och"
    bingo=$( echo "$shortstring" | grep -c -- '-och' )
    if [ $bingo -eq 0 ]; then
      # can't be the right type of string, skip
      echo "$ll" >> $OUTDIR/tmp.work.$dist
      continue
    fi

    # compare letter to letter

    bingo=$( echo "$shortstring""""$longstring" | awk -F'' -f reduce_pairs_spaces.awk )

    eecho "DBG bingo=  $bingo for $w1	/	$w2"

    if [ "$bingo" = "1" ]; then
      echo "$ll" >> $OUTDIR/tmp.discard.$dist
      nlinesafter=$(( $nlinesafter - 1 ))
    else
      echo "$ll" >> $OUTDIR/tmp.work.$dist
    fi


  done # next line


  eecho "edit distance = $dist table reduced from $nlinesbefore to $nlinesafter"

  # echo "stop here for now"; exit 0

done # next dist

for dist in 1    ; do
  eecho ""
  eecho $( mv -v $OUTDIR/tmp.work.$dist $OUTDIR/tmp10.pairs.$dist.sql )
  eecho $( mv -v $OUTDIR/tmp.discard.$dist $OUTDIR/tmp10.pairs.discard.$dist.sql )
  eecho $( wc -l $OUTDIR/tmp9.pairs.$dist.sql )
  eecho $( wc -l $OUTDIR/tmp10.pairs.$dist.sql $OUTDIR/tmp10.pairs.discard.$dist.sql )
done

cat $OUTDIR/tmp10.mainstream
rm $OUTDIR/tmp10.mainstream


exit 0

