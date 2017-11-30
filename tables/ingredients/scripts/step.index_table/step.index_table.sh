#!/bin/bash
BEGINIDX=0
SHOP="coop"

# pass-thru
cat > $OUTDIR/tmp.idxtable.mainstream

# collect SQL table

rm -f $OUTDIR/idxtable.sql

# st=0 initial, expect 'Ean' =>
# st=1 expect array {
# 
cat $OUTDIR/tmp.idxtable.mainstream |\
#DBG#  head -n 1000 |\
  awk -v"bi=$BEGINIDX" -v"shop=$SHOP" -v"OD=$OUTDIR" 'BEGIN {gtin=0; st=0; recno=1+bi; }\
      {\
        if ((st==0)&&(match($1,".Ean."))&&(match($2,"=>"))){\
#DBG#          print NR" HIT st=0 <" $1 "> "$0;\
          st=1; \
          next;\
        }\
#DBG#        print bi+NR" st="st" : "$0; \
        if ((st==1)&&(match($1,"array"))){\
#DBG#          print NR" HIT st=1 <" $1 "> "$0;\
          st=2; \
          next;\
        }\
        if (st==2) { \
#DBG#          print bi+NR" st="st" : "$0; \
          if (match($1,"),")){ \
            st=3; \
            next; \
          } else { \
            decomma=gensub(",", "", "g", $3);\
            lastgtin=substr(decomma,2,length(decomma)-2); \
#DBG#            print bi+NR" st="st" : lastgtin = "lastgtin; \
            st=3; \
            next; \
          } \
        }\
        if (st==3) { \
          printf("INSERT INTO gtintable VALUES ( %d, \"%s\", \"%s\" );\n", recno, shop, lastgtin) >> OD"/gtin_table.sql"; \
          recno++; \
          st=0; \
          next; \
        }\

#DBG#        if (st>0){print bi+NR" st="st" : "$0;} \
      }' |\
  cat 

# pass-thru
cat $OUTDIR/tmp.idxtable.mainstream
rm $OUTDIR/tmp.idxtable.mainstream


exit 0

