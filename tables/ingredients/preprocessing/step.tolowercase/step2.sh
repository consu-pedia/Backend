#!/bin/bash

cat |\
  tr '[:upper:]' '[:lower:]' |\
  tr 'ÄÅÆÈÉÖØ' 'äåæèéöø' |\
  cat

# cat ../step1/tmp.01 | perl -e 'do {$_=<>; printf tolower($_)."\n";} while("x".$_ != "x");' > tmp.02
