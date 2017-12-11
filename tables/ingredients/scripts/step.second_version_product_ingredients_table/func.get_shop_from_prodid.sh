#!/bin/bash
# this program needs to be sourced like this:
# . get_shop_from_prodid.sh 
# export PRODID_WILLYS_FIRST=1
# export PRODID_COOP_FIRST=8095
# export PRODID_ICA_FIRST=12969
# this script is actually a SERIOUSLY inflexible, bad idea. TODO.

export PRODID_OLDCOOP_FIRST=$(( 0 + 1 ))
export PRODID_WILLYS_FIRST=$(( 4875 + 1 ))
export PRODID_COOP201712_FIRST=$(( 15193 + 1 ))
export PRODID_LAST=15193


get_shop_from_prodid()
{
  myprodid=$1
  myshop="__UNDEFINED_SHOP__"
# maybe numeric test??
#  myprodid=$(( "$myprodid" + 0 ))

  if [ $myprodid -lt $PRODID_LAST ]; then myshop="ica"; fi
  if [ $myprodid -lt $PRODID_ICA_FIRST ]; then echo "coop201712"; fi
  if [ $myprodid -lt $PRODID_COOP201712_FIRST ]; then myshop="willys"; fi
  if [ $myprodid -lt $PRODID_WILLYS_FIRST ]; then myshop="oldcoop"; fi
  echo "$myshop"; return
}
