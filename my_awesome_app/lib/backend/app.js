// app.js
const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const bodyParser = require('body-parser');
const cors = require('cors');
const db = require('./db/connection');
const bcrypt = require('bcrypt');
const helmet = require('helmet');

const app = express();
const port = 3000;


// Middleware
app.use(bodyParser.json());
app.use(helmet());

app.use(cors({
    origin: "*",
    credentials: true,
}));


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

        const insertUserQuery = 'INSERT INTO users (email, username, password, role) VALUES (?, ?, ?, ?)';
        db.query(insertUserQuery, [email, username, hashedPassword, role], (err, result) => {
            if (err) {
                console.error('Error saat menyimpan data:', err);
                return res.status(500).json({ message: 'Gagal menyimpan data' });
            }

            // Ambil ID user yang baru saja dibuat
            const userId = result.insertId;

            // Insert data ke tabel profile
            const insertProfileQuery = 'INSERT INTO profile (id_user) VALUES (?)';
            db.query(insertProfileQuery, [userId], (err) => {
                if (err) {
                    console.error('Error saat menyimpan data profile:', err);
                    return res.status(500).json({ message: 'Gagal menyimpan data profile' });
                }

                res.status(201).json({ message: 'Registrasi berhasil' });
            });
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
const storage2 = multer.diskStorage({
    destination: (req, file, cb) => {
        const folderPath = '../../assets/images/soal/';
        cb(null, folderPath); // Direktori tujuan
    },
    filename: (req, file, cb) => {
        const uniqueName = Date.now() + '-' + file.originalname.replace(/\s+/g, '_'); // Nama file unik
        cb(null, uniqueName); // Simpan dengan nama unik
    },
});
const storage3 = multer.diskStorage({
    destination: (req, file, cb) => {
        const folderPath = '../../assets/images/profile/';
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
const upload2 = multer({
    storage: storage2,
    fileFilter: fileFilter,
});
const upload3 = multer({
    storage: storage3,
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

// Endpoint untuk mendapatkan data pengguna
app.get('/api/users', (req, res) => {
    const query = 'SELECT * FROM users'; // Ganti 'users' dengan nama tabel pengguna Anda

    db.query(query, (err, results) => {
        if (err) {
            console.error('Error saat mengambil data pengguna:', err);
            res.status(500).json({
                status: 'error',
                message: 'Gagal mengambil data pengguna',
            });
        } else {
            res.status(200).json({
                status: 'success',
                data: results,
            });
        }
    });
});

// Route: Edit kategori
app.put('/api/kategori/:id', upload.single('foto'), (req, res) => {
    const { id } = req.params;
    const { nama_kategori } = req.body;
    const fotoBaru = req.file ? req.file.filename : null;

    // Ambil foto lama dari database
    const getFotoQuery = 'SELECT foto FROM kategori WHERE id = ?';
    db.query(getFotoQuery, [id], (err, results) => {
        if (err) {
            console.error('Error saat mengambil data kategori:', err);
            return res.status(500).json({ message: 'Error saat mengambil data kategori' });
        }

        if (results.length === 0) {
            return res.status(404).json({ message: 'Kategori tidak ditemukan' });
        }

        const fotoLama = results[0].foto;
        const updateFields = [];
        const values = [];

        // Tambahkan field yang akan diperbarui
        if (nama_kategori) {
            updateFields.push('nama_kategori = ?');
            values.push(nama_kategori);
        }
        if (fotoBaru) {
            updateFields.push('foto = ?');
            values.push(fotoBaru);
        }

        if (updateFields.length === 0) {
            return res.status(400).json({ message: 'Tidak ada field untuk diperbarui' });
        }

        values.push(id);

        const updateQuery = `UPDATE kategori SET ${updateFields.join(', ')} WHERE id = ?`;

        // Hapus foto lama jika ada foto baru
        db.query(updateQuery, values, (err) => {
            if (err) {
                console.error('Error saat memperbarui kategori:', err);
                return res.status(500).json({ message: 'Error saat memperbarui kategori' });
            }

            if (fotoBaru && fotoLama) {
                const fotoLamaPath = path.join(__dirname, '../../assets/images/kategori/', fotoLama);

                // Hapus file foto lama
                fs.unlink(fotoLamaPath, (err) => {
                    if (err) {
                        console.error('Error saat menghapus foto lama:', err);
                        // Tidak perlu menghentikan proses jika gagal menghapus file
                    }
                });
            }

            res.json({ message: 'Kategori berhasil diperbarui' });
        });
    });
});

// Endpoint untuk mendapatkan soal berdasarkan kategori
app.get('/api/soal', (req, res) => {
    const kategoriId = req.query.kategori_id;

    if (!kategoriId) {
        return res.status(400).json({ message: 'kategori_id diperlukan' });
    }

    const query = `
      SELECT s.*, s.id_kategori, k.nama_kategori 
      FROM soal s
      JOIN kategori k ON s.id_kategori = k.id
      WHERE s.id_kategori = ?
    `;

    db.query(query, [kategoriId], (err, results) => {
        if (err) {
            console.error('Error fetching soal:', err);
            return res.status(500).json({ message: 'Error fetching soal' });
        }

        res.json(results);
    });
});

// Endpoint untuk menambahkan soal
app.post('/api/soal', upload2.single('gambar'), async (req, res) => {
    const { id_kategori, soal, opsi_a, opsi_b, opsi_c, opsi_d, id_jawaban, id } = req.body;
    const gambar = req.file ? req.file.filename : null;
    try {
        const result = await db.query(
            'INSERT INTO soal (id_kategori, soal, gambar, opsi_a, opsi_b, opsi_c, opsi_d, id_jawaban, dibuat_oleh) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [id_kategori, soal, gambar, opsi_a, opsi_b, opsi_c, opsi_d, id_jawaban, id]
        );

        res.status(200).json({ message: 'Soal berhasil ditambahkan' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Gagal menambahkan soal' });
    }
});

// Route: Edit soal
app.put('/api/soal/:id', upload2.single('gambar'), (req, res) => {
    const { id } = req.params;
    const { id_kategori, soal, opsi_a, opsi_b, opsi_c, opsi_d, id_jawaban } = req.body;
    const gambarBaru = req.file ? req.file.filename : null;

    // Ambil gambar lama dari database
    const getGambarQuery = 'SELECT gambar FROM soal WHERE id = ?';
    db.query(getGambarQuery, [id], (err, results) => {
        if (err) {
            console.error('Error saat mengambil data soal:', err);
            return res.status(500).json({ message: 'Error saat mengambil data soal' });
        }

        if (results.length === 0) {
            return res.status(404).json({ message: 'Soal tidak ditemukan' });
        }

        const gambarLama = results[0].gambar;
        const updateFields = [];
        const values = [];

        // Tambahkan field yang akan diperbarui
        if (id_kategori) {
            updateFields.push('id_kategori = ?');
            values.push(id_kategori);
        }
        if (soal) {
            updateFields.push('soal = ?');
            values.push(soal);
        }
        if (opsi_a) {
            updateFields.push('opsi_a = ?');
            values.push(opsi_a);
        }
        if (opsi_b) {
            updateFields.push('opsi_b = ?');
            values.push(opsi_b);
        }
        if (opsi_c) {
            updateFields.push('opsi_c = ?');
            values.push(opsi_c);
        }
        if (opsi_d) {
            updateFields.push('opsi_d = ?');
            values.push(opsi_d);
        }
        if (id_jawaban) {
            updateFields.push('id_jawaban = ?');
            values.push(id_jawaban);
        }
        if (gambarBaru) {
            updateFields.push('gambar = ?');
            values.push(gambarBaru);
        }

        if (updateFields.length === 0) {
            return res.status(400).json({ message: 'Tidak ada field untuk diperbarui' });
        }

        values.push(id);

        const updateQuery = `UPDATE soal SET ${updateFields.join(', ')} WHERE id = ?`;

        // Jalankan query untuk memperbarui soal
        db.query(updateQuery, values, (err) => {
            if (err) {
                console.error('Error saat memperbarui soal:', err);
                return res.status(500).json({ message: 'Error saat memperbarui soal' });
            }

            // Hapus gambar lama jika ada gambar baru
            if (gambarBaru && gambarLama) {
                const gambarLamaPath = path.join(__dirname, '../../assets/images/soal/', gambarLama);

                // Hapus file gambar lama
                fs.unlink(gambarLamaPath, (err) => {
                    if (err) {
                        console.error('Error saat menghapus gambar lama:', err);
                        // Tidak perlu menghentikan proses jika gagal menghapus file
                    }
                });
            }

            res.json({ message: 'Soal berhasil diperbarui' });
        });
    });
});

// Hapus soal
app.delete('/api/soal/:id', (req, res) => {
    const { id } = req.params;

    // Ambil gambar dari database sebelum menghapus soal
    const getGambarQuery = 'SELECT gambar FROM soal WHERE id = ?';
    db.query(getGambarQuery, [id], (err, results) => {
        if (err) {
            console.error('Error saat mengambil data soal:', err);
            return res.status(500).json({ message: 'Error saat mengambil data soal' });
        }

        if (results.length === 0) {
            return res.status(404).json({ message: 'Soal tidak ditemukan' });
        }

        const gambar = results[0].gambar;

        // Hapus soal dari database
        const deleteQuery = 'DELETE FROM soal WHERE id = ?';
        db.query(deleteQuery, [id], (err) => {
            if (err) {
                console.error('Error saat menghapus soal:', err);
                return res.status(500).json({ message: 'Error saat menghapus soal' });
            }

            // Hapus gambar jika ada
            if (gambar) {
                const gambarPath = path.join(__dirname, '../../assets/images/soal/', gambar);
                fs.unlink(gambarPath, (err) => {
                    if (err) {
                        console.error('Error saat menghapus gambar:', err);
                        // Tidak perlu menghentikan proses jika gagal menghapus file
                    }
                });
            }

            res.status(200).json({ message: 'Soal berhasil dihapus' });
        });
    });
});

// Endpoint untuk mendapatkan Profile Pengguna
app.get('/api/profile', (req, res) => {
    const userId = req.query.user_id;

    if (!userId) {
        return res.status(400).json({ message: 'user_id diperlukan' });
    }

    const query = `
      SELECT p.*, p.id_user, u.email, u.id, u.email, u.username
      FROM profile p
      JOIN users u ON p.id_user = u.id
      WHERE p.id_user = ?
    `;

    db.query(query, [userId], (err, results) => {
        if (err) {
            console.error('Error fetching soal:', err);
            return res.status(500).json({ message: 'Error fetching soal' });
        }

        res.json(results);
    });
});

app.put('/api/profile/:id', upload3.single('foto'), (req, res) => {
    const { id } = req.params;
    const { nama, tanggal_lahir, jenis_kelamin, bio } = req.body;
    const fotoBaru = req.file ? req.file.filename : null;

    // Ambil foto lama dari database
    const getFotoQuery = 'SELECT foto FROM profile WHERE id_user = ?';
    db.query(getFotoQuery, [id], (err, results) => {
        if (err) {
            console.error('Error saat mengambil data profile:', err);
            return res.status(500).json({ message: 'Error saat mengambil data profile' });
        }

        if (results.length === 0) {
            return res.status(404).json({ message: 'Profile tidak ditemukan' });
        }

        const fotoLama = results[0].foto;
        const updateFields = [];
        const values = [];

        if (nama) {
            updateFields.push('nama = ?');
            values.push(nama);
        }
        if (tanggal_lahir) {
            updateFields.push('tanggal_lahir = ?');
            values.push(tanggal_lahir);
        }
        if (jenis_kelamin) {
            updateFields.push('jenis_kelamin = ?');
            values.push(jenis_kelamin);
        }
        if (bio) {
            updateFields.push('bio = ?');
            values.push(bio);
        }
        if (fotoBaru) {
            updateFields.push('foto = ?');
            values.push(fotoBaru);
        }

        if (updateFields.length === 0 && !fotoBaru) {
            return res.status(400).json({ message: 'Tidak ada field untuk diperbarui' });
        }

        values.push(id);

        const updateQuery = `UPDATE profile SET ${updateFields.join(', ')} WHERE id_user = ?`;

        // Jalankan query untuk memperbarui profile
        db.query(updateQuery, values, (err) => {
            if (err) {
                console.error('Error saat memperbarui profile:', err);
                return res.status(500).json({ message: 'Error saat memperbarui profile' });
            }

            // Hapus gambar lama jika ada gambar baru
            if (fotoBaru && fotoLama && fotoBaru !== fotoLama) {
                const fotoLamaPath = path.join(__dirname, '../../assets/images/profile/', fotoLama);
                fs.unlink(fotoLamaPath, (err) => {
                    if (err) {
                        console.error('Error saat menghapus foto lama:', err);
                    }
                });
            }

            res.json({ message: 'Foto berhasil diperbarui' });
        });
    });
});

// Jalankan server
app.listen(port, () => {
    console.log(`Server berjalan di http://localhost:${port}`);
});