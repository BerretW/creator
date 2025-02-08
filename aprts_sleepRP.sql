CREATE TABLE IF NOT EXISTS `aprts_sleepRP` (
  `charID` int(11) NOT NULL,
  `coords` varchar(255) DEFAULT NULL,
  `gender` varchar(50) DEFAULT '',
  `meta` text DEFAULT NULL,
  PRIMARY KEY (`charID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;