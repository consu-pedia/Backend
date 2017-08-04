#!/bin/bash
# N.B. in order to parse the numeric information, I had to do the following
# preparation:
# manually make a SQL table temporarynuts with field textincludingunits
# has the numeric info replaced by one of 2 placeholders 
# __QUANTITY__ (1 value) or
# __QUANTITY_RANGE__ (2 values).
# if these placeholders aren't there then there is no numeric information.
# in that table, I also replaced the units, creating a field I called template.
# so we have:
# output from step 4 (U+001F replaced by comma for readability)
# 137,1,    0 => 'Energi 369 kJ',
# corresponding rough table value as output tmp.nuts.sql from step 2:
# before editing:
# INSERT INTO temporarynuts SET id=17, textincludingunits="Energi QUANTITY kJ", template="Energi QUANTITY kJ", unittext="kJ   ";
# after editing to temporarynuts.sql:
# INSERT INTO temporarynuts SET id=17, textincludingunits="Energi QUANTITY kJ", template="Energi QUANTITY kJ", unittext="kJ";

# for this script step # 5 to work, this table temporarynuts has to manually
# be converted to a second table nutritionscantemplates
# where I modified the templates to a scanf formatting string.
# Because the units are also filtered out, this reduces the 121 records table
# temporarynuts to 84 in nutritionscantemplates.

# to make things a bit easier (hah!) I then used units.sql and nutritionscantemplates.sql and temporarynuts.sql to make temporarynuts2.sql.

# Fri Aug  4 12:05:24 CEST 2017
# temporarynuts2 table is ready.
# I bet you've NEVER seen someone do a CROSS JOIN in as "klumpigt" a way as this script does!
# speed of this script is NOT an issue.

eecho()
{
  ( echo $* 1>&2 ) > /dev/null
}



if [ -f tmp.06.tempnuts2.1F-sep ]; then
  cp -p tmp.06.tempnuts2.1F-sep $OUTDIR/tmp.crossjointable
else
  echo 'SELECT * FROM temporarynuts2;' | mysql -u root -proot nutwork | tr '\011' '\037' > tmp.06.tempnuts2.1F-sep
  if [ ! -s tmp.06.tempnuts2.1F-sep ]; then
    rm tmp.06.tempnuts2.1F-sep
    echo "step5.parsequantity cannot find helper table tmp.06.tempnuts2.1F-sep"
    exit 1
  else
    cp -p tmp.06.tempnuts2.1F-sep $OUTDIR/tmp.crossjointable
  fi
fi

# next steps:
# re-create template just like in step 2

# this script only makes a JOIN, do the parsing in the next step.
if [ "$OUTDIR" = "" ]; then OUTDIR="."; fi

cat > $OUTDIR/tmp.step5.workfile

cat $OUTDIR/tmp.step5.workfile |\
  sed -e 's/^[0-9][0-9]*[0-9][0-9]* *[0-9][0-9]* => //' |\
  sed -e 's/^[0-9][0-9]*[0-9][0-9]*__DELETED__/__DELETED__/' |\
  sed -e 's/ [0-9][0-9,.]*|PIM_MULTIVALUE_SEPARATOR|[0-9][0-9,.]*\([^0-9]\)/ __QUANTITY_RANGE__\1/g' |\
  sed -e 's/ [0-9][0-9,.]*\([^0-9]\)/ __QUANTITY__\1/g' |\
  sed -e 's/^\x27//;s/\x27,$//;' |\
  cat > $OUTDIR/tmp.step5.templates

# screw it.. its only 30 000 records or so... do it the slow way

nr=$( cat $OUTDIR/tmp.step5.workfile | wc -l )

# keep templates table in-core
TEMPLATES=$( cat $OUTDIR/tmp.crossjointable )

eecho "$STEPNAME: processing $nr records the slooow way."
for r in $( seq 1 $nr ); do
  rm1k=$(( $r % 1000 ))
  if [ $rm1k -eq 0 ]; then
    eecho -n "..$r "
  fi

  ll=$( cat $OUTDIR/tmp.step5.workfile | head -n $r | tail -n 1 )
  lt=$( cat $OUTDIR/tmp.step5.templates | head -n $r | tail -n 1 )

