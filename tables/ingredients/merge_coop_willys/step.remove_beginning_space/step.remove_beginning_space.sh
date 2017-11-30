#!/bin/bash

cat |\
  sed -e 's/^ //;s/ *$//' |\
  cat

exit 0


