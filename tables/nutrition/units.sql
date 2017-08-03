DROP TABLE units;
CREATE TABLE units (
  id int(11) NOT NULL,
  unit varchar(255) NOT NULL,
)


DELETE FROM units;
INSERT INTO units SET id=1, unit="";
INSERT INTO units SET id=2, unit="µg";
INSERT INTO units SET id=3, unit="g";
INSERT INTO units SET id=4, unit="gram";
INSERT INTO units SET id=5, unit="Gram";
INSERT INTO units SET id=6, unit="kcal";
INSERT INTO units SET id=7, unit="kilojoule";
INSERT INTO units SET id=8, unit="Kilojoule";
INSERT INTO units SET id=9, unit="Kilokalori";
INSERT INTO units SET id=10, unit="kilokalorier";
INSERT INTO units SET id=11, unit="kJ";
INSERT INTO units SET id=12, unit="mg";
INSERT INTO units SET id=13, unit="Mikrogram";
INSERT INTO units SET id=14, unit="Milligram";
