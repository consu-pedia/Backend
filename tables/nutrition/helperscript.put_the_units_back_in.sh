#!/bin/bash

# if you do a SQL SELECT from "outside" the DB, like this:
# echo 'SELECT * from temporarynuts2' | mysql -u root -p nutwork
# then the output is in a TAB separated value format, which is much
# easier to manipulate!


cat |\
  awk -F'	' '{\
           id=$1;\
           u=$4;\
           st=$8;\
           stiu=$9;\
           
           replacedit = gsub("__UNIT__", u, stiu); \
           if (replacedit == 0){\
             stiu = st;\
           }\

# printf("DBG id=%d u=<%s> st=<%s> stiu=<%s>\n",id,u,st,stiu);\
           printf("UPDATE temporarynuts2 SET scantemplateincludingunits = \"%s\" WHERE id = %d;\n", stiu, id); \
           }' |\
  cat
