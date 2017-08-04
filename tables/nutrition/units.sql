--
-- Table structure for table `units`
--
DROP TABLE IF EXISTS `units`;
CREATE TABLE `units` (
  `id` int(11) NOT NULL,
  `unitname` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `units`
--

LOCK TABLES `units` WRITE;

INSERT INTO units VALUES( 1, NULL );
INSERT INTO units VALUES( 2, 'µg' );
INSERT INTO units VALUES(3, 'g' );
INSERT INTO units VALUES(4, 'gram' );
INSERT INTO units VALUES(5, 'Gram' );
INSERT INTO units VALUES(6, 'kcal' );
INSERT INTO units VALUES(7, 'kilojoule' );
INSERT INTO units VALUES(8, 'Kilojoule' );
INSERT INTO units VALUES(9, 'Kilokalori' );
INSERT INTO units VALUES(10, 'kilokalorier' );
INSERT INTO units VALUES(11, 'kJ' );
INSERT INTO units VALUES(12, 'mg' );
INSERT INTO units VALUES(13, 'Mikrogram' );
INSERT INTO units VALUES(14, 'Milligram' );
