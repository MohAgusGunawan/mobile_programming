// app.js
const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const bodyParser = require('body-parser');
const cors = require('cors');
const db = require('./db/connection');
const bcrypt = require('bcrypt');

const app = express();
const port = 3000;

// Middleware
app.use(bodyParser.json());
app.use(cors());

// Endpoint untuk login
app.post('/api/auth/login', (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ message: 'Username dan password wajib diisi' });
    }

    const query = 'SELECT * FROM users WHERE username = ?';
    db.query(query, [username], async (err, results) => {
        if (err) {
            console.error('Error saat melakukan query:', err);
            return res.status(500).json({ message: 'Internal server error' });
        }

        if (results.length === 0) {
            return res.status(401).json({ message: 'Username tidak ditemukan' });
        }

        const user = results[0];

        // Periksa password
        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            return res.status(401).json({ message: 'Password salah' });
        }

        // Jika login berhasil
        return res.status(200).json({
            message: 'Login berhasil',
            user: { id: user.id, username: user.username, role: user.role },
            // token: 'fake-jwt-token', // Anda bisa mengganti ini dengan token asli jika menggunakan JWT
        });
    });
});

// Endpoint untuk register
app.post('/api/auth/register', async (req, res) => {
    const { email, username, password, role = 'user' } = req.body;

    if (!email || !username) {
        return res.status(400).json({ message: 'Email dan Username wajib diisi' });
    }

    const query = 'SELECT * FROM users WHERE username = ? OR email = ?';
    db.query(query, [username, email], async (err, results) => {
        if (err) {
            console.error('Error saat melakukan query:', err);
            return res.status(500).json({ message: 'Internal server error' });
        }

        if (results.length > 0) {
            return res.status(400).json({ message: 'Username atau Email sudah terdaftar' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const insertQuery = 'INSERT INTO users (email, username, password, role) VALUES (?, ?, ?, ?)';
        db.query(insertQuery, [email, username, hashedPassword, role], (err, result) => {
            if (err) {
                console.error('Error saat menyimpan data:', err);
                return res.status(500).json({ message: 'Gagal menyimpan data' });
            }
            res.status(201).json({ message: 'Registrasi berhasil' });
        });
    });
});

// Penyimpanan foto
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const folderPath = '../../assets/images/kategori/';
        cb(null, folderPath); // Direktori tujuan
    },
    filename: (req, file, cb) => {
        const uniqueName = Date.now() + '-' + file.originalname.replace(/\s+/g, '_'); // Nama file unik
        cb(null, uniqueName); // Simpan dengan nama unik
    },
});

// Filter file hanya untuk gambar
const fileFilter = (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    } else {
        cb(new Error('Only image files are allowed'), false);
    }
};

// Middleware untuk upload
const upload = multer({
    storage: storage,
    fileFilter: fileFilter,
});

// Endpoint untuk menambah kategori
app.post('/api/kategori', upload.single('foto'), async (req, res) => {
    const { nama_kategori, id } = req.body;
    const fotoName = req.file ? req.file.filename : null;

    if (!nama_kategori || !id) {
        return res.status(400).json({
            success: false,
            message: 'Data tidak lengkap. Nama kategori dan ID diperlukan.',
        });
    }

    try {
        // Simpan nama file saja di database
        const result = await db.query(
            'INSERT INTO kategori (nama_kategori, foto, dibuat_oleh) VALUES (?, ?, ?)',
            [nama_kategori, fotoName, id]
        );

        res.json({ success: true, message: 'Kategori berhasil ditambahkan' });
    } catch (error) {
        console.error('Database Error:', error);
        res.status(500).json({
            success: false,
            message: 'Kesalahan server saat menyimpan data.',
            error: error.message,
        });
    }
});

// Error handler untuk multer
app.use((err, req, res, next) => {
    if (err instanceof multer.MulterError) {
        return res.status(400).json({ success: false, message: err.message });
    } else if (err) {
        return res.status(400).json({ success: false, message: err.message });
    }
    next();
});

// Endpoint untuk mengambil data kategori
app.get('/api/kategori', async (req, res) => {
    try {
        // Menggunakan query untuk mengambil data kategori
        db.query('SELECT * FROM kategori', (err, results) => {
            if (err) {
                console.error(err);
                return res.status(500).json({
                    success: false,
                    message: 'Kesalahan server saat mengambil data.',
                    error: err.message
                });
            }
            // console.log('Kategori:', results); // Tambahkan log untuk memeriksa hasil query
            res.json(results); // Mengembalikan hasil query dalam format JSON
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({
            success: false,
            message: 'Kesalahan server saat mengambil data.',
            error: err.message
        });
    }
});

// Jalankan server
app.listen(port, () => {
    console.log(`Server berjalan di http://localhost:${port}`);
});
