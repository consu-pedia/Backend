#!/bin/bash

cat |\
  awk -v"ofp=$OUTDIR/tmp1.ofp" -v"ofi=$OUTDIR/tmp1.ofi" 'BEGIN {c=3;n=3;nn="UNKNOWN_NUTRITION";cc="__DELETED__";} \
       {c++; n++;
#print c" "$0; 
        if (c==2) { cc=$0; } \
        if (n==2) { nn=$0; } \
       } \
       / .NutritionFacts. =>/ { c=0; }\
       /^   .Name. =>/ { n=0; }\
       /^attributes/ { if (NR>2) {print nn > ofp; print cc > ofi;}; n=3;c=3;nn="UNKNOWN_NUTRITION";cc="__DELETED__";} \
       END {print nn > ofp; print cc > ofi;} \
      ' 
  cat $OUTDIR/tmp1.ofi

exit 0

