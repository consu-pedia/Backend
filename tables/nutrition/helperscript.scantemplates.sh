#!/bin/bash
# helper script to transform temporarynuts table to nutritionscantemplates table.
# 3 forms: 0-value, 1-value and 2-value.


cat |\
  awk '{\
        nvalues=0;\
        template = $0;\
        scantemplate = template;\
        hasrange=gsub("__QUANTITY_RANGE__", "%f|PIM_MULTIVALUE_SEPARATOR|%f", scantemplate);\
        if (hasrange==1){\
          nvalues=2;\
        } else {\
          has1quant=gsub("__QUANTITY__", "%f", scantemplate);\
          if (has1quant==1){\
            nvalues=1;\
          }\
        }\
        printf("INSERT INTO nutritionscantemplates SET id=%d, template=\"%s\", nvalues=%d, scantemplate=\"%s\";\n", NR, template, nvalues, scantemplate); \
      }' |\
  cat


exit 0
