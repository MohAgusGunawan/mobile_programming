// db/connection.js
const mysql = require('mysql');

// Konfigurasi koneksi ke database
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'kuis_pintar',
});

// Cek koneksi ke database
db.connect((err) => {
    if (err) {
        console.error('Koneksi database gagal:', err);
        return;
    }
    console.log('Terhubung ke database MySQL');
});

module.exports = db; // Ekspor koneksi database untuk digunakan di file lain
