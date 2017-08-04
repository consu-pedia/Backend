/* use "SHOW COLLATION;" command to find a case-insensitive UTF-8 Basic Multilingual Plane collation 
N.B. only found utf8_bin
N.B. !!! you can use bin for the EQUAL comparison of a JOIN and then something else for sorting the results!
*/
SELECT a.id, a.textincludingunits, a.template, a.unittext, b.id FROM temporarynuts a LEFT OUTER JOIN units b ON a.unittext = b.unitname COLLATE utf8_bin LIMIT 10;
