#!/bin/bash
BASE=/home/mitmproxy/data/experiment01
PROXYPORT=8080

if [ $# -ne 1 ]; then
  echo "usage: dump.sh <project name 1 word eg. coop.se>"
  exit 1
fi

proj="$1"

mkdir -p $BASE/$proj

if [ ! -d $BASE/$proj ]; then
  echo "ERROR couldnt write dir $BASE/$proj"
  exit 1
fi

now=$( date "+%Y-%m-%dT%H:%M" )

( echo "begin dumping to $proj/output.$now" 1>&2 ) > /dev/null
cd $BASE/$proj

  rm -f workpipe
  mknod workpipe p
  cat workpipe | spit_mitm_chunks &
  sleep 1

  mitmdump.sh -p $PROXYPORT -w workpipe
cd -
( echo "end dumping to $proj/output.$now" 1>&2 ) > /dev/null

exit 0

