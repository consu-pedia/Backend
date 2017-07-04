#!/bin/bash

cat |\
  tr -d '()*' |\
  cat

exit 0

