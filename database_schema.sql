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
('admin', 'admin@gmail.com', '$2b$10$O0Fq/mFqj6rBfT/M5y7PneM9lY2O6fL7rC2/o9iL6zG7JqXWqGg2q', 'admin')
ON DUPLICATE KEY UPDATE `id`=`id`;

-- Insert Sample Items
INSERT INTO `items` (`name`, `type`, `category`, `description`, `stock`, `price`, `stars`, `image_url`) VALUES
('Primogems Pack', 'Currency', 'Premium', 'Essential currency used to make wishes for characters and weapons.', 999, 15000.00, 5, NULL),
('Intertwined Fate', 'Wish', 'Item', 'A fateful stone that connects dreams. Used for Limited Banners.', 500, 25000.00, 5, NULL),
('Acquaint Fate', 'Wish', 'Item', 'A fateful stone that connects dreams. Used for Standard Banners.', 300, 20000.00, 5, NULL),
('Wolf\'s Gravestone', 'Weapon', 'Claymore', 'A longsword used by the Wolf Knight. Increases ATK significantly.', 10, 150000.00, 5, NULL);
