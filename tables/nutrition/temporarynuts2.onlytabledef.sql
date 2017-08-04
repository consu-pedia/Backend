DROP TABLE IF EXISTS temporarynuts2;
CREATE TABLE temporarynuts2 (
  id int(11) NOT NULL,
  textincludingunits varchar(255) NOT NULL,
  template varchar(255) NOT NULL,
  unittext varchar(255),
  unit_id int(11) NOT NULL,
  scantemplate_id int(11) NOT NULL,
  nvalues int(2),
  scantemplate varchar(255),
  scantemplateincludingunits varchar(255)
) DEFAULT CHARSET=utf8;

