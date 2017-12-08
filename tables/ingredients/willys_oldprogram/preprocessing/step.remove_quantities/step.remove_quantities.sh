#!/bin/bash

# first version: don't parse just remove

cat |\
  sed -e 's/QUANT_[^]*/ /g;' |\
  sed -e 's/UNITFRAC[^]*/ /g;' |\
  sed -e 's/UNIT[^]*/ /g;' |\
  sed -e 's/  / /g' |\
  cat

exit 0

