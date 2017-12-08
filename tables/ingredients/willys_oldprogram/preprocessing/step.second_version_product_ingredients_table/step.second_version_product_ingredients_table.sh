#!/bin/bash
# use current ingredients list to form product-ingredients
# n.b. change key from productid to gtin will give some problems
# where the gtin is not unique, even within-shop so { gtin, shop} is not
# unique either.
# Willys has 2 products (Pukka Detox Te with Cardamom)
# 101146136_ST => { 850835000122 , "willys" }
# 101248269_ST => { 850835000122 , "willys" }

cat > $OUTDIR/tmp6a.mainstream

# NB it gets EXECUTED from topdir
. ./func.get_shop_from_prodid.sh
# . ../func.get_shop_from_prodid.sh

testshop=$( get_shop_from_prodid 1 )
if [ "$testshop" = "" ]; then
  cwd=$( pwd )
  whre=$( find .. -type f -name 'func.get_shop_from_prodid.sh' )
  ( echo "ERROR function get_shop_from_prodid() NOT LOADED, pwd=$cwd, did find it in $whre" 1>&2 ) > /dev/null
  exit 1
fi


# following auxiliary tables are available and get used here:
# tmp1a.product_gtin_table.raw
# tmp1b.product_productname_table.raw

eecho()
{
  ( echo $* 1>&2 ) > /dev/null
}


cp $CURINP $OUTDIR/tmp6a.inp
cp tmp6.inp $OUTDIR/tmp6a.inp

#DONTUSE# np=$( cat $OUTDIR/tmp6a.inp | wc -l )
#DONTUSE# nw=$( cat $CURINP_INGREDIENTS | wc -l )
#DONTUSE# eecho "$OUTDIR: $np products, $nw ingredients, this step is very slow"
#DONTUSE# 
#DONTUSE# rm -f $OUTDIR/tmp6a.difficult
#DONTUSE# for w in $( seq 1 $nw ); do
#DONTUSE#   wl=$( cat $CURINP_INGREDIENTS | head -n $w | tail -n 1 )
#DONTUSE#   wmod100=$(( $w % 100 ))
#DONTUSE#   if [ $wmod100 -eq 0 ]; then eecho ".. $w / $nw "; fi
#DONTUSE#   difficult0=$( echo "$wl" | tr -d '[-a-z0-9 ]' )
#DONTUSE#   difficult="$difficult0"
#DONTUSE#   if [ ! "$difficult" = "" ]; then
#DONTUSE#     echo "$wl" >> $OUTDIR/tmp6a.difficult
#DONTUSE#   fi
#DONTUSE# done # next ingredient $w


#======================================================================

nprod=$( cat $OUTDIR/tmp6a.inp | wc -l )
ningred=$( cat $CURINP_INGREDIENTS | wc -l )

eecho "$nprod products $ningred ingredients"

# prepro: check nothing contains control code 0x1f octal \037

wrong=$( cat $OUTDIR/tmp6a.inp $CURINP_INGREDIENTS | tr -d -c '\037' )
if [ ! "$wrong" = "" ]; then
  eecho "product_ingredients_table: ERROR, input contains separator char 0x1f"
  exit 1
fi

# index and comma-separate
# syntax in: [^ *][0-9][0-9]*\t
# TODO chunking
# this gives the following syntax:
# syntax <product idx> <sep> <ingredient name> <sep> <position of ingredient in ingredientlist>
rm -f $OUTDIR/tmp6a.prod.idx.01
for pi in $( seq 1 $nprod ); do
  pl=$( cat $OUTDIR/tmp6a.inp | head -n $pi | tail -n 1 )
#NOTHERE  shop=$( get_shop_from_prodid $pi )
#NOTHERE  prodid_gtin=$( grep '^'"$pi"'' $OUTDIR/tmp1a.product_gtin_table.raw )

  echo "$pl" |\
    tr ',' '\n' |\
#NOTHERE    sed -e 's/^ */'"$shop"'\x1f'"$prodid_gtin"'\x1f/;s/ *$//;' |\
    sed -e 's/^ */'"$pi"'\x1f/;s/ *$//;' |\
    nl -ba |\
    sed -e 's/^ *\([0-9][0-9]*\)	\(.*$\)/\2\x1f\1/' |\
    cat >> $OUTDIR/tmp6a.prod.idx.01
