-- MySQL dump 10.13  Distrib 5.5.55, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: nutwork
-- ------------------------------------------------------
-- Server version	5.5.55-0+deb8u1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `temporarynuts2`
--

DROP TABLE IF EXISTS `temporarynuts2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `temporarynuts2` (
  `id` int(11) NOT NULL,
  `textincludingunits` varchar(255) NOT NULL,
  `template` varchar(255) NOT NULL,
  `unittext` varchar(255) DEFAULT NULL,
  `unit_id` int(11) NOT NULL,
  `scantemplate_id` int(11) NOT NULL,
  `nvalues` int(2) DEFAULT NULL,
  `scantemplate` varchar(255) DEFAULT NULL,
  `scantemplateincludingunits` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temporarynuts2`
--

LOCK TABLES `temporarynuts2` WRITE;
/*!40000 ALTER TABLE `temporarynuts2` DISABLE KEYS */;
INSERT INTO `temporarynuts2` VALUES (1,'15mg (11 % av DRI)  ','__QUANTITY____UNIT__ (11 % av DRI)  ','mg',12,8,1,'%f__UNIT__ (11 % av DRI)  ','%fmg (11 % av DRI)  '),(2,'1g.  ','__QUANTITY____UNIT__.  ','g',3,9,1,'%f__UNIT__.  ','%fg.  '),(3,'6 g  ','__QUANTITY__ __UNIT__  ','g',3,10,1,'%f __UNIT__  ','%f g  '),(4,'8g  ','__QUANTITY____UNIT__  ','g',3,11,1,'%f__UNIT__  ','%fg  '),(5,' används ej __QUANTITY__ Gram',' används ej __QUANTITY__ __UNIT__','Gram',5,12,1,' används ej %f __UNIT__',' används ej %f Gram'),(6,'Biotin __QUANTITY__ Mikrogram','Biotin __QUANTITY__ __UNIT__','Mikrogram',13,13,1,'Biotin %f __UNIT__','Biotin %f Mikrogram'),(7,'CHO- __QUANTITY__ Gram','CHO- __QUANTITY__ __UNIT__','Gram',5,14,1,'CHO- %f __UNIT__','CHO- %f Gram'),(8,'*Dagligt Referensintag  ','*Dagligt Referensintag  ','',0,0,NULL,NULL,'NULL'),(9,'*Dagligt Referens Intag  ','*Dagligt Referens Intag  ','',0,0,NULL,NULL,'NULL'),(10,'__DELETED__','__DELETED__','',0,0,NULL,NULL,'NULL'),(11,'Energi __QUANTITY__ Gram','Energi __QUANTITY__ __UNIT__','Gram',5,15,1,'Energi %f __UNIT__','Energi %f Gram'),(12,'Energi __QUANTITY__ kcal','Energi __QUANTITY__ __UNIT__','kcal',6,15,1,'Energi %f __UNIT__','Energi %f kcal'),(13,'energi __QUANTITY__ kilojoule','energi __QUANTITY__ __UNIT__','kilojoule',7,16,1,'energi %f __UNIT__','energi %f kilojoule'),(14,'Energi __QUANTITY__ Kilojoule','Energi __QUANTITY__ __UNIT__','Kilojoule',8,15,1,'Energi %f __UNIT__','Energi %f Kilojoule'),(15,'Energi __QUANTITY__ Kilokalori','Energi __QUANTITY__ __UNIT__','Kilokalori',9,15,1,'Energi %f __UNIT__','Energi %f Kilokalori'),(16,'energi __QUANTITY__ kilokalorier','energi __QUANTITY__ __UNIT__','kilokalorier',10,16,1,'energi %f __UNIT__','energi %f kilokalorier'),(17,'Energi __QUANTITY__ kJ','Energi __QUANTITY__ __UNIT__','kJ',11,15,1,'Energi %f __UNIT__','Energi %f kJ'),(18,'Energi __QUANTITY__ Milligram','Energi __QUANTITY__ __UNIT__','Milligram',14,15,1,'Energi %f __UNIT__','Energi %f Milligram'),(19,'Energi __QUANTITY_RANGE__ Kilojoule','Energi __QUANTITY_RANGE__ __UNIT__','Kilojoule',8,84,2,'Energi %f|PIM_MULTIVALUE_SEPARATOR|%f __UNIT__','Energi %f|PIM_MULTIVALUE_SEPARATOR|%f Kilojoule'),(20,'Energi __QUANTITY_RANGE__ Kilokalori','Energi __QUANTITY_RANGE__ __UNIT__','Kilokalori',9,84,2,'Energi %f|PIM_MULTIVALUE_SEPARATOR|%f __UNIT__','Energi %f|PIM_MULTIVALUE_SEPARATOR|%f Kilokalori'),(21,'Energivärde: __QUANTITY__ kcal','Energivärde: __QUANTITY__ __UNIT__','kcal',6,17,1,'Energivärde: %f __UNIT__','Energivärde: %f kcal'),(22,'Energivärde: __QUANTITY__ kJ','Energivärde: __QUANTITY__ __UNIT__','kJ',11,17,1,'Energivärde: %f __UNIT__','Energivärde: %f kJ'),(23,'Fett34 g  ','Fett__QUANTITY__ __UNIT__  ','g',3,18,1,'Fett%f __UNIT__  ','Fett%f g  '),(24,'Fett __QUANTITY__ g','Fett __QUANTITY__ __UNIT__','g',3,19,1,'Fett %f __UNIT__','Fett %f g'),(25,'Fett __QUANTITY__g  ','Fett __QUANTITY____UNIT__  ','g',3,20,1,'Fett %f__UNIT__  ','Fett %fg  '),(26,'fett __QUANTITY__ gram','fett __QUANTITY__ __UNIT__','gram',4,21,1,'fett %f __UNIT__','fett %f gram'),(27,'Fett __QUANTITY__ Gram','Fett __QUANTITY__ __UNIT__','Gram',5,19,1,'Fett %f __UNIT__','Fett %f Gram'),(28,'Fett __QUANTITY__ Kilokalori','Fett __QUANTITY__ __UNIT__','Kilokalori',9,19,1,'Fett %f __UNIT__','Fett %f Kilokalori'),(29,'Fett __QUANTITY__ Mikrogram','Fett __QUANTITY__ __UNIT__','Mikrogram',13,19,1,'Fett %f __UNIT__','Fett %f Mikrogram'),(30,'Fiber __QUANTITY__g  ','Fiber __QUANTITY____UNIT__  ','g',3,22,1,'Fiber %f__UNIT__  ','Fiber %fg  '),(31,'fiber __QUANTITY__ gram','fiber __QUANTITY__ __UNIT__','gram',4,23,1,'fiber %f __UNIT__','fiber %f gram'),(32,'Fiber __QUANTITY__ Gram','Fiber __QUANTITY__ __UNIT__','Gram',5,24,1,'Fiber %f __UNIT__','Fiber %f Gram'),(33,'fleromättat fett __QUANTITY__ g','fleromättat fett __QUANTITY__ __UNIT__','g',3,25,1,'fleromättat fett %f __UNIT__','fleromättat fett %f g'),(34,'Fluorid __QUANTITY__ Milligram','Fluorid __QUANTITY__ __UNIT__','Milligram',14,26,1,'Fluorid %f __UNIT__','Fluorid %f Milligram'),(35,'Folsyra __QUANTITY__ g','Folsyra __QUANTITY__ __UNIT__','g',3,27,1,'Folsyra %f __UNIT__','Folsyra %f g'),(36,'Folsyra __QUANTITY__ Mikrogram','Folsyra __QUANTITY__ __UNIT__','Mikrogram',13,27,1,'Folsyra %f __UNIT__','Folsyra %f Mikrogram'),(37,'Fosfor __QUANTITY__ mg','Fosfor __QUANTITY__ __UNIT__','mg',12,28,1,'Fosfor %f __UNIT__','Fosfor %f mg'),(38,'Fosfor __QUANTITY__ Milligram','Fosfor __QUANTITY__ __UNIT__','Milligram',14,28,1,'Fosfor %f __UNIT__','Fosfor %f Milligram'),(39,'Järn __QUANTITY__ Gram','Järn __QUANTITY__ __UNIT__','Gram',5,29,1,'Järn %f __UNIT__','Järn %f Gram'),(40,'Järn __QUANTITY__ Milligram','Järn __QUANTITY__ __UNIT__','Milligram',14,29,1,'Järn %f __UNIT__','Järn %f Milligram'),(41,'Jod __QUANTITY__ g','Jod __QUANTITY__ __UNIT__','g',3,30,1,'Jod %f __UNIT__','Jod %f g'),(42,'Jod __QUANTITY__ Mikrogram','Jod __QUANTITY__ __UNIT__','Mikrogram',13,30,1,'Jod %f __UNIT__','Jod %f Mikrogram'),(43,'Jod __QUANTITY__ Milligram','Jod __QUANTITY__ __UNIT__','Milligram',14,30,1,'Jod %f __UNIT__','Jod %f Milligram'),(44,'Jordgubb/VaniljEnergi __QUANTITY__ kJ/80','Jordgubb/VaniljEnergi __QUANTITY__ __UNIT__/80','kJ',11,31,1,'Jordgubb/VaniljEnergi %f __UNIT__/80','Jordgubb/VaniljEnergi %f kJ/80'),(45,'Kalcium __QUANTITY__ mg','Kalcium __QUANTITY__ __UNIT__','mg',12,32,1,'Kalcium %f __UNIT__','Kalcium %f mg'),(46,'Kalcium __QUANTITY__ Milligram','Kalcium __QUANTITY__ __UNIT__','Milligram',14,32,1,'Kalcium %f __UNIT__','Kalcium %f Milligram'),(47,'Kalium __QUANTITY__ mg','Kalium __QUANTITY__ __UNIT__','mg',12,33,1,'Kalium %f __UNIT__','Kalium %f mg'),(48,'Kalium __QUANTITY__ Milligram','Kalium __QUANTITY__ __UNIT__','Milligram',14,33,1,'Kalium %f __UNIT__','Kalium %f Milligram'),(49,'Klorid __QUANTITY__ mg','Klorid __QUANTITY__ __UNIT__','mg',12,34,1,'Klorid %f __UNIT__','Klorid %f mg'),(50,'Klorid __QUANTITY__ Milligram','Klorid __QUANTITY__ __UNIT__','Milligram',14,34,1,'Klorid %f __UNIT__','Klorid %f Milligram'),(51,'Kolhydrat11 g  ','Kolhydrat__QUANTITY__ __UNIT__  ','',0,0,NULL,NULL,'NULL'),(52,'Kolhydrater __QUANTITY__ g','Kolhydrater __QUANTITY__ __UNIT__','g',3,36,1,'Kolhydrater %f __UNIT__','Kolhydrater %f g'),(53,'Kolhydrater __QUANTITY__g  ','Kolhydrater __QUANTITY____UNIT__  ','g',3,37,1,'Kolhydrater %f__UNIT__  ','Kolhydrater %fg  '),(54,'Kolhydrat __QUANTITY__ g','Kolhydrat __QUANTITY__ __UNIT__','g',3,38,1,'Kolhydrat %f __UNIT__','Kolhydrat %f g'),(55,'kolhydrat __QUANTITY__ gram','kolhydrat __QUANTITY__ __UNIT__','gram',4,39,1,'kolhydrat %f __UNIT__','kolhydrat %f gram'),(56,'Kolhydrat __QUANTITY__ Gram','Kolhydrat __QUANTITY__ __UNIT__','Gram',5,38,1,'Kolhydrat %f __UNIT__','Kolhydrat %f Gram'),(57,'Koppar __QUANTITY__ Kilokalori','Koppar __QUANTITY__ __UNIT__','Kilokalori',9,40,1,'Koppar %f __UNIT__','Koppar %f Kilokalori'),(58,'Koppar __QUANTITY__ Mikrogram','Koppar __QUANTITY__ __UNIT__','Mikrogram',13,40,1,'Koppar %f __UNIT__','Koppar %f Mikrogram'),(59,'Koppar __QUANTITY__ Milligram','Koppar __QUANTITY__ __UNIT__','Milligram',14,40,1,'Koppar %f __UNIT__','Koppar %f Milligram'),(60,'Krom __QUANTITY__ Mikrogram','Krom __QUANTITY__ __UNIT__','Mikrogram',13,41,1,'Krom %f __UNIT__','Krom %f Mikrogram'),(61,'Magnesium __QUANTITY__ Milligram','Magnesium __QUANTITY__ __UNIT__','Milligram',14,42,1,'Magnesium %f __UNIT__','Magnesium %f Milligram'),(62,'Mangan __QUANTITY__ Milligram','Mangan __QUANTITY__ __UNIT__','Milligram',14,43,1,'Mangan %f __UNIT__','Mangan %f Milligram'),(63,'Molybden __QUANTITY__ g','Molybden __QUANTITY__ __UNIT__','g',3,44,1,'Molybden %f __UNIT__','Molybden %f g'),(64,'Molybden __QUANTITY__ Mikrogram','Molybden __QUANTITY__ __UNIT__','Mikrogram',13,44,1,'Molybden %f __UNIT__','Molybden %f Mikrogram'),(65,'NACL __QUANTITY__ Gram','NACL __QUANTITY__ __UNIT__','Gram',5,45,1,'NACL %f __UNIT__','NACL %f Gram'),(66,'NACL __QUANTITY__ Milligram','NACL __QUANTITY__ __UNIT__','Milligram',14,45,1,'NACL %f __UNIT__','NACL %f Milligram'),(67,'Natrium __QUANTITY__ Gram','Natrium __QUANTITY__ __UNIT__','Gram',5,46,1,'Natrium %f __UNIT__','Natrium %f Gram'),(68,'Natrium __QUANTITY__ Milligram','Natrium __QUANTITY__ __UNIT__','Milligram',14,46,1,'Natrium %f __UNIT__','Natrium %f Milligram'),(69,'Niacin __QUANTITY__ Milligram','Niacin __QUANTITY__ __UNIT__','Milligram',14,47,1,'Niacin %f __UNIT__','Niacin %f Milligram'),(70,'Pantotensyra __QUANTITY__ mg','Pantotensyra __QUANTITY__ __UNIT__','mg',12,48,1,'Pantotensyra %f __UNIT__','Pantotensyra %f mg'),(71,'Pantotensyra __QUANTITY__ Milligram','Pantotensyra __QUANTITY__ __UNIT__','Milligram',14,48,1,'Pantotensyra %f __UNIT__','Pantotensyra %f Milligram'),(72,'Protein __QUANTITY__ g','Protein __QUANTITY__ __UNIT__','g',3,49,1,'Protein %f __UNIT__','Protein %f g'),(73,'Protein __QUANTITY__g  ','Protein __QUANTITY____UNIT__  ','',0,0,NULL,NULL,'NULL'),(74,'protein __QUANTITY__ gram','protein __QUANTITY__ __UNIT__','gram',4,51,1,'protein %f __UNIT__','protein %f gram'),(75,'Protein __QUANTITY__ Gram','Protein __QUANTITY__ __UNIT__','Gram',5,49,1,'Protein %f __UNIT__','Protein %f Gram'),(76,'Riboflavin __QUANTITY__','Riboflavin __QUANTITY__','',0,0,NULL,NULL,'NULL'),(77,'Riboflavin __QUANTITY__ mg','Riboflavin __QUANTITY__ __UNIT__','mg',12,53,1,'Riboflavin %f __UNIT__','Riboflavin %f mg'),(78,'Riboflavin __QUANTITY__ Milligram','Riboflavin __QUANTITY__ __UNIT__','Milligram',14,53,1,'Riboflavin %f __UNIT__','Riboflavin %f Milligram'),(79,'Salt','Salt','',0,0,NULL,NULL,'NULL'),(80,'Salt <0','Salt <0','',0,0,NULL,NULL,'NULL'),(81,'Salt __QUANTITY__ g','Salt __QUANTITY__ __UNIT__','g',3,54,1,'Salt %f __UNIT__','Salt %f g'),(82,'Salt __QUANTITY__g  ','Salt __QUANTITY____UNIT__  ','',0,0,NULL,NULL,'NULL'),(83,'salt __QUANTITY__ gram','salt __QUANTITY__ __UNIT__','gram',4,56,1,'salt %f __UNIT__','salt %f gram'),(84,'Salt __QUANTITY__ Gram','Salt __QUANTITY__ __UNIT__','Gram',5,54,1,'Salt %f __UNIT__','Salt %f Gram'),(85,'Selen __QUANTITY__ Mikrogram','Selen __QUANTITY__ __UNIT__','Mikrogram',13,57,1,'Selen %f __UNIT__','Selen %f Mikrogram'),(86,'Tiamin __QUANTITY__ Milligram','Tiamin __QUANTITY__ __UNIT__','Milligram',14,58,1,'Tiamin %f __UNIT__','Tiamin %f Milligram'),(87,'varav enkelomättat fett __QUANTITY__ g','varav enkelomättat fett __QUANTITY__ __UNIT__','g',3,59,1,'varav enkelomättat fett %f __UNIT__','varav enkelomättat fett %f g'),(88,'Varav enkelomättat fett __QUANTITY__ Gram','Varav enkelomättat fett __QUANTITY__ __UNIT__','Gram',5,60,1,'Varav enkelomättat fett %f __UNIT__','Varav enkelomättat fett %f Gram'),(89,'varav fleromättat fett __QUANTITY__ g','varav fleromättat fett __QUANTITY__ __UNIT__','g',3,61,1,'varav fleromättat fett %f __UNIT__','varav fleromättat fett %f g'),(90,'Varav fleromättat fett __QUANTITY__ Gram','Varav fleromättat fett __QUANTITY__ __UNIT__','Gram',5,62,1,'Varav fleromättat fett %f __UNIT__','Varav fleromättat fett %f Gram'),(91,'varav laktos __QUANTITY__ g','varav laktos __QUANTITY__ __UNIT__','g',3,63,1,'varav laktos %f __UNIT__','varav laktos %f g'),(92,'varav mättat fett __QUANTITY__ g','varav mättat fett __QUANTITY__ __UNIT__','g',3,64,1,'varav mättat fett %f __UNIT__','varav mättat fett %f g'),(93,'varav: Mättat fett __QUANTITY__g  ','varav: Mättat fett __QUANTITY____UNIT__  ','g',3,65,1,'varav: Mättat fett %f__UNIT__  ','varav: Mättat fett %fg  '),(94,'varav mättat fett __QUANTITY__ gram','varav mättat fett __QUANTITY__ __UNIT__','gram',4,64,1,'varav mättat fett %f __UNIT__','varav mättat fett %f gram'),(95,'Varav mättat fett __QUANTITY__ Gram','Varav mättat fett __QUANTITY__ __UNIT__','Gram',5,66,1,'Varav mättat fett %f __UNIT__','Varav mättat fett %f Gram'),(96,'varav polyoler __QUANTITY__ gram','varav polyoler __QUANTITY__ __UNIT__','gram',4,67,1,'varav polyoler %f __UNIT__','varav polyoler %f gram'),(97,'Varav polyoler __QUANTITY__ Gram','Varav polyoler __QUANTITY__ __UNIT__','Gram',5,68,1,'Varav polyoler %f __UNIT__','Varav polyoler %f Gram'),(98,'Varav sockerarter','Varav sockerarter','',0,0,NULL,NULL,'NULL'),(99,'varav sockerarter2','varav sockerarter2','',0,0,NULL,NULL,'NULL'),(100,'varav sockerarter __QUANTITY__','varav sockerarter __QUANTITY__','',0,0,NULL,NULL,'NULL'),(101,'varav sockerarter __QUANTITY__ g','varav sockerarter __QUANTITY__ __UNIT__','g',3,70,1,'varav sockerarter %f __UNIT__','varav sockerarter %f g'),(102,'varav: Sockerarter __QUANTITY__g  ','varav: Sockerarter __QUANTITY____UNIT__  ','g',3,71,1,'varav: Sockerarter %f__UNIT__  ','varav: Sockerarter %fg  '),(103,'varav sockerarter __QUANTITY__ gram','varav sockerarter __QUANTITY__ __UNIT__','gram',4,70,1,'varav sockerarter %f __UNIT__','varav sockerarter %f gram'),(104,'Varav sockerarter __QUANTITY__ Gram','Varav sockerarter __QUANTITY__ __UNIT__','Gram',5,72,1,'Varav sockerarter %f __UNIT__','Varav sockerarter %f Gram'),(105,'varav sockerater __QUANTITY__ g','varav sockerater __QUANTITY__ __UNIT__','g',3,73,1,'varav sockerater %f __UNIT__','varav sockerater %f g'),(106,'Varav stärkelse __QUANTITY__ Gram','Varav stärkelse __QUANTITY__ __UNIT__','Gram',5,74,1,'Varav stärkelse %f __UNIT__','Varav stärkelse %f Gram'),(107,'Vitamin A310 µg (39% av DRI*) *Dagligt Referensintag  ','Vitamin A__QUANTITY__ __UNIT__ (39% av DRI*) *Dagligt Referensintag  ','µg',2,75,1,'Vitamin A%f __UNIT__ (39% av DRI*) *Dagligt Referensintag  ','Vitamin A%f µg (39% av DRI*) *Dagligt Referensintag  '),(108,'Vitamin A __QUANTITY__ g','Vitamin A __QUANTITY__ __UNIT__','g',3,76,1,'Vitamin A %f __UNIT__','Vitamin A %f g'),(109,'Vitamin A __QUANTITY__ Mikrogram','Vitamin A __QUANTITY__ __UNIT__','Mikrogram',13,76,1,'Vitamin A %f __UNIT__','Vitamin A %f Mikrogram'),(110,'Vitamin B12 __QUANTITY__ g','Vitamin B12 __QUANTITY__ __UNIT__','g',3,77,1,'Vitamin B12 %f __UNIT__','Vitamin B12 %f g'),(111,'Vitamin B12 __QUANTITY__ mg','Vitamin B12 __QUANTITY__ __UNIT__','mg',12,77,1,'Vitamin B12 %f __UNIT__','Vitamin B12 %f mg'),(112,'Vitamin B12 __QUANTITY__ Mikrogram','Vitamin B12 __QUANTITY__ __UNIT__','Mikrogram',13,77,1,'Vitamin B12 %f __UNIT__','Vitamin B12 %f Mikrogram'),(113,'Vitamin B6 __QUANTITY__ Milligram','Vitamin B6 __QUANTITY__ __UNIT__','Milligram',14,78,1,'Vitamin B6 %f __UNIT__','Vitamin B6 %f Milligram'),(114,'Vitamin C __QUANTITY__ mg','Vitamin C __QUANTITY__ __UNIT__','mg',12,79,1,'Vitamin C %f __UNIT__','Vitamin C %f mg'),(115,'Vitamin C __QUANTITY__ Milligram','Vitamin C __QUANTITY__ __UNIT__','Milligram',14,79,1,'Vitamin C %f __UNIT__','Vitamin C %f Milligram'),(116,'Vitamin D __QUANTITY__ g','Vitamin D __QUANTITY__ __UNIT__','g',3,80,1,'Vitamin D %f __UNIT__','Vitamin D %f g'),(117,'Vitamin D __QUANTITY__ Gram','Vitamin D __QUANTITY__ __UNIT__','Gram',5,80,1,'Vitamin D %f __UNIT__','Vitamin D %f Gram'),(118,'Vitamin D __QUANTITY__ Mikrogram','Vitamin D __QUANTITY__ __UNIT__','Mikrogram',13,80,1,'Vitamin D %f __UNIT__','Vitamin D %f Mikrogram'),(119,'Vitamin E __QUANTITY__ Milligram','Vitamin E __QUANTITY__ __UNIT__','Milligram',14,81,1,'Vitamin E %f __UNIT__','Vitamin E %f Milligram'),(120,'Vitamin K __QUANTITY__ Mikrogram','Vitamin K __QUANTITY__ __UNIT__','Mikrogram',13,82,1,'Vitamin K %f __UNIT__','Vitamin K %f Mikrogram'),(121,'Zink __QUANTITY__ Milligram','Zink __QUANTITY__ __UNIT__','Milligram',14,83,1,'Zink %f __UNIT__','Zink %f Milligram');
/*!40000 ALTER TABLE `temporarynuts2` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-08-04 11:56:03
