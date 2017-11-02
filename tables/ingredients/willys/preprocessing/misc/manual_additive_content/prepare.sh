#!/bin/bash
if [ ! -f tmp6.ingred.idx.01 ]; then
  echo "copy tmp6.ingred.idx.01 to this directory"
  exit 1
fi

if [ -f manual_input_additive_content ]; then
  echo "ERROR will not overwrite existing file manual_input_additive_content"
  exit 1
fi

sanity=$( cat tmp6.ingred.idx.01 | grep -c '	' )
if [ $sanity -ne 0 ]; then
  echo "ERROR the input table has TABs"
  exit 1
fi

# separator char = U+001F octal 037
cat tmp6.ingred.idx.01 |\
  cut -d'' -f2 |\
  awk -F'	' 'BEGIN { re="[eE][0-9][0-9]([0-9]){1,2}([a-hj-z]){0,1}([i]){0,}"; } \
                  {enm="UNK";OFS="	"; \
                   for(i=1;i<=NF;i++){if(match($(i), re, a)>0) {enm=substr($(i), a[0, "start"], a[0, "length"]); enm="?"enm;};};     print enm"	"$0; }' |\
  sed -e 's/^	//' |\
  cat > manual_input_additive_content 

echo
wc -l manual_input_additive_content 
echo -n "possible enummers: "
cat manual_input_additive_content |grep -v '^UNK' |wc -l
echo
echo "next edit manual_input_additive_content manually, then run program x"

exit 0

