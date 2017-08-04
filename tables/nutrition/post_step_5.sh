#!/bin/bash
if [ ! -f out.500 ]; then echo need out.500; exit 1; fi
grep PFUNC out.500 > work.02
head -n 1  work.02

nl work.02 | sed -e 's/	PFUNC/, product_id = /' > work.03
head -n 1  work.03

cat work.03 |sed -e 's/\x1f/, rank = /' > work.04
head -n 1  work.04

cat work.04 |sed -e 's/\x1f/, rawinput = \"/' > work.05
head -n 1  work.05

cat work.05 |sed -e 's/\x1f/\", unit_id = /' > work.06
head -n 1  work.06

cat work.06 |sed -e 's/\x1f/, nvalues = /' > work.07
head -n 1  work.07

cat work.07 |sed -e 's/\x1f/, scantemplate = \"/' > work.08
head -n 1  work.08

cat work.08 |sed -e 's/\x1f/\", value1 = /' > work.09
head -n 1  work.09

cat work.09 |sed -e 's/\x1f/, value2 = /' > work.10
head -n 1  work.10

cat work.10 |sed -e 's/$/;/;s/^ */INSERT INTO worktable1 SET id = /' > work.11
head -n 1  work.11

cat work.11 |grep -v 'PARSE ERROR' > work.12
cat work.11 |grep 'PARSE ERROR' > work.13

exit 0


