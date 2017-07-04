#!/bin/bash

cat |\
  tr '[:upper:]' '[:lower:]' |\
  tr 'ÄÅÆÈÉÖØ' 'äåæèéöø' |\
  sed -e 's/__deleted__/__DELETED__/;' |\
  cat

# cat ../step1/tmp.01 | perl -e 'do {$_=<>; printf tolower($_)."\n";} while("x".$_ != "x");' > tmp.02
