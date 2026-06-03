# genshin-import-app

# 🌟 Genshin Import App

Aplikasi manajemen katalog item (Weapons & Artifacts) Genshin Impact. Project ini menggunakan arsitektur Monorepo yang terdiri dari **Backend (Node.js, Express, MySQL)** dan **Frontend (Flutter)**.

## 📋 Prasyarat Sistem
Sebelum menjalankan project ini, pastikan komputer Anda sudah terinstal:
1. **Node.js** (Minimal v16+)
2. **MySQL** (Bisa menggunakan XAMPP, MAMP, atau Laragon)
3. **Flutter SDK** (Untuk menjalankan aplikasi mobile)

---

## 🛠️ Panduan Setup Backend (Node.js)

Ikuti langkah-langkah di bawah ini secara berurutan untuk menyalakan server backend.

### 1. Setup Database & Akun Admin
1. Nyalakan modul **MySQL** (misal: via XAMPP Control Panel).
2. Buka phpMyAdmin (biasanya di `http://localhost/phpmyadmin`).
3. Buat database baru bernama `genshin_import_db`.
4. Jalankan query SQL di bawah ini untuk membuat tabel dan menyuntikkan 1 akun Admin:

```sql
-- Buat Tabel Users
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255),
    role ENUM('admin', 'customer') DEFAULT 'customer',
    oauth_provider VARCHAR(50) DEFAULT 'local',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Buat Tabel Items
CREATE TABLE items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    type VARCHAR(50) NOT NULL,
    category ENUM('Weapons', 'Artifacts') NOT NULL,
    description TEXT,
    stock INT DEFAULT 0,
    price INT NOT NULL,
    stars INT DEFAULT 4,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Buat Akun Admin Default (Password belum di-hash, pastikan register ulang via Postman jika ingin fitur login aman)
INSERT INTO users (username, email, password, role) 
VALUES ('admin_gacha', 'admin@genshinimport.com', 'admin1234', 'admin');
```

### 2. Setup Environment Variables (.env)
Karena file .env bersifat rahasia dan tidak diunggah ke GitHub, Anda harus membuatnya secara manual.

Masuk ke folder backend: cd backend

Buat file baru bernama .env

Isi dengan konfigurasi berikut (sesuaikan password database jika XAMPP Anda menggunakan password):
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=genshin_import_db
JWT_SECRET=rahasia_teyvat_kunci_super_aman_123

### 3. Install Dependencies & Jalankan Server
Buka terminal, pastikan posisi Anda berada di dalam folder backend, lalu jalankan:

Bash
# Install semua package Node.js
npm install

# Jalankan server dengan Nodemon
npm run dev

Jika berhasil, terminal akan menampilkan:

app listening on port 3000
DB connected : genshin_import_db


## 📱 Panduan Setup Frontend (Flutter)
Setelah server Backend menyala, Anda bisa menjalankan aplikasi mobile-nya.

1. Buka terminal baru (biarkan terminal Backend tetap menyala).

2. Masuk ke folder frontend: cd frontend

3. Ambil semua package Flutter yang dibutuhkan:

Bash
flutter pub get

4. Jalankan aplikasi (pilih emulator atau device yang tersedia):

Bash
flutter run
"# genshin-import-app" 
