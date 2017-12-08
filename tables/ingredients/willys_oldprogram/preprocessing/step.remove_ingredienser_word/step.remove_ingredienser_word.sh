#!/bin/bash


cat |\
  sed -e 's/^ *ingredienser:*  *//' |\
  cat

exit 0


