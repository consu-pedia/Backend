#!/bin/bash
# very primitive import script.
# tries to fix an error in raw coop input where there are multiple
# "record close" braces on subsequent lines.

workdir=/home/frits/github/git/Backend/Backend/tables/ingredients/coop201712
inputdir=/home/frits/20171115.coop_products/GLUE


hier=$(pwd)

if [ ! "$hier" = "$workdir" ]; then echo "ERROR run from $workdir"; exit 1; fi

if [ -f inp ]; then mv -v inp inp.old; fi

if [ ! -d "$inputdir" ]; then echo "ERROR input dir $inputdir must contain file inp that is the concatenated coop201712 study.123 files"; exit 1; fi

cat $inputdir/inp |\
  sed -z -e 's/            },\n            },/# RECORD END REPAIRED\n            },/g' |\
  cat > $workdir/inp

exit 0

