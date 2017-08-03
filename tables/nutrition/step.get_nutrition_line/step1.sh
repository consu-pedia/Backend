#!/bin/bash

cat |\
  awk -v"ofp=$OUTDIR/tmp1.ofp" -v"ofi=$OUTDIR/tmp1.ofi" 'BEGIN {c=3;n=3;nn="UNKNOWN_NUTRITION";cc="__DELETED__";cdone=1;} \
       {c++; n++;
#print c" "$0; 
        if (c==2) { cc=$0; cdone=0; } \
        if ((c>2) && ($2=="=>") && (cdone==0)) { \
           testcdone=strtonum($1);if (testcdone==0){  \
             cdone=1; \
           } else { \
            cc=cc "" $0; \
           }
        }\
        if (n==2) { nn=$0; } \
       } \
       / .NutritionFacts. =>/ { c=0; }\
       /^   .Name. =>/ { n=0; }\
       /^attributes/ { if (NR>2) {print nn > ofp; print cc > ofi;}; n=3;c=3;nn="UNKNOWN_NUTRITION";cc="__DELETED__";cdone=1;} \
       END {print nn > ofp; print cc > ofi;} \
      ' 
  cat $OUTDIR/tmp1.ofi

exit 0

