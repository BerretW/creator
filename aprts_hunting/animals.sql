-- Exportování struktury pro tabulka spoiledwest.aprts_hunting_animals
CREATE TABLE IF NOT EXISTS `aprts_hunting_animals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT 'animal',
  `outfit` double DEFAULT 0,
  `model` double NOT NULL DEFAULT 0,
  `perfect` double DEFAULT NULL,
  `item` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '[{"name":"raw_meat","quantity":1}]',
  `poor` double DEFAULT NULL,
  `good` double DEFAULT NULL,
  `hunting_season` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '[]',
  `base_price` float NOT NULL DEFAULT 1,
  `poor_price` float DEFAULT NULL,
  `good_price` float DEFAULT NULL,
  `perfect_price` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=355 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- Exportování dat pro tabulku spoiledwest.aprts_hunting_animals: ~267 rows (přibližně)
INSERT INTO `aprts_hunting_animals` (`id`, `name`, `outfit`, `model`, `perfect`, `item`, `poor`, `good`, `hunting_season`, `base_price`, `poor_price`, `good_price`, `perfect_price`) VALUES
	(78, 'Armadillo', 0, -1797625440, -662726703, '[{"name":"raw_meat","quantity":1}]', 1760886130, 143941906, '[]', 0.5, 0.2, 0.5, 1),
	(79, 'American Badger', 0, -1170118274, NULL, '[{"name":"raw_meat","quantity":1}]', NULL, NULL, '[]', 0.5, 0.2, 0.5, 1),;



-- Exportování struktury pro tabulka vorp.aprts_hunting_butchers
CREATE TABLE IF NOT EXISTS `aprts_hunting_butchers` (
  `id` int(200) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT 'Řezník',
  `location` varchar(50) NOT NULL DEFAULT 'Někde',
  `coords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '{"x":0, "y":0, "z":0}',
  `npcH` double NOT NULL DEFAULT 0.1,
  `blipsprite` varchar(50) NOT NULL DEFAULT 'blip_shop_butcher',
  `blipscale` double NOT NULL DEFAULT 0.2,
  `gain` double NOT NULL DEFAULT 1.1,
  `showblip` char(50) NOT NULL DEFAULT 'true',
  `model` varchar(250) NOT NULL DEFAULT 'u_m_m_nbxgeneralstoreowner_01',
  KEY `Index 1` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Exportování dat pro tabulku vorp.aprts_hunting_butchers: ~7 rows (přibližně)
INSERT INTO `aprts_hunting_butchers` (`id`, `name`, `location`, `coords`, `npcH`, `blipsprite`, `blipscale`, `gain`, `showblip`, `model`) VALUES
	(1, 'Řezník BW', 'BW', '{"x":-753.0073, "y":-1284.9989, "z":43.464}', 0.1, 'blip_shop_butcher', 0.2, 1.1, 'true', 'u_m_m_nbxgeneralstoreowner_01'),
	(2, 'Řezník SD', 'SD', '{"x":2816.37, "y":-1322.24, "z":46.61}', 0.2, 'blip_shop_butcher', 0.2, 1.1, 'true', 'u_m_m_nbxgeneralstoreowner_01'),
	(3, 'Řerzník VL', 'VL', '{"x":-339.1436, "y":767.3636, "z":116.6287}', 0.1, 'blip_shop_butcher', 0.2, 1.1, 'true', 'u_m_m_nbxgeneralstoreowner_01'),
	(4, 'Řezník RD', 'RD', '{"x":1297.4504, "y":-1277.6608, "z":75.8773}', 0.1, 'blip_shop_butcher', 0.2, 1.1, 'true', 'u_m_m_nbxgeneralstoreowner_01'),
	(5, 'Řezník TW', 'TW', '{"x":-5509.8989, "y":-2947.0015, "z":-1.8936}', 0.1, 'blip_shop_butcher', 0.2, 1.1, 'true', 'u_m_m_nbxgeneralstoreowner_01'),
	(6, 'Řezník AN', 'AN', '{"x":2932.54, "y":1302.00, "z": 44.48}', 0.1, 'blip_shop_butcher', 0.2, 1.1, 'true', 'u_m_m_nbxgeneralstoreowner_01'),
	(7, 'Řezník VH', 'VH', '{"x": 2994.23, "y":571.79, "z":44.35}', 0.1, 'blip_shop_butcher', 0.2, 1.1, 'true', 'u_m_m_nbxgeneralstoreowner_01');

