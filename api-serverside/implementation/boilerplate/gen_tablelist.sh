#!/bin/bash
# helper script to generate boilerplate Golang 
# Copyright © 2017 Consupedia AB
# Author: Frits Daalmans <frits@consupedia.com>

if [ ! -f tablelist.txt ]; then
  echo "boilerplate.sh: ERROR could not find tablelist.txt, generate that first"
  exit 1
fi

dbname="$1"
tblname="$2"
logincmd=$( cat ./login.sh )
sqlfile=out/"$tblname".sql
jsonexportfile1=tmp.boilerplate.json1
jsonexportfile2=tmp.boilerplate.json2
jsonexportfile=out/"$tblname".jsonexport.go
jsondbfile1=tmp.boilerplate.db1
jsondbfile2=tmp.boilerplate.db2
jsondbfile3=tmp.boilerplate.db3
jsondbfile4=tmp.boilerplate.db4
jsondbfile5=tmp.boilerplate.db5
jsondbfile=out/"$tblname".db.go

mkdir -p out

echo "DBG: gen_tablelist.sh $dbname $tblname"

echo "DESC $tblname" | $logincmd > $sqlfile

if [ ! -s $sqlfile ]; then
  echo "ERROR doing desc $tblname" | tee -a errors.log
  exit 1
fi

nflds=$( cat $sqlfile | wc -l )
nflds=$(( $nflds - 1 ))
# sql to JSON struct

structname="$tblname""struct"
scanfuncname="Scan_""$dbname""_""$tblname"

cat << TMPL00 > $jsonexportfile1
package $dbname

import (
"encoding/json"
TMPL00

cat << TMPL01 > $jsondbfile1
package $dbname

import (
"encoding/json"
"database/sql"
_ "github.com/go-sql-driver/mysql"
TMPL01


cat << TMPL02 > $jsonexportfile2
// Generated boilerplate code for MySQL DB $dbname table $tblname
type $structname struct {
TMPL02

cat << TMPL03 > $jsondbfile2
// Generated boilerplate code for MySQL DB $dbname table $tblname
func $scanfuncname(rows *sql.Rows) (c $structname, err error) {
TMPL03

echo "" > $jsondbfile3
echo -n "err = rows.Scan(" >> $jsondbfile3

echo "" > $jsondbfile4

has_time_fields=0
has_enums=0

cat << TMPL04 > $jsondbfile5

// now assemble
c = $structname{
Type: "$tblname",
TMPL04

for fldi in $( seq 1 $nflds ); do
  fldip1=$(( $fldi + 1 ))
  sqll=$( cat $sqlfile | head -n $fldip1 | tail -n 1 )
  echo "// $sqll" | tee -a $jsonexportfile2

  fldname=$( echo "$sqll" |cut -d'	' -f1 )
  fldtype=$( echo "$sqll" |cut -d'	' -f2 )
  fldnull=$( echo "$sqll" |cut -d'	' -f3 )

  jsonfldname=$( echo "$fldname" )
  jsonfldtype=$( echo "_UNPARSED_$fldtype" )
  jsonnullok=""
  
  use_holder=0
  dbholderfldname="$dbname""_""$tblname""_""$fldname""_""Holder"
  dbfldname="$dbname""_""$tblname""_""$fldname"
  dbfldtype=$( echo "_UNPARSED_$fldtype" )
  if [ "$fldnull" = "YES" ]; then
    jsonnullok=",omitempty"
    use_holder=1
  fi


  fldtypetmpl=$( echo "$fldtype" | sed -e 's/([0-9][0-9]*,[0-9][0-9]*)/(Y,Z)/g;s/([0-9][0-9]*)/(X)/g;s/enum([^)]*)/enum(TODO)/' )

  case "$fldtypetmpl" in
"int(X) unsigned")
  jsonfldtype="int"
  dbfldtype="int"
  ;;
"int(X)")
  jsonfldtype="int"
  dbfldtype="int"
  ;;
"varchar(X)")
  jsonfldtype="string"
  dbfldtype="string"
  ;;
"decimal(Y,Z) unsigned")
  jsonfldtype="int"
  dbfldtype="int"
  ;;
"tinyint(X)")
  jsonfldtype="int"
  dbfldtype="int"
  ;;
