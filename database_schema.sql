CREATE DATABASE IF NOT EXISTS `genshin_import_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `genshin_import_db`;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(100) NOT NULL UNIQUE,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(255) NULL, -- Nullable b/c of Google OAuth users
  `role` ENUM('customer', 'admin') DEFAULT 'customer',
  `oauth_provider` VARCHAR(50) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `items`;
CREATE TABLE `items` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(150) NOT NULL,
  `type` VARCHAR(50) NOT NULL,
  `category` ENUM('Weapons', 'Artifacts') NOT NULL,
  `description` TEXT DEFAULT NULL,
  `stock` INT NOT NULL DEFAULT 0,
  `price` INT NOT NULL DEFAULT 0,
  `stars` INT NOT NULL DEFAULT 4,
  `image_url` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `item_id` INT NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `inventory`;
CREATE TABLE `inventory` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `item_id` INT NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `purchased_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert Default Admin Account (Password hashed using bcrypt 'admin123')
INSERT INTO `users` (`username`, `email`, `password`, `role`) VALUES
('admin', 'admin@gmail.com', '$2b$10$8ys/i0AOFbD0WEeIDHx36OnlMG15IevjNYMfg.sQsP4w1JaIW8S5u', 'admin')
ON DUPLICATE KEY UPDATE `id`=`id`;

-- Insert Sample Items
INSERT INTO `items` (`name`, `type`, `category`, `description`, `stock`, `price`, `stars`, `image_url`) VALUES

-- WEAPONS
('Wolf\'s Gravestone', 'Claymore', 'Weapons',
'A longsword used by the Wolf Knight. Once just a heavy sheet of iron, it became endowed with legendary power through his bond with wolves. Greatly increases ATK for the whole party.',
10, 150000, 5,
'http://localhost:3000/uploads/wolfgravestone.jpg'),

('Aquila Favonia', 'Sword', 'Weapons',
'The soul of the Knights of Favonius. Millennia later, it still calls on the winds of swift justice. Increases ATK and regenerates HP when the wielder takes damage.',
7, 175000, 5,
'http://localhost:3000/uploads/aquilafavonia.webp'),

('Engulfing Lightning', 'Polearm', 'Weapons',
'A polearm that carries the will of an Electro Archon. Increases ATK based on Energy Recharge and restores Energy after using an Elemental Burst.',
5, 160000, 5,
'http://localhost:3000/uploads/engulfinglightning.jpg'),

-- ARTIFACTS
('Viridescent Venerer\'s Diadem', 'Circlet of Logos', 'Artifacts',
'A crown woven from windswept petals. Part of the Viridescent Venerer set — increases Anemo DMG and enhances Swirl reactions while shredding enemy Elemental RES.',
25, 35000, 4,
'http://localhost:3000/uploads/ViridescentVenererDiadem.webp'),

('Emblem of Severed Fate - Storm Cage', 'Sands of Eon', 'Artifacts',
'An ornate timepiece from Inazuma\'s Momiji-Dyed Court. Part of the Emblem of Severed Fate set — boosts Energy Recharge and scales Elemental Burst DMG.',
15, 50000, 5, 
'http://localhost:3000/uploads/stormcage.webp');