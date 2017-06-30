#!/bin/bash
# helper script, don't know yet if works

inf="$1"

e=0

cp "$inf" in

while [ 1 ]; do
cat in | head -n 1 | cut -d: -f1 | tr -d '\n' > tmp.01
if [ ! -s tmp.01 ]; then echo empty; rm tmp.01; exit 1; fi
wrong=$( cat tmp.01 | tr -d '[0-9]' | wc -c )
if [ $wrong -ne 0 ]; then echo wrong; exit 1; fi

e0=$( printf "e.%05d" $e )

l0=$( cat tmp.01 )
l0l=$( cat tmp.01 | wc -c )
l=$(( $l0l + 1 + $l0 + 1 ))
echo "dump $e0 length $l0l+1+$l0+1 = $l"

dd if=in bs=$l skip=0 count=1 > $e0 2> err.$e0
dd if=in bs=$l skip=1         > rest 2> err.rest

mv rest in

e=$(( $e + 1 ))
done


exit 0

