
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


-- --------------------------------------------------------
-- Hostitel:                     db-server.kkrp.cz
-- Verze serveru:                11.5.2-MariaDB - MariaDB Server
-- OS serveru:                   Linux
-- HeidiSQL Verze:               12.8.0.6976
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Exportování struktury pro tabulka s29_dev-redm.aprts_ranch_config_animals
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

-- Exportování dat pro tabulku s29_dev-redm.aprts_ranch_config_animals: ~5 rows (přibližně)
INSERT INTO `aprts_ranch_config_animals` (`animal_id`, `name`, `price`, `model`, `m_model`, `health`, `adultAge`, `WalkOnly`, `offsetX`, `offsetY`, `offsetZ`, `food`, `water`, `foodMax`, `waterMax`, `kibble`, `kibbleFood`, `poop`, `poopChance`, `dieAge`, `pregnancyTime`, `pregnancyChance`, `noFuckTime`) VALUES
	(1, 'Goat', 10, 'a_c_goat_01', 'a_c_bighornram_01', 100, 3, 0, 0, 2, 0, 2, 3, 48, 72, 'product_carrot', 14, 'p_poop01x', 0.3, 12, 1, 20, 1),
	(2, 'Cow', 10, 'a_c_cow', 'a_c_bull_01', 300, 5, 0, 0, 2, 0, 25, 25, 600, 360, 'animal_silage', 200, 's_horsepoop01x', 0.4, 20, 1, 20, 1),
	(3, 'Chicken1', 10, 'a_c_chicken_01', 'a_c_rooster_01', 50, 2, 0, 0, 2, 0, 1, 1, 24, 24, 'product_wheat', 10, 'p_poop01x', 0.1, 10, 1, 20, 1),
	(4, 'sheep', 10, 'a_c_sheep_01', 'mp_a_c_bighornram_01', 50, 2, 0, 0, 2, 0, 2, 2, 48, 48, 'product_grass', 14, 'p_sheeppoop01x', 0.1, 12, 1, 70, 1),
	(5, 'pig', 10, 'a_c_pig_01', 'a_c_pig_01', 50, 3, 0, 0, 2, 0, 2, 2, 120, 120, 'product_grass', 30, 'p_sheeppoop01x', 0.1, 10, 1, 70, 1);

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

-- Exportování dat pro tabulku s29_dev-redm.aprts_ranch_config_animal_products: ~12 rows (přibližně)
INSERT INTO `aprts_ranch_config_animal_products` (`product_id`, `animal_id`, `name`, `item`, `prop`, `gather`, `amount`, `maxAmount`, `lifetime`, `tool`, `anim`, `chance`, `gender`) VALUES
	(1, 1, 'Kozí Mléko', 'animal_goat_milk', NULL, 2, 1, 3, 10800, 'tool_empty_bucket', '{"dict": "mech_animal_interaction@horse@left@brushing", "name": "idle_a", "time": 10000, "flag": 17, "type": "standard", "prop": null}', 100, 'female'),
	(2, 1, 'Zvířecí roh', 'animal_horn', NULL, 1, 1, NULL, 10800, '', '{"dict": "mech_animal_interaction@horse@left@brushing", "name": "idle_a", "time": 10000, "flag": 17, "type": "standard", "prop": null}', 100, NULL),
	(3, 1, 'Zvířecí kůže', 'animal_pelt', NULL, 1, 1, NULL, 10800, '', '{"dict": "mech_animal_interaction@horse@left@brushing", "name": "idle_a", "time": 10000, "flag": 17, "type": "standard", "prop": null}', 100, NULL),
	(4, 3, 'Vejce', 'animal_egg', 'p_egg01x', 3, 1, 10, 10800, 'tool_basket', '{"dict": "mech_animal_interaction@horse@left@brushing", "name": "idle_a", "time": 10000, "flag": 17, "type": "standard", "prop": null}', 30, 'female'),
	(5, 3, 'Maso', 'animal_chicken_meat', NULL, 1, 1, NULL, 10800, '', '{"dict": "mech_animal_interaction@horse@left@brushing", "name": "idle_a", "time": 10000, "flag": 17, "type": "standard", "prop": null}', 60, NULL),
	(6, 3, 'Peří', 'animal_feathers', NULL, 1, 1, NULL, 10800, '', '{"dict": "mech_animal_interaction@horse@left@brushing", "name": "idle_a", "time": 10000, "flag": 17, "type": "standard", "prop": null}', 60, NULL),
	(7, 4, 'Vlna', 'animal_wool', NULL, 2, 1, 10, 10800, 'tool_scissors', '{"dict": "mech_animal_interaction@horse@left@brushing", "name": "idle_a", "time": 10000, "flag": 17, "type": "standard", "prop": null}', 60, NULL),
	(8, 4, 'Ovcí mléko', 'animal_sheep_milk', NULL, 1, 1, NULL, 10800, '', '{"dict": "mech_animal_interaction@horse@left@brushing", "name": "idle_a", "time": 10000, "flag": 17, "type": "standard", "prop": null}', 60, 'female'),
	(9, 4, 'Maso', 'animal_meat', NULL, 1, 1, NULL, 10800, '', '{"dict": "mech_animal_interaction@horse@left@brushing", "name": "idle_a", "time": 10000, "flag": 17, "type": "standard", "prop": null}', 60, NULL),
	(10, 4, 'Vlna', 'animal_wool', NULL, 1, 1, NULL, 10800, '', '{"dict": "mech_animal_interaction@horse@left@brushing", "name": "idle_a", "time": 10000, "flag": 17, "type": "standard", "prop": null}', 60, NULL),
	(11, 5, 'Štetiny', 'animal_pighair', NULL, 2, 1, 10, 10800, 'tool_scissors', '{"dict": "mech_animal_interaction@horse@left@brushing", "name": "idle_a", "time": 10000, "flag": 17, "type": "standard", "prop": null}', 60, NULL),
	(12, 5, 'Maso', 'animal_boar_meat', NULL, 1, 4, NULL, 10800, '', '{"dict": "mech_animal_interaction@horse@left@brushing", "name": "idle_a", "time": 10000, "flag": 17, "type": "standard", "prop": null}', 60, NULL);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
