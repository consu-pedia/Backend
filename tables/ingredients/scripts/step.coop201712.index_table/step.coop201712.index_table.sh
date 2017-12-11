#!/bin/bash
BEGINIDX=0
SHOP="coop201712"

# pass-thru
cat > $OUTDIR/tmp.idxtable.mainstream

# collect SQL table

rm -f $OUTDIR/tmp.gtin.list

# st=0 initial, expect 'Ean' =>
# st=1 expect array {
# 
cat $OUTDIR/tmp.idxtable.mainstream |\
#DBG#  head -n 1000 |\
  awk -v"bi=$BEGINIDX" -v"shop=$SHOP" -v"OD=$OUTDIR" 'BEGIN {gtin=0; st=0; recno=1+bi; }\
      {\
        if ((st==0)&&(match($1,".Ean."))&&(match($2,"=>"))){\
#DBG# print NR" HIT type1 st=0 <" $1 "> "$0;\
          st=1; \
          next;\
        }\
        if ((st==0)&&(match($1,".Ean."))&&(match($2,":"))&&(match($3,"[[]"))){\
#DBG# print NR" HIT type2 st=0 <" $1 "> "$0;\
          st=1; \
          next;\
        }\
#DBG#        print bi+NR" st="st" : "$0; \
        if ((st==1)&&(match($1,"array"))){\
#DBG#          print NR" HIT st=1 <" $1 "> "$0;\
          st=2; \
          next;\
        }\
        if ((st==1)&&(match($1,"^\"[0-9][0-9]*\"$"))){\
#DBG# print NR" HIT st=1 <" $1 "> "$0;\
          st=3; \
          lastgtin=gensub("\"", "", "g", $1); \
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
          printf("%s%s\n",        lastgtin, shop) >> OD"/tmp.gtin.list"; \
          recno++; \
          st=0; \
          next; \
        }\

#DBG#        if (st>0){print bi+NR" st="st" : "$0;} \
      }' |\
  cat 

#OBSOLETED          printf("%d%s%s\n", recno, lastgtin, shop) >> OD"/gtin_table.raw"; \

#NEXTSTEP # convert gtin table to SQL
#NEXTSTEP cat $OUTDIR/gtin_table.raw |\
#NEXTSTEP   awk -F'' '{ printf("INSERT INTO gtintable VALUES ( %d, \"%s\", \"%s\" );\n", $1, $3, $2);}' |\
#NEXTSTEP   cat > $OUTDIR/gtin_table.sql

# pass-thru
cat $OUTDIR/tmp.idxtable.mainstream
rm $OUTDIR/tmp.idxtable.mainstream


exit 0