"text")
  jsonfldtype="string"
  dbfldtype="string"
  ;;
"timestamp")
  jsonfldtype="*time.Time"
  has_time_fields=1
  dbfldtype="time"
  use_holder=1
  ;;
"date")
  jsonfldtype="*time.Time"
  has_time_fields=1
  dbfldtype="time"
  use_holder=1
  ;;

"enum(TODO)")
  jsonfldtype="string"
  echo "// TODO $sqll" | tee -a $jsonexportfile2
  has_enums=1
  ;;

*)
  echo "ERROR json generator: UNDEFINED fldtype template \"$fldtypetmpl\"" | tee -a errors.log
  ;;
  esac

  echo "$jsonfldname	$jsonfldtype	\`json:\"$fldname$jsonnullok\"\`	// type = $fldtype" | tee -a $jsonexportfile2

  echo >> $jsondbfile4

  if [ $use_holder -eq 1 ]; then
    echo "var $dbholderfldname interface{} = nil" | tee -a $jsondbfile2
    echo "var $dbfldname $jsonfldtype" | tee -a $jsondbfile2
  else # use_holder
    echo "var $dbfldname $jsonfldtype" | tee -a $jsondbfile2
  fi # use_holder

  if [ $fldi -gt 1 ]; then
    echo -n ", " >> $jsondbfile3
    echo -n ", " >> $jsondbfile5
  fi
  if [ $use_holder -eq 1 ]; then
    echo -n "&""$dbholderfldname" >> $jsondbfile3
  else
    echo -n "&""$dbfldname" >> $jsondbfile3
  fi

  echo -n "$jsonfldname: $dbfldname" >> $jsondbfile5


  case "$dbfldtype" in
"time")
    echo "$dbfldname, err = Sqltime2Gotime($dbholderfldname)" >> $jsondbfile4
    ;;

"int")
  if [ $use_holder -eq 1 ]; then
    cat << TMPL05 >> $jsondbfile4
if $dbholderfldname != nil {
  $dbfldname, err = strconv.Atoi($dbholderfldname.(string))
  if err != nil { return nil, err }
} else {
  $dbfldname = 0
}
TMPL05
  fi # holder
    ;;

"string")
  if [ $use_holder -eq 1 ]; then
    cat << TMPL06 >> $jsondbfile4
if $dbholderfldname != nil {
  $dbfldname = $dbholderfldname.(string)
} else {
  $dbfldname = ""
}
TMPL06
  fi # holder
    ;;

*)
  echo "ERROR db generator: UNDEFINED fldtype template \"$fldtypetmpl\" dbfldtype $dbfldtype" | tee -a errors.log
echo "ERROR $dbfldtype $dbfldname" >> $jsondbfile4
    ;;
  esac # dbfldtype
  

done # next field $fldi/$sqll




cat << TMPL07 >> $jsonexportfile2
}
// End of generated boilerplate code for MySQL DB $dbname table $tblname

TMPL07

if [ $has_time_fields -gt 0 ]; then
  echo "\"time\"" >> $jsonexportfile1
  echo "\"time\"" >> $jsondbfile1
fi

cat << TMPL08 >> $jsonexportfile1
)

TMPL08

cat << TMPL09 >> $jsondbfile1
)

TMPL09

cat << TMPL10 >> $jsondbfile3
)
if err != nil { return nil, err }

// special handling for some fields
TMPL10

cat << TMPL11 >> $jsondbfile5
}

return c, nil
}
TMPL11

cat $jsonexportfile1 $jsonexportfile2 > $jsonexportfile

go fmt $jsonexportfile

cat $jsondbfile1 $jsondbfile2 $jsondbfile3 $jsondbfile4 $jsondbfile5 > $jsondbfile

go fmt $jsondbfile

exit 0

