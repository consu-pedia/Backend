#!/bin/bash

# this program is interactive!
#DONT# # passthru in
#DONT# cat > tmp.smallwords.mainstream

# this one is to remove small words
# needs manual processing step
# cutoff: word length <= $SMALLWORD
SMALLWORD=4
# 150 small words
#  29 tmp5.blacklist
# 120 tmp5.whitelist
#   1 unsure :-)

if [ "$EDITOR" = "" ]; then
  EDITOR=vi
fi

eecho()
{
  ( echo $* 1>&2 ) > /dev/null
}

# this edits the ingredients table

if [ "$OUTDIR" = "" ] || [ "$CURINP_INGREDIENTS" = "" ] || [ "$CUROUT_INGREDIENTS" = "" ]; then
  echo "ERROR UNDEFINED OUTDIR=$OUTDIR CURINP_INGREDIENTS=$CURINP_INGREDIENTS /CUROUT_INGREDIENTS =$CUROUT_INGREDIENTS"
  exit 1
fi



# line 2: select small words
cat $CURINP_INGREDIENTS |\
  awk -v"s=$SMALLWORD" '{if(length($0)<=s) {print}}' |\
  cat > $OUTDIR/tmp5.smallwords.current

ncursmw=$( cat $OUTDIR/tmp5.smallwords.current | wc -l )
eecho "currently $ncursmw ingredients keywords of length <= $SMALLWORD"

if [ ! -f ingredients.blacklist ] || [ ! -f ingredients.whitelist ]; then
  echo "ERROR first create or copy ingredients.blacklist and ingredients.whitelist from $OUTDIR/tmp5.smallwords.current"
  exit 1
fi

cat $OUTDIR/tmp5.smallwords.current ingredients.whitelist ingredients.whitelist ingredients.blacklist ingredients.blacklist | sort | uniq -c | awk '{if($1==1){$1="";print}}' |cut -c2- > $OUTDIR/tmp5.new

if [ -s $OUTDIR/tmp5.new ]; then
# first edit with blacklist
echo "__EDIT_BLACKLIST__" > $OUTDIR/tmp5.blacklist.new
cat $OUTDIR/tmp5.new >> $OUTDIR/tmp5.blacklist.new
$EDITOR $OUTDIR/tmp5.blacklist.new

# next edit with whitelist
echo "__EDIT_WHITELIST__" > $OUTDIR/tmp5.whitelist.new
cat $OUTDIR/tmp5.new >> $OUTDIR/tmp5.whitelist.new
$EDITOR $OUTDIR/tmp5.whitelist.new

cat $OUTDIR/tmp5.blacklist.new | grep -v '__EDIT_BLACKLIST__' >> ingredients.blacklist
cat $OUTDIR/tmp5.whitelist.new | grep -v '__EDIT_WHITELIST__' >> ingredients.whitelist
fi # tmp5.new not empty


cat $CURINP_INGREDIENTS |\
  grep -n -F --line-regexp -f ingredients.blacklist |\
  cut -d: -f1 |\
  cat > $OUTDIR/tmp5.work

# this works well upto approx 100 entries otherwise becomes too slow
# N.B. after close parenthesis is a TAB character
cat $OUTDIR/tmp5.work | tr '\n' '|' | sed -e 's/^/^ *(/;s/|$/)	/;' > $OUTDIR/tmp5.regex

# annoying bug: first ingredient is the empty string ^$
# and nl ignores it causing an off-by-one error :-(
cat $CURINP_INGREDIENTS |\
  nl -ba |\
  egrep -f $OUTDIR/tmp5.regex |\
  cat > $OUTDIR/tmp5.work2

cat $CURINP_INGREDIENTS |\
  nl -ba |\
  egrep -v -f $OUTDIR/tmp5.regex |\
  cat > $OUTDIR/tmp5.work3

# now remove the line numbers
# N.B. sed script line 2 contains a TAB U+0009
cat $OUTDIR/tmp5.work3 |\
  sed -e 's/^ *[0-9][0-9]*	//' |\
  cat > $OUTDIR/tmp5.work4

mv $OUTDIR/tmp5.work4 $CUROUT_INGREDIENTS


# passthru out
#DONT# cat tmp.smallwords.mainstream
#DONT# rm tmp.smallwords.mainstream
cp $CURINP $CUROUT

exit 0
