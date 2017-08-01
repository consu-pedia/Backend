#!/bin/bash
# Copyright © Consupedia AB 2017
# Author: Frits Daalmans <frits@consupedia.com>

# The original DB was encoded as low-endian UTF-16, I installed
# GNU recode to convert it as follows:
# recode UTF-16..UTF-8 < in > out

# ASSUMPTION first [] is for field name (and table name), change those to backtics
# ASSUMPTION second [] translate field types

cat |\
  tr -d '\r' |\
  sed -e 's/^USE \[dbTGSAnalysTest\]/USE \[consunews\]/;' |\
  sed -e 's/SET ANSI_NULLS ON//' |\
  sed -e 's/SET QUOTED_IDENTIFIER ON//' |\
  sed -e 's/\[dbo\]\.\[/\[/g;' |\
  sed -e 's/CREATE TABLE \(\[[^]]*\)\]/DROP TABLE IF EXISTS \1\];\
CREATE TABLE \1\] /;' |\
  sed -e 's/\[/`/; s/\]/`/;' |\
  sed -e 's/\(WITH.*STATISTICS_NORECOMPUTE.*$\)/ \/* \1 *\//' |\
  sed -e 's/^)\( ON .*$\)/); \/* \1 *\/\
/' |\
  sed -e 's/\[varchar\]/VARCHAR /g; s/\[int\]/INT /g; s/\[real\]/DOUBLE /g; s/\[date\]/DATE /g; s/\[bit\]/TINYINT /g' |\
  awk -f convert_insert_lines.awk |\
  awk '/^INSERT/ {if(p!="GO"){p=p ";"}} /^GO[;]*$/ {plastchar=substr(p,length(p),1);if (plastchar == ")"){ p=p ";"; printf("DBG pre-go p %s lastchar %s\n",p,plastchar) > "/dev/null";}} {print p;p=$0;} END {print p;}' |\
  awk '/^ALTER TABLE/ {printf("PLEASE EDIT NEXT LINE MANUALLY\n");} {print;}' |\
  sed 's/`Article`/`articles`/g;s/`Batchentry`/`batchentries`/g;s/`Keyword`/`keywords`/g;s/`Keywordarticle`/`keyword_article`/g;s/`Keywordsearch`/`keyword_search`/g;s/`Search`/`searches`/g;s/`Searchresult`/`searchresults`/g;s/`Sitetable`/`newssites`/g;' |\
  cat

exit 0
# reserved for error messages

