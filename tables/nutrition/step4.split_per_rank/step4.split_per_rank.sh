#!/bin/bash
# input: one-record-per-line, 0x1f separated
#     0 => 'Energi 2301 Kilojoule',    1 => 'Energi 553 Kilokalori',    2 => 'Fett 35 Gram',    3 => 'Varav mättat fett 18 Gram',    4 => 'Kolhydrat 50 Gram',    5 => 'Varav sockerarter 47 Gram',    6 => 'Protein 7.30 Gram',    7 => 'Salt 0.16 Gram',
# output: linenr, ranknr, ranktext 0x1f separated 

if [ "$OUTDIR" = "" ]; then OUTDIR="."; fi

cat |\
  awk -F"" '{for(i=1;i<=NF;i++){printf("%d%c%d%c%s\n", NR, 0x1f, i, 0x1f, $(i));}}' |\
  cat

exit 0

