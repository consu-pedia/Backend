#!/bin/bash

nprod=$( cat prods.txt |wc -l )
ningred=$( cat ingred.txt |wc -l )

echo "$nprod products $ningred ingredients"

# prepro: check nothing contains control code 0x1f octal \037

wrong=$( cat prods.txt ingred.txt | tr -d -c '\037' )
if [ ! "$wrong" = "" ]; then
  echo "EXIT contains it"
  exit 1
fi

# index and comma-separate
# syntax in: [^ *][0-9][0-9]*\t
# TODO chunking
# this gives the following syntax:
# syntax <product idx> <sep> <ingredient name> <sep> <position of ingredient in ingredientlist>
rm -f tmp.prod.idx.01
for pi in $( seq 1 $nprod ); do
  pl=$( cat prods.txt | head -n $pi | tail -n 1 )
  echo "$pl" |\
    tr ',' '\n' |\
    sed -e 's/^ */'"$pi"'\x1f/;s/ *$//;' |\
    nl -ba |\
    sed -e 's/^ *\([0-9][0-9]*\)	\(.*$\)/\2\x1f\1/' |\
    cat >> tmp.prod.idx.01
done

# trick: product index #0 doesnt exist so we use it to indicate
# syntax 0(dummy) <sep> <ingredient name> <sep> <ingredient idx>
cat ingred.txt |\
  nl -ba |\
  sed -e 's/^ *\([0-9][0-9]*\)	\(.*$\)/0\x1f\2\x1f\1/' > tmp.ingred.idx.01


cat tmp.prod.idx.01 tmp.ingred.idx.01 |\
  sort -t'' -k2,2 |\
  cat > tmp.merge.01

# now if I could only sort tmp.merge.01

cat tmp.merge.01 |\
  awk -F'' 'BEGIN {ingredname="dummy ingredient dont use";OFS=sprintf("%c", 31);};\
              {if ($1==0){ingredname=$2;ingredidx=$3;next;}\
               if ($2==ingredname){ $2="_INGREDIENT_"ingredidx"_"; };\
               print;\
              }' |\
  cat > tmp.merge.03

cat tmp.merge.03 |\
  grep '_INGREDIENT_' |\
  tr '\037_' ',,' |\
  awk -F, '{printf("INSERT INTO productcontent VALUES(%s , %s);\n", $1 , $4 );}' |\
  cat > tmp.p-i.table


# RECONSTRUCT
# it's not necessary but a great way to validate
rm -f tmp.reconstruct
# SLOOOW
for p in $( seq 1 $nprod ); do
  plines=$( cat tmp.merge.03 | grep '^'"$p"'' | sort -t '' -n -k 3 )
  echo "$plines" |\
    cut -d'' -f2 |\
    tr '\n' ',' |\
    sed -e 's/,/, /g;s/, , $/,/;' |\
    cat >> tmp.reconstruct
  echo >> tmp.reconstruct
    
done


exit 0

