#!/bin/bash

cat |\
  grep '"ingredients" : "' |\
  awk -F'"' '{OFS="\"";printf("%s",$4);for(w=5;w<=NF-1;w++){printf("\"%s",$(w));};printf("\n");}' |\
  cat


exit 0

