#!/bin/bash

cat |\
  tr -d '()*\047' |\
  cat

exit 0

