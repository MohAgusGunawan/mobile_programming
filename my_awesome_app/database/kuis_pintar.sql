-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Waktu pembuatan: 05 Jan 2025 pada 06.13
-- Versi server: 8.0.30
-- Versi PHP: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `kuis_pintar`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `kategori`
--

CREATE TABLE `kategori` (
  `id` int NOT NULL,
  `nama_kategori` varchar(50) NOT NULL,
  `foto` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `dibuat_oleh` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data untuk tabel `kategori`
--

INSERT INTO `kategori` (`id`, `nama_kategori`, `foto`, `dibuat_oleh`) VALUES
(1, 'Pengetahuan Umum', '1735999462968-image.jpg', 3),
(2, 'Matematika', '1735547205274-image.png', 3),
(3, 'Bahasa Inggris', '1735559140957-image.png', 3),
(4, 'Agama Islam', '1735559715180-image.png', 3),
(5, 'Bahasa Indonesia', '1735710755786-image.png', 3);

-- --------------------------------------------------------

--
-- Struktur dari tabel `papan_peringkat`
--

CREATE TABLE `papan_peringkat` (
  `id` int NOT NULL,
  `id_user` int NOT NULL,
  `id_kategori` int NOT NULL,
  `nilai_skor` int NOT NULL,
  `waktu_pengerjaan` int NOT NULL,
  `tanggal_minggu` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `profile`
--

CREATE TABLE `profile` (
  `id` int NOT NULL,
  `id_user` int NOT NULL,
  `nama` varchar(50) DEFAULT NULL,
  `foto` varchar(100) DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `jenis_kelamin` enum('L','P') DEFAULT NULL,
  `bio` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `skor`
--

CREATE TABLE `skor` (
  `id` int NOT NULL,
  `id_user` int NOT NULL,
  `id_kategori` int NOT NULL,
  `nilai_skor` int NOT NULL,
  `total_soal` int NOT NULL,
  `jawaban_benar` int NOT NULL,
  `waktu_pengerjaan` int NOT NULL,
  `selesai_pada` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `soal`
--

CREATE TABLE `soal` (
  `id` int NOT NULL,
  `id_kategori` int NOT NULL,
  `soal` text NOT NULL,
  `gambar` varchar(50) DEFAULT NULL,
  `opsi_a` text NOT NULL,
  `opsi_b` text NOT NULL,
  `opsi_c` text NOT NULL,
  `opsi_d` text NOT NULL,
  `id_jawaban` enum('a','b','c','d') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `dibuat_oleh` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data untuk tabel `soal`
--

INSERT INTO `soal` (`id`, `id_kategori`, `soal`, `gambar`, `opsi_a`, `opsi_b`, `opsi_c`, `opsi_d`, `id_jawaban`, `dibuat_oleh`) VALUES
(1, 1, 'Apa nama ibu kota negara Jepang?', NULL, 'Osaka', 'Kyoto', 'Tokyo', 'Nagoya', 'c', 3),
(7, 1, 'gjgjgj45', '1736054686628-image.png', 'fhgfghf', 'gdgdg', 'sgfsgf', 'gdgd', 'a', 3),
(8, 1, 'jhjhadj7', '1736054695381-image.png', 'jhjhfjhf', 'jfjfjfjh', 'fjfjfjhf', 'fjfjhffhf', 'b', 3);

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `email` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','user') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `email`, `username`, `password`, `role`) VALUES
(2, 'viki@gmail.com', 'viki', '$2b$10$pRkH.1hHwLfe6YoJQPkgi.rBUGAqFStNaTMEyZfWADZRU8Sf0t5.2', 'admin'),
(3, 'agus@gmail.com', 'agus', '$2b$10$JGVIZGsQEqkOU7nC3/mZo.j4jimowVMkq3oan0IuCy893O9fgZ9sW', 'admin'),
(4, 'selly@gmail.com', 'selly', '$2b$10$HSLYRakAhTVwJN1dr6siOOb9ZQ8j.xJA.ifO/8ZpD0RmWe3Grpbre', 'admin'),
(5, 'syarif@gmail.com', 'syarif', '$2b$10$923sB79PimbNkgjJL5tIJeag4Hu5rQMR5Cjvf5bJRlZ/okG/G2.82', 'admin'),
(6, 'ikmal@gmail.com', 'ikmal', '$2b$10$2iZnzAWjXYu.bmPSm0Bdw.dqksqpw4TRUvUfc5g1dsyECJN2Vd8CO', 'user'),
(7, 'tes123@gmail.com', 'tes123', '$2b$10$P7JO.fEHiKRs/251wHDBeuY1U5YlRt8KDWIbLCyi6FKCLjfNDBBGG', 'admin'),
(8, 'user@gmail.com', 'user', '$2b$10$J1UtSuU4R/FD77B6hb0PYOacFBkIqZfPplSpbkcgIaSozbeINTonO', 'user');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `kategori`
--
ALTER TABLE `kategori`
  ADD PRIMARY KEY (`id`),
  ADD KEY `kategori_ibfk_1` (`dibuat_oleh`);

--
-- Indeks untuk tabel `papan_peringkat`
--
ALTER TABLE `papan_peringkat`
  ADD PRIMARY KEY (`id`),
  ADD KEY `papan_peringkat_ibfk_1` (`id_user`),
  ADD KEY `papan_peringkat_ibfk_2` (`id_kategori`);

--
-- Indeks untuk tabel `profile`
--
ALTER TABLE `profile`
  ADD PRIMARY KEY (`id`),
  ADD KEY `profile_ibfk_1` (`id_user`);

--
-- Indeks untuk tabel `skor`
--
ALTER TABLE `skor`
  ADD PRIMARY KEY (`id`),
  ADD KEY `skor_ibfk_1` (`id_user`),
  ADD KEY `skor_ibfk_2` (`id_kategori`);

--
-- Indeks untuk tabel `soal`
--
ALTER TABLE `soal`
  ADD PRIMARY KEY (`id`),
  ADD KEY `soal_ibfk_1` (`id_kategori`),
  ADD KEY `soal_ibfk_2` (`dibuat_oleh`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `kategori`
--
ALTER TABLE `kategori`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `papan_peringkat`
--
ALTER TABLE `papan_peringkat`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `profile`
--
ALTER TABLE `profile`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `skor`
--
ALTER TABLE `skor`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `soal`
--
ALTER TABLE `soal`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `kategori`
--
ALTER TABLE `kategori`
  ADD CONSTRAINT `kategori_ibfk_1` FOREIGN KEY (`dibuat_oleh`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `papan_peringkat`
--
ALTER TABLE `papan_peringkat`
  ADD CONSTRAINT `papan_peringkat_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `papan_peringkat_ibfk_2` FOREIGN KEY (`id_kategori`) REFERENCES `kategori` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `profile`
--
ALTER TABLE `profile`
  ADD CONSTRAINT `profile_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `skor`
--
ALTER TABLE `skor`
  ADD CONSTRAINT `skor_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `skor_ibfk_2` FOREIGN KEY (`id_kategori`) REFERENCES `kategori` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `soal`
--
ALTER TABLE `soal`
  ADD CONSTRAINT `soal_ibfk_1` FOREIGN KEY (`id_kategori`) REFERENCES `kategori` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `soal_ibfk_2` FOREIGN KEY (`dibuat_oleh`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
