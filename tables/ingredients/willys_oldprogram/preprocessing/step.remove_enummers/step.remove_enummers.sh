#!/bin/bash

# TODO parse

cat |\
  sed -e 's/ENUMMER_\([^_]*\)_ENUMMER/ E\1 /g;' |\
  sed -e 's/^  *//;s/  *$//;s/  */ /g;' |\
  cat


exit 0

