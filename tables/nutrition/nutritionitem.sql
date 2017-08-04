DROP TABLE IF EXISTS nutritionitems;
CREATE TABLE nutritionitems (
  id int(11) NOT NULL,
  name varchar(255),
  url varchar(255)
) DEFAULT CHARSET=utf8;


INSERT INTO nutritionitems SET id =  1, name= "", url= NULL;
INSERT INTO nutritionitems SET id =  2, name= "__DELETED__", url= NULL;
INSERT INTO nutritionitems SET id =  3, name= "Pantotensyra (Vitamin B5)", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/vitaminer-och-antioxidanter/pantotensyra";
INSERT INTO nutritionitems SET id =  4, name= "Riboflavin (Vitamin B2)", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/vitaminer-och-antioxidanter/riboflavin";
INSERT INTO nutritionitems SET id =  5, name= "Tiamin (Vitamin B1)", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/vitaminer-och-antioxidanter/tiamin";
INSERT INTO nutritionitems SET id =  6, name= "Biotin (Vitamin B7)", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/vitaminer-och-antioxidanter/biotin";
INSERT INTO nutritionitems SET id =  7, name= "Energi", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/energi-kalorier";
INSERT INTO nutritionitems SET id =  8, name= "Enkelomättat fett", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/fett/enkelomattat-fett";
INSERT INTO nutritionitems SET id =  9, name= "Fett", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/fett";
INSERT INTO nutritionitems SET id = 10, name= "Fibrer", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/fibrer";
INSERT INTO nutritionitems SET id = 11, name= "Fleromättat fett", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/fett/fleromattat-fett-omega-3-och-omega-6";
INSERT INTO nutritionitems SET id = 12, name= "Fluorid", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/salt-och-mineraler1/fluor";
INSERT INTO nutritionitems SET id = 13, name= "Folsyra", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/vitaminer-och-antioxidanter/folat";
INSERT INTO nutritionitems SET id = 14, name= "Fosfor", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/salt-och-mineraler1/fosfor";
INSERT INTO nutritionitems SET id = 15, name= "Järn", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/salt-och-mineraler1/jarn";
INSERT INTO nutritionitems SET id = 16, name= "Jod", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/salt-och-mineraler1/jod";
INSERT INTO nutritionitems SET id = 17, name= "Kalcium", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/salt-och-mineraler1/kalcium";
INSERT INTO nutritionitems SET id = 18, name= "Kalium", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/salt-och-mineraler1/kalium";
INSERT INTO nutritionitems SET id = 19, name= "Klorid", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/salt-och-mineraler1/natrium";
INSERT INTO nutritionitems SET id = 20, name= "Kolhydrater", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/kolhydrater";
INSERT INTO nutritionitems SET id = 21, name= "Koppar", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/salt-och-mineraler1/koppar";
INSERT INTO nutritionitems SET id = 22, name= "Krom", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/salt-och-mineraler1/krom";
INSERT INTO nutritionitems SET id = 23, name= "Laktos";
INSERT INTO nutritionitems SET id = 24, name= "Magnesium", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/salt-och-mineraler1/magnesium";
INSERT INTO nutritionitems SET id = 25, name= "Mangan", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/salt-och-mineraler1/mangan";
INSERT INTO nutritionitems SET id = 26, name= "Mättat fett", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/fett/mattat-fett";
INSERT INTO nutritionitems SET id = 27, name= "Molybden", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/salt-och-mineraler1/molybden";
INSERT INTO nutritionitems SET id = 28, name= "Natrium", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/salt-och-mineraler1/natrium";
INSERT INTO nutritionitems SET id = 29, name= "Niacin", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/vitaminer-och-antioxidanter/niacin";
INSERT INTO nutritionitems SET id = 30, name= "Polyoler";
INSERT INTO nutritionitems SET id = 31, name= "Protein", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/protein";
INSERT INTO nutritionitems SET id = 32, name= "Salt", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/salt-och-mineraler1/natrium";
INSERT INTO nutritionitems SET id = 33, name= "Selen", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/salt-och-mineraler1/selen";
INSERT INTO nutritionitems SET id = 34, name= "Sockerarter", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/kolhydrater/socker";
INSERT INTO nutritionitems SET id = 35, name= "Stärkelse";
INSERT INTO nutritionitems SET id = 36, name= "Vitamin A", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/vitaminer-och-antioxidanter/vitamin-a";
INSERT INTO nutritionitems SET id = 37, name= "Vitamin B12", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/vitaminer-och-antioxidanter/vitamin-b12";
INSERT INTO nutritionitems SET id = 38, name= "Vitamin B6", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/vitaminer-och-antioxidanter/vitamin-b6";
INSERT INTO nutritionitems SET id = 39, name= "Vitamin C", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/vitaminer-och-antioxidanter/vitamin-c";
INSERT INTO nutritionitems SET id = 40, name= "Vitamin D", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/vitaminer-och-antioxidanter/vitamin-d";
INSERT INTO nutritionitems SET id = 41, name= "Vitamin E", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/vitaminer-och-antioxidanter/vitamin-e";
INSERT INTO nutritionitems SET id = 42, name= "Vitamin K", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/vitaminer-och-antioxidanter/vitamin-k";
INSERT INTO nutritionitems SET id = 43, name= "Zink", url= "https://www.livsmedelsverket.se/livsmedel-och-innehall/naringsamne/salt-och-mineraler1/zink";
