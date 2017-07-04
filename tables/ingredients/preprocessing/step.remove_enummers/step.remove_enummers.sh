#!/bin/bash

# N.B. the marker bytes are U+001F

# line 2 protects E-numbers
cat |\
  sed -e 's?\(^\|[^a-z]\)e *\([1-9][0-9][0-9]\)\($\|[^0-9a-z]\)? ENUMMER_\2_ENUMMER ?g;' |\
  cat
