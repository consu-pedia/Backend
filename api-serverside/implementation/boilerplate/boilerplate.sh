#!/bin/bash
# script to generate boilerplate Golang 
# Copyright © 2017 Consupedia AB
# Author: Frits Daalmans <frits@consupedia.com>

if [ ! -f tablelist.txt ]; then
  echo "boilerplate.sh: ERROR could not find tablelist.txt, generate that first"
  exit 1
fi

if [ ! -f login.sh ]; then
  echo "boilerplate.sh: ERROR you should write a 1-line script login.sh that connects to mysql, e.g."
 echo "mysql -u root -h 10.60.218.987 -pmickeymouse consuweb"
  exit 1
fi

if [ $# -ne 1 ]; then
  echo "Usage: boilerplate.sh <dbname>"
  exit 1
fi
dbname="$1"

echo "begin login.sh test with dbname = $dbname"
echo "SHOW DATABASES" | ./login.sh  > tmp.boil.db
echo "end login.sh test with dbname = $dbname"
worked=$( cat tmp.boil.db |grep -c '^'"$dbname"'$' )
if [ $worked -ne 1 ]; then
  echo "ERROR: dbname $dbname not found on server"
  cat login.sh
  cat tmp.boil.db
  exit 1
fi
rm -f tmp.boil.db

now=$( date "+%Y-%m-%dT%H:%M:%S" )
echo |tee -a errors.log
echo |tee -a errors.log
echo "$now Begin creating boilerplate code for DB $dbname" |tee -a errors.log
echo |tee -a errors.log

for t in $( cat tablelist.txt ); do
  tblf="out/$t"".sql"
  if [ -f "$tblf" ]; then echo "skip $tblf exists"; else
    ./gen_tablelist.sh "$dbname" "$t"
  fi
done

now=$( date "+%Y-%m-%dT%H:%M:%S" )
echo "$now End creating boilerplate code for DB $dbname" |tee -a errors.log

exit 0

