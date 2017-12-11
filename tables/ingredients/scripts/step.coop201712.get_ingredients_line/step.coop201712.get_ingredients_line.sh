#!/bin/bash
# unfortunately, this newly botted one is NOT the same format as Dino's
# from last year.
# old syntax: 'Content' => array ( 0 => 'ingredient1, ingredient2', ),
# new syntax: "Content" : [ "ingredient1, ingredient2" ],

cat |\
  awk -v"ofp=$OUTDIR/tmp1.ofp" -v"ofi=$OUTDIR/tmp1.ofi" 'BEGIN {c=3;n=3;nn="UNKNOWN_PRODUCT";cc="__DELETED__";} \
       {c++; n++;
#print c" "$0; 
        if (c==1) { cc=$0; } \
        if (n==1) { nn=$0; } \
       } \
       / .Content. : \[/ { c=0; }\
       / .Name. : \[/ { n=0; }\
       / .Entity. : / { if (NR>4) {print nn > ofp; print cc > ofi;}; n=3;c=3;nn="UNKNOWN_PRODUCT";cc="__DELETED__";} \
       END {print nn > ofp; print cc > ofi;} \
      ' 
cat $OUTDIR/tmp1.ofi |\
  sed -e 's/^  *//;' |\
  tr -d '\042' |\
  cat


# N.B. the tr command is stupid but I couldn't get it to parse LC_COLLATE :-(

cat $OUTDIR/tmp1.ofp |\
  # sed -e 's/^  *0 => *\x27//;s/\x27,$//;' |\
  tr -d '\042' |\
  tr '[:upper:]' '[:lower:]' | tr 'ÄÅÖÉ' 'äåöé' |\
  sed -e 's/^  *//' |\
  cat > $OUTDIR/tmp1.productnames

exit 0

