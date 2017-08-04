SELECT a.id, a.textincludingunits, a.template, a.unittext, b.id FROM temporarynuts a LEFT OUTER JOIN units b ON a.unittext = b.unitname LIMIT 10;
