#!/bin/bash
# this program needs to be sourced like this:
# . get_shop_from_prodid.sh 
export PRODID_WILLYS_FIRST=1
export PRODID_COOP_FIRST=8095
export PRODID_ICA_FIRST=12969

get_shop_from_prodid()
{
  myprodid=$1
# maybe numeric test??
#  myprodid=$(( "$myprodid" + 0 ))

  if [ $myprodid -lt $PRODID_COOP_FIRST ]; then echo "willys"; return; fi
  if [ $myprodid -lt $PRODID_ICA_FIRST ]; then echo "coop"; return; fi
  echo "ica"; return
}
