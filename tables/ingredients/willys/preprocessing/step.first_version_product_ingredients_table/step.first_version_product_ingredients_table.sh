#!/bin/bash
# use current ingredients list to form product-ingredients

cat > $OUTDIR/tmp.mainstream

eecho()
{
  ( echo $* 1>&2 ) > /dev/null
}


cp $CURINP $OUTDIR/tmp6.inp

#DONTUSE# np=$( cat $OUTDIR/tmp6.inp | wc -l )
#DONTUSE# nw=$( cat $CURINP_INGREDIENTS | wc -l )
#DONTUSE# eecho "$OUTDIR: $np products, $nw ingredients, this step is very slow"
#DONTUSE# 
#DONTUSE# rm -f $OUTDIR/tmp6.difficult
#DONTUSE# for w in $( seq 1 $nw ); do
#DONTUSE#   wl=$( cat $CURINP_INGREDIENTS | head -n $w | tail -n 1 )
#DONTUSE#   wmod100=$(( $w % 100 ))
#DONTUSE#   if [ $wmod100 -eq 0 ]; then eecho ".. $w / $nw "; fi
#DONTUSE#   difficult0=$( echo "$wl" | tr -d '[-a-z0-9 ]' )
#DONTUSE#   difficult="$difficult0"
#DONTUSE#   if [ ! "$difficult" = "" ]; then
#DONTUSE#     echo "$wl" >> $OUTDIR/tmp6.difficult
#DONTUSE#   fi
#DONTUSE# done # next ingredient $w


#======================================================================

nprod=$( cat $OUTDIR/tmp6.inp | wc -l )
ningred=$( cat $CURINP_INGREDIENTS | wc -l )

echo "$nprod products $ningred ingredients"

# prepro: check nothing contains control code 0x1f octal \037

wrong=$( cat $OUTDIR/tmp6.inp $CURINP_INGREDIENTS | tr -d -c '\037' )
if [ ! "$wrong" = "" ]; then
  eecho "product_ingredients_table: ERROR, input contains separator char 0x1f"
  exit 1
fi

# index and comma-separate
# syntax in: [^ *][0-9][0-9]*\t
# TODO chunking
# this gives the following syntax:
# syntax <product idx> <sep> <ingredient name> <sep> <position of ingredient in ingredientlist>
rm -f $OUTDIR/tmp6.prod.idx.01
for pi in $( seq 1 $nprod ); do
  pl=$( cat $OUTDIR/tmp6.inp | head -n $pi | tail -n 1 )
  echo "$pl" |\
    tr ',' '\n' |\
    sed -e 's/^ */'"$pi"'\x1f/;s/ *$//;' |\
    nl -ba |\
    sed -e 's/^ *\([0-9][0-9]*\)	\(.*$\)/\2\x1f\1/' |\
    cat >> $OUTDIR/tmp6.prod.idx.01
done

# trick: product index #0 doesnt exist so we use it to indicate
# syntax 0(dummy) <sep> <ingredient name> <sep> <ingredient idx>
cat $CURINP_INGREDIENTS |\
  nl -ba |\
  sed -e 's/^ *\([0-9][0-9]*\)	\(.*$\)/0\x1f\2\x1f\1/' > $OUTDIR/tmp6.ingred.idx.01


cat $OUTDIR/tmp6.prod.idx.01 $OUTDIR/tmp6.ingred.idx.01 |\
  sort -t'' -k2,2 |\
  cat > $OUTDIR/tmp6.merge.01

# now if I could only sort tmp6.merge.01

cat $OUTDIR/tmp6.merge.01 |\
  awk -F'' 'BEGIN {ingredname="dummy ingredient dont use";OFS=sprintf("%c", 31);};\
              {if ($1==0){ingredname=$2;ingredidx=$3;next;}\
               if ($2==ingredname){ $2="_INGREDIENT_"ingredidx"_"; };\
               print;\
              }' |\
  cat > $OUTDIR/tmp6.merge.03


# TODO
# tmp6.merge.03 table is *NOT* unique in key ( product_id, content_id)
# so this gives a problem when inserting into MySQL
# needs an extra uniq step before I figure out why (tf) it is not unique in
# the first place!
echo 'USE consupedia;' > $OUTDIR/tmp6.content_product.sql
echo 'DELETE FROM `content_product`;'>> $OUTDIR/tmp6.content_product.sql
  # awk -F, '{printf("INSERT INTO content_product VALUES(%d, %s , %s , %s);\n", NR, $1 , $4 , $6 );}' |\
  # awk -F, '{printf("INSERT INTO content_product VALUES(%s, %s , %s , %s);\n", NR, $1 , $4 , $6 );}' |\
cat $OUTDIR/tmp6.merge.03 |\
  sort -n | uniq |\
  grep '_INGREDIENT_' |\
  tr '\037_' ',,' |\
  awk -F, '{printf("INSERT INTO content_product SET id = %d, product_id = %s, content_id = %s, content_product_ranknr = %s;\n", NR, $1 , $4 , $6 );}' |\
  cat >> $OUTDIR/tmp6.content_product.sql



# sql dump contents
echo 'USE consupedia;' > $OUTDIR/tmp6.contents.sql
echo 'DELETE FROM `contents`;'>> $OUTDIR/tmp6.contents.sql
  # awk -F'' '{printf("INSERT INTO contents VALUES(%s , %c%s%c);\n", $3 , 39, $2 , 39 );}' |\
cat $OUTDIR/tmp6.ingred.idx.01 |\
  tr -d '\047' |\
  awk -F'' '{printf("INSERT INTO contents SET id = %s , name = %c%s%c;\n", $3 , 39, $2 , 39 );}' |\
  cat >> $OUTDIR/tmp6.contents.sql



# RECONSTRUCT
# it's not necessary but a great way to validate
rm -f tmp6.reconstruct
# SLOOOW
for p in $( seq 1 $nprod ); do
  plines=$( cat $OUTDIR/tmp6.merge.03 | grep '^'"$p"'' | sort -t '' -n -k 3 )
  echo "$plines" |\
    cut -d'' -f2 |\
    tr '\n' ',' |\
    sed -e 's/,/, /g;s/, , $/,/;' |\
    cat >> $OUTDIR/tmp6.reconstruct
  echo >> $OUTDIR/tmp6.reconstruct
done

# TODO reconstruct until it looks like the input again, i.e. substitute the
# ingredients

exit 0

#======================================================================


# doesn't affect main data stream
cat $OUTDIR/tmp6.mainstream
rm $OUTDIR/tmp6.mainstream

exit 0


