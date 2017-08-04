/* use "SHOW COLLATION;" command to find a case-insensitive UTF-8 Basic Multilingual Plane collation 
N.B. only found utf8_bin
N.B. !!! you can use bin for the EQUAL comparison of a JOIN and then something else for sorting the results!
*/
SELECT a.id, a.textincludingunits, a.template, a.unittext, b.id, c.id, c.nvalues, c.scantemplate, c.scantemplate FROM temporarynuts a LEFT OUTER JOIN ( units b, nutritionscantemplates c) ON ( a.unittext = b.unitname COLLATE utf8_bin AND a.template = c.template COLLATE utf8_bin ) LIMIT 10;
