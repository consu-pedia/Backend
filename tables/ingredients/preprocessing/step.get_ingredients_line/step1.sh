#!/bin/bash

cat |\
  awk 'BEGIN {c=3;} \
       {c++; 
#print c" "$0; 
        if (c==2) { print $0; } \
       } \
       /.Content. =>/ { c=0; }\
      ' |\
  cat

exit 0

