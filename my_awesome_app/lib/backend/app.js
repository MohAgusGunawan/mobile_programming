// app.js
const express = require('express');
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
            user: { id: user.id, username: user.username },
            // token: 'fake-jwt-token', // Anda bisa mengganti ini dengan token asli jika menggunakan JWT
        });
    });
});

// Endpoint untuk register
app.post('/api/auth/register', async (req, res) => {
    const { email, username, password } = req.body;

    if (!email || !username || !password) {
        return res.status(400).json({ message: 'Email, Username, dan Password wajib diisi' });
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

        // Enkripsi password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insert ke database
        const insertQuery = 'INSERT INTO users (email, username, password) VALUES (?, ?, ?)';
        db.query(insertQuery, [email, username, hashedPassword], (err, result) => {
            if (err) {
                console.error('Error saat menyimpan data:', err);
                return res.status(500).json({ message: 'Gagal menyimpan data' });
            }
            res.status(201).json({ message: 'Registrasi berhasil' });
        });
    });
});

// Jalankan server
app.listen(port, () => {
    console.log(`Server berjalan di http://localhost:${port}`);
});
