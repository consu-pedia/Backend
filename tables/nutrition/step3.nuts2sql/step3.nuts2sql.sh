#!/bin/bash
# convert tmp.nuts to an SQL table (intermediate form, not what we
# really want)

if [ "$OUTDIR" = "" ]; then OUTDIR="."; fi

cat > $OUTDIR/tmp.placeholder

cat << TMPL > $OUTDIR/tmp.nuts.sql
DROP TABLE temporarynuts;
CREATE TABLE temporarynuts (
  id int(11) NOT NULL,
  textincludingunits varchar(255) NOT NULL,
  template varchar(255) NOT NULL,
  unittext varchar(255),
)

DELETE FROM temporarynuts;
TMPL

cat $OUTDIR/tmp.nuts |\
  awk '{\
        unit=$3" "$4" "$5" "$6;\
        printf("INSERT INTO temporarynuts SET id=%d, textincludingunits=\"%s\", template=\"%s\", unittext=\"%s\";\n", NR, $0, $0, unit);\
      }' |\
  cat >> $OUTDIR/tmp.nuts.sql

echo 'manually edit SQL file tmp.nuts.sql to update temporarynuts.sql' > $OUTDIR/WARNING.300


cat $OUTDIR/tmp.placeholder
