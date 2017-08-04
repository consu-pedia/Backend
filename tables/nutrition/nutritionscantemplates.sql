/* This table has to be manually generated from temporarynuts.sql.
 * Sorry.
 */

DROP TABLE nutritionscantemplates;
CREATE TABLE nutritionscantemplates (
  id int(11) NOT NULL,
  template varchar(255) NOT NULL,
  nvalues int(2),
  scantemplate varchar(255) NOT NULL
)

DELETE FROM nutritionscantemplates;
INSERT INTO nutritionscantemplates SET id=1, template="*Dagligt Referensintag  ", nvalues=0, scantemplate="*Dagligt Referensintag  ";
INSERT INTO nutritionscantemplates SET id=2, template="*Dagligt Referens Intag  ", nvalues=0, scantemplate="*Dagligt Referens Intag  ";
INSERT INTO nutritionscantemplates SET id=3, template="__DELETED__", nvalues=0, scantemplate="__DELETED__";
INSERT INTO nutritionscantemplates SET id=4, template="Salt", nvalues=0, scantemplate="Salt";
INSERT INTO nutritionscantemplates SET id=5, template="Salt <0", nvalues=0, scantemplate="Salt <0";
INSERT INTO nutritionscantemplates SET id=6, template="Varav sockerarter", nvalues=0, scantemplate="Varav sockerarter";
INSERT INTO nutritionscantemplates SET id=7, template="varav sockerarter2", nvalues=0, scantemplate="varav sockerarter2";
INSERT INTO nutritionscantemplates SET id=8, template="__QUANTITY____UNIT__ (11 % av DRI)  ", nvalues=1, scantemplate="%f__UNIT__ (11 % av DRI)  ";
INSERT INTO nutritionscantemplates SET id=9, template="__QUANTITY____UNIT__.  ", nvalues=1, scantemplate="%f__UNIT__.  ";
INSERT INTO nutritionscantemplates SET id=10, template="__QUANTITY__ __UNIT__  ", nvalues=1, scantemplate="%f __UNIT__  ";
INSERT INTO nutritionscantemplates SET id=11, template="__QUANTITY____UNIT__  ", nvalues=1, scantemplate="%f__UNIT__  ";
INSERT INTO nutritionscantemplates SET id=12, template=" används ej __QUANTITY__ __UNIT__", nvalues=1, scantemplate=" används ej %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=13, template="Biotin __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Biotin %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=14, template="CHO- __QUANTITY__ __UNIT__", nvalues=1, scantemplate="CHO- %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=15, template="Energi __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Energi %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=16, template="energi __QUANTITY__ __UNIT__", nvalues=1, scantemplate="energi %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=17, template="Energivärde: __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Energivärde: %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=18, template="Fett__QUANTITY__ __UNIT__  ", nvalues=1, scantemplate="Fett%f __UNIT__  ";
INSERT INTO nutritionscantemplates SET id=19, template="Fett __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Fett %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=20, template="Fett __QUANTITY____UNIT__  ", nvalues=1, scantemplate="Fett %f__UNIT__  ";
INSERT INTO nutritionscantemplates SET id=21, template="fett __QUANTITY__ __UNIT__", nvalues=1, scantemplate="fett %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=22, template="Fiber __QUANTITY____UNIT__  ", nvalues=1, scantemplate="Fiber %f__UNIT__  ";
INSERT INTO nutritionscantemplates SET id=23, template="fiber __QUANTITY__ __UNIT__", nvalues=1, scantemplate="fiber %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=24, template="Fiber __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Fiber %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=25, template="fleromättat fett __QUANTITY__ __UNIT__", nvalues=1, scantemplate="fleromättat fett %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=26, template="Fluorid __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Fluorid %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=27, template="Folsyra __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Folsyra %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=28, template="Fosfor __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Fosfor %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=29, template="Järn __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Järn %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=30, template="Jod __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Jod %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=31, template="Jordgubb/VaniljEnergi __QUANTITY__ __UNIT__/80", nvalues=1, scantemplate="Jordgubb/VaniljEnergi %f __UNIT__/80";
INSERT INTO nutritionscantemplates SET id=32, template="Kalcium __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Kalcium %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=33, template="Kalium __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Kalium %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=34, template="Klorid __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Klorid %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=35, template="Kolhydrat__QUANTITY__ __UNIT__  ", nvalues=1, scantemplate="Kolhydrat%f __UNIT__  ";
INSERT INTO nutritionscantemplates SET id=36, template="Kolhydrater __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Kolhydrater %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=37, template="Kolhydrater __QUANTITY____UNIT__  ", nvalues=1, scantemplate="Kolhydrater %f__UNIT__  ";
INSERT INTO nutritionscantemplates SET id=38, template="Kolhydrat __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Kolhydrat %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=39, template="kolhydrat __QUANTITY__ __UNIT__", nvalues=1, scantemplate="kolhydrat %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=40, template="Koppar __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Koppar %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=41, template="Krom __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Krom %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=42, template="Magnesium __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Magnesium %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=43, template="Mangan __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Mangan %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=44, template="Molybden __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Molybden %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=45, template="NACL __QUANTITY__ __UNIT__", nvalues=1, scantemplate="NACL %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=46, template="Natrium __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Natrium %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=47, template="Niacin __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Niacin %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=48, template="Pantotensyra __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Pantotensyra %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=49, template="Protein __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Protein %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=50, template="Protein __QUANTITY____UNIT__  ", nvalues=1, scantemplate="Protein %f__UNIT__  ";
INSERT INTO nutritionscantemplates SET id=51, template="protein __QUANTITY__ __UNIT__", nvalues=1, scantemplate="protein %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=52, template="Riboflavin __QUANTITY__", nvalues=1, scantemplate="Riboflavin %f";
INSERT INTO nutritionscantemplates SET id=53, template="Riboflavin __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Riboflavin %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=54, template="Salt __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Salt %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=55, template="Salt __QUANTITY____UNIT__  ", nvalues=1, scantemplate="Salt %f__UNIT__  ";
INSERT INTO nutritionscantemplates SET id=56, template="salt __QUANTITY__ __UNIT__", nvalues=1, scantemplate="salt %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=57, template="Selen __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Selen %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=58, template="Tiamin __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Tiamin %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=59, template="varav enkelomättat fett __QUANTITY__ __UNIT__", nvalues=1, scantemplate="varav enkelomättat fett %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=60, template="Varav enkelomättat fett __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Varav enkelomättat fett %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=61, template="varav fleromättat fett __QUANTITY__ __UNIT__", nvalues=1, scantemplate="varav fleromättat fett %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=62, template="Varav fleromättat fett __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Varav fleromättat fett %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=63, template="varav laktos __QUANTITY__ __UNIT__", nvalues=1, scantemplate="varav laktos %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=64, template="varav mättat fett __QUANTITY__ __UNIT__", nvalues=1, scantemplate="varav mättat fett %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=65, template="varav: Mättat fett __QUANTITY____UNIT__  ", nvalues=1, scantemplate="varav: Mättat fett %f__UNIT__  ";
INSERT INTO nutritionscantemplates SET id=66, template="Varav mättat fett __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Varav mättat fett %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=67, template="varav polyoler __QUANTITY__ __UNIT__", nvalues=1, scantemplate="varav polyoler %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=68, template="Varav polyoler __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Varav polyoler %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=69, template="varav sockerarter __QUANTITY__", nvalues=1, scantemplate="varav sockerarter %f";
INSERT INTO nutritionscantemplates SET id=70, template="varav sockerarter __QUANTITY__ __UNIT__", nvalues=1, scantemplate="varav sockerarter %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=71, template="varav: Sockerarter __QUANTITY____UNIT__  ", nvalues=1, scantemplate="varav: Sockerarter %f__UNIT__  ";
INSERT INTO nutritionscantemplates SET id=72, template="Varav sockerarter __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Varav sockerarter %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=73, template="varav sockerater __QUANTITY__ __UNIT__", nvalues=1, scantemplate="varav sockerater %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=74, template="Varav stärkelse __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Varav stärkelse %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=75, template="Vitamin A__QUANTITY__ __UNIT__ (39% av DRI*) *Dagligt Referensintag  ", nvalues=1, scantemplate="Vitamin A%f __UNIT__ (39% av DRI*) *Dagligt Referensintag  ";
INSERT INTO nutritionscantemplates SET id=76, template="Vitamin A __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Vitamin A %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=77, template="Vitamin B12 __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Vitamin B12 %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=78, template="Vitamin B6 __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Vitamin B6 %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=79, template="Vitamin C __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Vitamin C %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=80, template="Vitamin D __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Vitamin D %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=81, template="Vitamin E __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Vitamin E %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=82, template="Vitamin K __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Vitamin K %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=83, template="Zink __QUANTITY__ __UNIT__", nvalues=1, scantemplate="Zink %f __UNIT__";
INSERT INTO nutritionscantemplates SET id=84, template="Energi __QUANTITY_RANGE__ __UNIT__", nvalues=2, scantemplate="Energi %f|PIM_MULTIVALUE_SEPARATOR|%f __UNIT__";
