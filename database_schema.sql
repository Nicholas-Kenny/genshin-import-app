-- Database Setup Script for Genshin Import App

CREATE DATABASE IF NOT EXISTS `genshin_import_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `genshin_import_db`;

-- 1. Table Structure for `users`
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(255) NULL, -- Nullable because of Google OAuth users
  `role` ENUM('customer', 'admin') DEFAULT 'customer',
  `oauth_provider` VARCHAR(20) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Table Structure for `items`
DROP TABLE IF EXISTS `items`;
CREATE TABLE `items` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `type` VARCHAR(50) NOT NULL,
  `category` VARCHAR(50) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `stock` INT NOT NULL DEFAULT 0,
  `price` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  `stars` INT NOT NULL DEFAULT 1,
  `image_url` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Table Structure for `cart`
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `item_id` INT NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_user_item` (`user_id`, `item_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Table Structure for `inventory`
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

-- =====================================================================
-- SEED DATA (Optional data insertion for testing initialization)
-- =====================================================================

-- Insert Default Admin Account (Password hashed using bcrypt 'admin123')
INSERT INTO `users` (`username`, `email`, `password`, `role`) VALUES
('admin', 'admin@gmail.com', '$2b$10$O0Fq/mFqj6rBfT/M5y7PneM9lY2O6fL7rC2/o9iL6zG7JqXWqGg2q', 'admin')
ON DUPLICATE KEY UPDATE `id`=`id`;

-- Insert Initial Sample Items
INSERT INTO `items` (`name`, `type`, `category`, `description`, `stock`, `price`, `stars`, `image_url`) VALUES
('Primogems Pack', 'Currency', 'Premium', 'Essential currency used to make wishes for characters and weapons.', 999, 15000.00, 5, NULL),
('Intertwined Fate', 'Wish', 'Item', 'A fateful stone that connects dreams. Used for Limited Banners.', 500, 25000.00, 5, NULL),
('Acquaint Fate', 'Wish', 'Item', 'A fateful stone that connects dreams. Used for Standard Banners.', 300, 20000.00, 5, NULL),
('Wolf\'s Gravestone', 'Weapon', 'Claymore', 'A longsword used by the Wolf Knight. Increases ATK significantly.', 10, 150000.00, 5, NULL);
