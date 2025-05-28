
-- Exportování struktury pro tabulka vorp.aprts_ranch
CREATE TABLE IF NOT EXISTS `aprts_ranch` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `owner` int(11) unsigned NOT NULL DEFAULT 0,
  `land_id` mediumint(8) unsigned NOT NULL,
  `money` float NOT NULL DEFAULT 0,
  `storage_id` mediumint(8) unsigned DEFAULT 0,
  `storage_limit` smallint(5) unsigned NOT NULL DEFAULT 200,
  `coords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`coords`)),
  KEY `Index 1` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Export dat nebyl vybrán.

-- Exportování struktury pro tabulka vorp.aprts_ranch_animals
CREATE TABLE IF NOT EXISTS `aprts_ranch_animals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `breed` varchar(50) NOT NULL DEFAULT 'goat',
  `coords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '{"x":0.0,"y":0.0,"z":0.0}',
  `gender` varchar(50) NOT NULL DEFAULT 'male',
  `pregnant` tinyint(4) NOT NULL DEFAULT 0,
  `out` tinyint(4) NOT NULL DEFAULT 0,
  `railing_id` smallint(6) NOT NULL,
  `health` tinyint(4) NOT NULL DEFAULT 100,
  `food` tinyint(4) NOT NULL DEFAULT 100,
  `water` tinyint(4) NOT NULL DEFAULT 100,
  `clean` tinyint(4) NOT NULL DEFAULT 100,
  `sick` tinyint(4) NOT NULL DEFAULT 0,
  `happynes` tinyint(4) NOT NULL DEFAULT 100,
  `energy` tinyint(4) NOT NULL DEFAULT 100,
  `age` tinyint(4) NOT NULL DEFAULT 0,
  `quality` tinyint(4) NOT NULL DEFAULT 0,
  `count` tinyint(4) NOT NULL DEFAULT 0,
  `born` timestamp NOT NULL DEFAULT current_timestamp(),
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  KEY `Index 1` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Export dat nebyl vybrán.

-- Exportování struktury pro tabulka vorp.aprts_ranch_railing
CREATE TABLE IF NOT EXISTS `aprts_ranch_railing` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ranch_id` int(10) unsigned NOT NULL DEFAULT 0,
  `food` int(10) unsigned NOT NULL DEFAULT 0,
  `water` int(10) unsigned NOT NULL DEFAULT 0,
  `shit` int(10) unsigned NOT NULL DEFAULT 0,
  `coords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '{"x":0.0,"y":0.0,"z":0.0}',
  `size` int(11) unsigned NOT NULL DEFAULT 10,
  `prop` varchar(50) NOT NULL DEFAULT 'p_mp_feedbaghang01x',
  KEY `Index 1` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;



CREATE TABLE IF NOT EXISTS `aprts_ranch_config_animals` (
  `animal_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `price` int(11) NOT NULL,
  `model` varchar(255) NOT NULL,
  `m_model` varchar(255) NOT NULL,
  `health` int(11) NOT NULL,
  `adultAge` int(11) NOT NULL,
  `WalkOnly` tinyint(1) NOT NULL,
  `offsetX` float NOT NULL,
  `offsetY` float NOT NULL,
  `offsetZ` float NOT NULL,
  `food` int(11) NOT NULL,
  `water` int(11) NOT NULL,
  `foodMax` int(11) NOT NULL,
  `waterMax` int(11) NOT NULL,
  `kibble` varchar(255) NOT NULL,
  `kibbleFood` int(11) NOT NULL,
  `poop` varchar(255) NOT NULL,
  `poopChance` float NOT NULL,
  `dieAge` int(11) NOT NULL,
  `pregnancyTime` int(11) NOT NULL,
  `pregnancyChance` int(11) NOT NULL,
  `noFuckTime` int(11) NOT NULL,
  PRIMARY KEY (`animal_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- Exportování struktury pro tabulka s29_dev-redm.aprts_ranch_config_animal_products
CREATE TABLE IF NOT EXISTS `aprts_ranch_config_animal_products` (
  `product_id` int(11) NOT NULL AUTO_INCREMENT,
  `animal_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `item` varchar(255) NOT NULL,
  `prop` varchar(255) DEFAULT NULL,
  `gather` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  `maxAmount` int(11) DEFAULT NULL,
  `lifetime` int(11) NOT NULL,
  `tool` varchar(255) DEFAULT NULL,
  `anim` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`anim`)),
  `chance` int(11) NOT NULL,
  `gender` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`product_id`),
  KEY `animal_id` (`animal_id`),
  CONSTRAINT `aprts_ranch_config_animal_products_ibfk_1` FOREIGN KEY (`animal_id`) REFERENCES `aprts_ranch_config_animals` (`animal_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
