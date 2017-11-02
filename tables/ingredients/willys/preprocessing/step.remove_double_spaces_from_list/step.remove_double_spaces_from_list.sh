#!/bin/bash

cat |\
  sed -e 's/  */ /g' |\
  cat

exit 0