done

# trick: product index #0 doesnt exist so we use it to indicate
# syntax 0(dummy) <sep> <ingredient name> <sep> <ingredient idx>
cat $CURINP_INGREDIENTS |\
  nl -ba |\
  sed -e 's/^ *\([0-9][0-9]*\)	\(.*$\)/0\x1f\2\x1f\1/' > $OUTDIR/tmp6a.ingred.idx.01


cat $OUTDIR/tmp6a.prod.idx.01 $OUTDIR/tmp6a.ingred.idx.01 |\
  sort -t'' -k2,2 |\
  cat > $OUTDIR/tmp6a.merge.01

# now if I could only sort tmp6a.merge.01

cat $OUTDIR/tmp6a.merge.01 |\
  awk -F'' 'BEGIN {ingredname="dummy ingredient dont use";OFS=sprintf("%c", 31);};\
              {if ($1==0){ingredname=$2;ingredidx=$3;next;}\
               if ($2==ingredname){ $2="_INGREDIENT_"ingredidx"_"; };\
               print;\
              }' |\
  cat > $OUTDIR/tmp6a.merge.02
# the file previously known as tmp6.merge.03

rm -f $OUTDIR/tmp6a.auxtable
for pi in $( seq 1 $nprod ); do
  shop=$( get_shop_from_prodid $pi )
  prodid_gtin=$( grep '^'"$pi"'' $OUTDIR/tmp1a.product_gtin_table.raw )
  echo "$pi"""",sortingfield""""$shop""""$prodid_gtin" >> $OUTDIR/tmp6a.auxtable
done

# use a kind of mergesort, and # fields to distinguish.
cat $OUTDIR/tmp6a.merge.02 $OUTDIR/tmp6a.auxtable | sort -t'' -n > $OUTDIR/tmp6a.merge.02.5

#WRONG  awk -F'' '{if (NF==5){shop=$3;prodid=$4;gtin=$5;} else {if (NF==3){OFS='';printf("%s%s%s%s%s%s%s%s\n",gtin, OFS, shop, OFS, prodid, OFS, $2, OFS, $3);}else {print "ERROR $0";}}}' |\

cat $OUTDIR/tmp6a.merge.02 $OUTDIR/tmp6a.auxtable |\
  sort -t'' -n -k1,2 -r |\
  awk -F'' '{if (NF==5){shop=$3;prodid=$4;gtin=$5;}else { if (NF==3){ content_id = $2; content_product_ranknr = $3; printf("%s%s%s%s%s\n", gtin, shop, prodid, content_id, content_product_ranknr );}else {printf("ERROR %s\n",$0);} } }' |\
  cat > $OUTDIR/tmp6a.merge.02.75

# N.B. table tmp6a.merge.02.75 has prodid as field #3, but it is NOT stored in the SQL table!
rm -f $OUTDIR/tmp6a.duplicate_gtin $OUTDIR/tmp6a.duplicate_prodid_shop_gtin
cat $OUTDIR/tmp6a.auxtable | awk -F'' '{print $5}' | sort | uniq -d > $OUTDIR/tmp6a.duplicate_gtin
if [ -s $OUTDIR/tmp6a.duplicate_gtin ]; then
  nd=$( cat $OUTDIR/tmp6a.duplicate_gtin |wc -l )
  eecho "processing $nd duplis, creating tmp6a.merge.03"
  cp -p $OUTDIR/tmp6a.merge.02.75 $OUTDIR/tmp6a.merge.03
  
  rm -f $OUTDIR/tmp6a.merge.02.75.allduplis
  for d in $( seq 1 $nd ); do
    dl=$( cat $OUTDIR/tmp6a.duplicate_gtin | head -n "$d" | tail -n 1 )
    grep -a "$dl"'$' $OUTDIR/tmp6a.auxtable >> $OUTDIR/tmp6a.duplicate_prodid_shop_gtin
    prodids=$( grep -a "$dl"'$' $OUTDIR/tmp6a.duplicate_prodid_shop_gtin | cut -d'' -f 1 )
    keep=$( echo "$prodids" | tail -n 1 )
 
    # result gets sorted anyhow
    cat $OUTDIR/tmp6a.merge.03 | awk -F'' -v"gtin=$dl" '{if ($1!=gtin){print}}' > $OUTDIR/tmp6a.merge.03.work.1
    cat $OUTDIR/tmp6a.merge.03 | awk -F'' -v"gtin=$dl" '{if ($1==gtin){print}}' >> $OUTDIR/tmp6a.merge.02.75.allduplis
    cat $OUTDIR/tmp6a.merge.03 | awk -F'' -v"gtin=$dl" -v"keep=$keep" '{if (($1==gtin)&&($3==keep)){print}}' > $OUTDIR/tmp6a.merge.03.work.2
    
    cat $OUTDIR/tmp6a.merge.03.work.1 $OUTDIR/tmp6a.merge.03.work.2 > $OUTDIR/tmp6a.merge.03
  done
  eecho $( wc -l $OUTDIR/tmp6a.merge.02.75 $OUTDIR/tmp6a.merge.03 )

else
  eecho "no duplis, copying tmp6a.merge.02.75 to tmp6a.merge.03"
  cp -p $OUTDIR/tmp6a.merge.02.75 $OUTDIR/tmp6a.merge.03
fi # no duplis


# TODO
# tmp6a.merge.03 table is *NOT* unique in key ( product_id, content_id)
# so this gives a problem when inserting into MySQL
# needs an extra uniq step before I figure out why (tf) it is not unique in
# the first place!
echo 'USE consupedia;' > $OUTDIR/tmp6a.content_product.sql
echo 'DELETE FROM `content_product`;'>> $OUTDIR/tmp6a.content_product.sql
  # awk -F, '{printf("INSERT INTO content_product VALUES(%d, %s , %s , %s);\n", NR, $1 , $4 , $6 );}' |\
  # awk -F, '{printf("INSERT INTO content_product VALUES(%s, %s , %s , %s);\n", NR, $1 , $4 , $6 );}' |\
cat $OUTDIR/tmp6a.merge.03 |\
  sort -n | uniq |\
  grep '_INGREDIENT_' |\
  tr '\037_' ',,' |\
  awk -F, '{printf("INSERT INTO content_product SET id = %d, gtin_id = %s, shop = %s, content_id = %s, content_product_ranknr = %s;\n", NR, $1 , $2 , $6 , $8 );}' |\
  cat >> $OUTDIR/tmp6a.content_product.sql


# cat $OUTDIR/tmp6a.merge.03 |\
#   sort -n | uniq |\
#   grep '_INGREDIENT_' |\
#   tr '\037_' ',,' |\
#   awk -F, '{printf("INSERT INTO content_product SET id = %d, product_id = %s, content_id = %s, content_product_ranknr = %s;\n", NR, $1 , $4 , $6 );}' |\


# sql dump contents
echo 'USE consupedia;' > $OUTDIR/tmp6a.contents.sql
echo 'DELETE FROM `contents`;'>> $OUTDIR/tmp6a.contents.sql
  # awk -F'' '{printf("INSERT INTO contents VALUES(%s , %c%s%c);\n", $3 , 39, $2 , 39 );}' |\
cat $OUTDIR/tmp6a.ingred.idx.01 |\
  tr -d '\047' |\
  awk -F'' '{printf("INSERT INTO contents SET id = %s , name = %c%s%c;\n", $3 , 39, $2 , 39 );}' |\
  cat >> $OUTDIR/tmp6a.contents.sql


# TODO re-implement this, only works for prodid
# # RECONSTRUCT
# # it's not necessary but a great way to validate
# rm -f tmp6a.reconstruct
# # SLOOOW
# for p in $( seq 1 $nprod ); do
#   plines=$( cat $OUTDIR/tmp6a.merge.03 | grep '^'"$p"'' | sort -t '' -n -k 3 )
#   echo "$plines" |\
#     cut -d'' -f2 |\
#     tr '\n' ',' |\
#     sed -e 's/,/, /g;s/, , $/,/;' |\
#     cat >> $OUTDIR/tmp6a.reconstruct
#   echo >> $OUTDIR/tmp6a.reconstruct
# done

# TODO reconstruct until it looks like the input again, i.e. substitute the
# ingredients


#======================================================================


# doesn't affect main data stream
cat $OUTDIR/tmp6a.mainstream
rm $OUTDIR/tmp6a.mainstream

exit 0


