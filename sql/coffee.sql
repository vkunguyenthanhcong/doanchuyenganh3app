-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 14, 2024 at 07:37 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `coffee`
--

-- --------------------------------------------------------

--
-- Table structure for table `bill`
--

CREATE TABLE `bill` (
  `id` int(100) NOT NULL,
  `idban` int(100) NOT NULL,
  `idmon` int(100) NOT NULL,
  `giovao` datetime NOT NULL,
  `giora` datetime DEFAULT NULL,
  `idhoadon` varchar(100) DEFAULT NULL,
  `soluong` int(100) NOT NULL,
  `tinhtrang` int(100) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bill`
--

INSERT INTO `bill` (`id`, `idban`, `idmon`, `giovao`, `giora`, `idhoadon`, `soluong`, `tinhtrang`) VALUES
(7, 2, 12, '2024-05-14 12:34:20', '2024-05-14 12:35:58', '12342014052024ban2', 1, 1),
(8, 2, 12, '2024-05-14 12:34:20', '2024-05-14 12:35:58', '12342014052024ban2', 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `hoadon`
--

CREATE TABLE `hoadon` (
  `id` int(100) NOT NULL,
  `idhoadon` varchar(100) NOT NULL,
  `nhanvien` varchar(100) NOT NULL,
  `tongtien` int(100) NOT NULL,
  `giovao` datetime NOT NULL,
  `giora` datetime NOT NULL,
  `idban` int(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `hoadon`
--

INSERT INTO `hoadon` (`id`, `idhoadon`, `nhanvien`, `tongtien`, `giovao`, `giora`, `idban`) VALUES
(1, '17004813052024ban2', 'admin', 75000, '2024-05-13 17:00:48', '0000-00-00 00:00:00', 2),
(2, '12342014052024ban2', 'admin', 30000, '2024-05-14 12:34:20', '2024-05-14 12:35:58', 2);

-- --------------------------------------------------------

--
-- Table structure for table `loaisanpham`
--

CREATE TABLE `loaisanpham` (
  `id` int(100) NOT NULL,
  `tenloai` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `loaisanpham`
--

INSERT INTO `loaisanpham` (`id`, `tenloai`) VALUES
(1, 'Nước Ngọt'),
(4, 'Trà Sữa');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(100) NOT NULL,
  `ten` varchar(100) NOT NULL,
  `loai` int(100) NOT NULL,
  `image` varchar(100) NOT NULL,
  `gia` int(100) NOT NULL,
  `soluong` int(100) NOT NULL DEFAULT 0,
  `hot` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `ten`, `loai`, `image`, `gia`, `soluong`, `hot`) VALUES
(12, 'Coca', 1, 'image/Coca.png', 15000, 10, 0);

-- --------------------------------------------------------

--
-- Table structure for table `tableorder`
--

CREATE TABLE `tableorder` (
  `id` int(100) NOT NULL,
  `ten` varchar(100) NOT NULL,
  `tinhtrang` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tableorder`
--

INSERT INTO `tableorder` (`id`, `ten`, `tinhtrang`) VALUES
(2, 'Bàn 1', 0);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(100) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `roll` int(10) NOT NULL DEFAULT 0,
  `fullname` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `roll`, `fullname`) VALUES
(1, 'admin', 'admin', 0, 'Công'),
(8, 'admin1', 'admin1', 0, 'công'),
(9, 'ntc1309', 'ntc1309', 0, 'hhhhh');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bill`
--
ALTER TABLE `bill`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `hoadon`
--
ALTER TABLE `hoadon`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `loaisanpham`
--
ALTER TABLE `loaisanpham`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tableorder`
--
ALTER TABLE `tableorder`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bill`
--
ALTER TABLE `bill`
  MODIFY `id` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `hoadon`
--
ALTER TABLE `hoadon`
  MODIFY `id` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `loaisanpham`
--
ALTER TABLE `loaisanpham`
  MODIFY `id` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `tableorder`
--
ALTER TABLE `tableorder`
  MODIFY `id` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