#DBG#   eecho "DBG # $r tmpl=<$lt>"
#DBG#   eecho "ll="
#DBG#   eecho "$ll"

  res=$( echo "$TEMPLATES" | grep "$lt" )
  nres=$( echo "$res" | wc -l )
  
  # special case if it is not matched
  if [ $nres -ne 1 ] || [ "$res" = "" ]; then
    echo "$ll" | awk '{OFS="";print $0 OFS "PARSE ERROR";}'
    continue # next r
  fi

  # finally..
  unitid=$( echo "$res" |awk -F'' '{print $5}' )
  nvalues=$( echo "$res" |awk -F'' '{print $7}' )
  scantemplate=$( echo "$res" |awk -F'' '{print $9}' )

  # Fri Aug  4 13:23:06 CEST 2017 very disappointed that awk and perl dont have sscanf..
  echo "$ll""""$unitid""""$nvalues""""$scantemplate"  |\
     awk -F'' 'BEGIN { OFS="";}\
       function p(n,r,inp,unitid,nvalues,st,v1,v2) { printf("PFUNC%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n", n, OFS, r, OFS, inp, OFS, unitid, OFS, nvalues, OFS, st, OFS, v1, OFS, v2);} \
       {\
       n=$1;\
       r=$2;\
       inp=$3;\
       inpl=length(inp);\
       unitid=$4;\
       nvalues=$5;\
       st=$6;\
       oops=match(inp," *[0-9][0-9]* => \x27");\
       if (oops>0){\
         printf("GOTCHA %d %d\n",oops,RLENGTH);\
         # remove initial shit or beginning of string doesnt match !!
         inp=substr(inp, oops + RLENGTH);\
         inpl=length(inp);\
       }\
       oops=match(inp,"\x27,$");\
       if (oops>0){\
         printf("GOTCHA2 %d %d\n",oops,RLENGTH);\
         inp=substr(inp,1,length(inp)-RLENGTH);\
         inpl=length(inp);\
       }\

printf("DBG inp=<%s> inpl=%d st=<%s>\n",inp,inpl,st);\
       v1=0.0;\
       v2=0.0;\
       if (nvalues==0){\
         p(n,r,inp,unitid,nvalues,st,v1,v2);\
         next;\
       }\
       # %f in next line is a literal %f string
       i=index(st,"%f");\
       if (nvalues==2){\
         # HACK for 2-value
         i+= 1 + index(substr(st,i+1),"%f");\
       }\
       if ((i==0)||(length(inp)<i)){ printf("%s%s%s%s%s\n",$0,OFS,st,OFS,"PARSE ERROR"); next; };\
       # inp2 is where in the input we expect the number to show up
       inp2=substr(inp,i);\
       # st2 is the part of the template string after the first %f
       st2=substr(st,i+2);\
       inp3=substr(inp,length(inp)-length(st2)+1);\
       # inp3 seems to be wrong for 2-value :-(
       inp4=substr(inp,i, length(inp2)-length(inp3));\
printf("DBG inp2=%s st2=%s inp3=%s inp4=%s\n",inp2,st2,inp3, inp4);\
       # if (st2!=inp3){printf("%s%s%s%s%s\n",$0,OFS,st,OFS,"PARSE ERROR"); next; };\
       # DO NOT TRY to parse in awk
       v1=inp4;\
       if (nvalues==1){\
         p(n,r,inp,unitid,nvalues,st,v1,v2);\
         next;\
       }\
       printf("DBG TODO nvalues=2\n");\
       i2=index(st2,"%f");\
       if ((i2==0)||(length(inp3)<i2)){ p(n,r,inp,unitid,nvalues,st,v1,"PARSE ERROR"); next; };\
       st3=substr(st2,i2+2);\
       printf("DBG st2=<%s> st3=<%s>\n",st2,st3);\
       inp5=substr(inp3,i2);\
       inp6=substr(inp3,i2, length(inp5)-length(st3));\
       printf("DBG inp3=<%s> inp5=<%s> inp6=<%s>\n", inp3, inp5, inp6);\
       v2=inp6;\
       p(n,r,inp,unitid,nvalues,st,v1,v2);\
       }'

#DBG#   eecho "DBG nres=$nres res="
#DBG#   ( echo "$res" 1>&2 ) > /dev/null

#DBG# eecho "stop here for now."; exit
done

eecho "done."


exit 0

