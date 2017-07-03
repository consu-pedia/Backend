USE `consupedia`;
--
-- Table structure for table `contents`
--

DROP TABLE IF EXISTS `contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contents` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8572 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contents`
--

LOCK TABLES `contents` WRITE;
/*!40000 ALTER TABLE `contents` DISABLE KEYS */;
/*!40000 ALTER TABLE `contents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_product`
--

DROP TABLE IF EXISTS `content_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
/*  `product_gtin` varchar(255) COLLATE utf8_unicode_ci NOT NULL, */
/* key (content_id, product_id) is NOT UNIQUE, see for example solrosolja in:
havregryn, inulin (fiber), veteflingor, solrosolja, torkade tranbär (tranbär, koncentrerad ananasjuice, solrosolja), solroskärnor, kokosflingor, linfrön, frystorkade jordgubbar (jordgubbar, solrosolja), salt, naturlig arom, vanilj.',
*/
CREATE TABLE `content_product` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(10) unsigned DEFAULT NULL,
  `content_id` int(10) unsigned DEFAULT NULL,
  `content_product_ranknr` int(3) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY (`product_id`, `content_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8572 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_product`
--

LOCK TABLES `content_product` WRITE;
/*!40000 ALTER TABLE `content_product` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_product` ENABLE KEYS */;
UNLOCK TABLES;

