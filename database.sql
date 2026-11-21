CREATE DATABASE IF NOT EXISTS adu_cloud_network;
USE adu_cloud_network;

-- 1. Taqsimlangan tarmoq tugunlari (filiallar va bulut markazi)
CREATE TABLE IF NOT EXISTS tarmoq_tugunlari (
    tugun_id INT AUTO_INCREMENT PRIMARY KEY,
    tugun_nomi VARCHAR(100) NOT NULL,
    hudud VARCHAR(100) NOT NULL,
    ip_manzil VARCHAR(45) NOT NULL,
    rol VARCHAR(50) NOT NULL, -- 'Bosh ofis', 'Filial', 'Cloud Server'
    holat VARCHAR(20) DEFAULT 'Online'
);

-- 2. Bulutli ma'lumotlar almashinuvi va sinxronizatsiya jurnali
CREATE TABLE IF NOT EXISTS malumot_almashinuvi (
    xabar_id INT AUTO_INCREMENT PRIMARY KEY,
    manba_tugun_id INT NOT NULL,
    maqsad_tugun_id INT NOT NULL,
    malumot_mazmuni VARCHAR(255) NOT NULL,
    protokol VARCHAR(30) DEFAULT 'HTTPS/TLS',
    yuborilgan_vaqt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    holat VARCHAR(20) DEFAULT 'Synced',
    FOREIGN KEY (manba_tugun_id) REFERENCES tarmoq_tugunlari(tugun_id),
    FOREIGN KEY (maqsad_tugun_id) REFERENCES tarmoq_tugunlari(tugun_id)
);

-- Boshlang'ich tugunlarni kiritish
INSERT INTO tarmoq_tugunlari (tugun_nomi, hudud, ip_manzil, rol, holat) VALUES
('Andijon_Bosh_Ofis', 'Andijon', '192.168.10.10', 'Bosh ofis', 'Online'),
('Toshkent_Filiali', 'Toshkent', '192.168.20.10', 'Filial', 'Online'),
('Markaziy_Cloud_Server', 'Cloud Region-1', '172.16.10.10', 'Cloud Server', 'Online');

-- Boshlang'ich sinxronizatsiya yozuvlari
INSERT INTO malumot_almashinuvi (manba_tugun_id, maqsad_tugun_id, malumot_mazmuni, protokol, holat) VALUES
(1, 3, 'Andijon ofisidan bulut bazasiga ilk sinxronizatsiya', 'HTTPS/TLS', 'Synced'),
(2, 3, 'Toshkent filialidan markaziy bazaga hisobot yuborildi', 'IPsec/HTTPS', 'Synced');

-- Test so'rovlari:
-- 1) Barcha tugunlar:
SELECT * FROM tarmoq_tugunlari;

-- 2) Yangi yozuv qo'shish:
INSERT INTO malumot_almashinuvi (manba_tugun_id, maqsad_tugun_id, malumot_mazmuni, protokol, holat)
VALUES (1, 3, 'Yangi filial sozlamalari bulutda yangilandi', 'HTTPS/TLS', 'Synced');

-- 3) Tugunlar bo'yicha ma'lumot almashinuvi jurnali:
SELECT
    m.xabar_id,
    t1.tugun_nomi AS manba,
    t1.ip_manzil AS manba_ip,
    t2.tugun_nomi AS maqsad,
    t2.ip_manzil AS maqsad_ip,
    m.malumot_mazmuni,
    m.protokol,
    m.holat,
    m.yuborilgan_vaqt
FROM malumot_almashinuvi m
JOIN tarmoq_tugunlari t1 ON m.manba_tugun_id = t1.tugun_id
JOIN tarmoq_tugunlari t2 ON m.maqsad_tugun_id = t2.tugun_id
ORDER BY m.xabar_id DESC;
