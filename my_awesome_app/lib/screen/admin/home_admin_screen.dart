import 'package:flutter/material.dart';

class HomeAdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Latar Belakang Biru
          Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: const Color(0xFF4A00E0), // Warna biru gelap
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          // Pembatas dengan Lengkungan Halus
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: SmoothQuadCurveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height *
                    0.76, // Tinggi area lengkungan
                color: const Color(0xFF4A00E0),
              ),
            ),
          ),
          // Konten
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon Buku
                Image.asset(
                  'assets/images/book.png', // Ganti dengan path ikon Anda
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 150),
                // Teks Judul
                const Text(
                  "Kelola data Kuis dan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  "Pengguna",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                // Tombol Get Started
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF007A), // Pink
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper untuk Lengkungan Halus dengan 4 Lengkungan
class SmoothQuadCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.4); // Titik awal dari garis

    // Lengkungan pertama
    path.quadraticBezierTo(
      size.width * 0.125, size.height * 0.3, // Kontrol ke atas
      size.width * 0.25, size.height * 0.4, // Akhir turun
    );

    // Lengkungan kedua
    path.quadraticBezierTo(
      size.width * 0.375, size.height * 0.5, // Kontrol ke atas
      size.width * 0.5, size.height * 0.4, // Akhir turun
    );

    // Lengkungan ketiga
    path.quadraticBezierTo(
      size.width * 0.625, size.height * 0.3, // Kontrol ke atas
      size.width * 0.75, size.height * 0.4, // Akhir turun
    );

    // Lengkungan keempat
    path.quadraticBezierTo(
      size.width * 0.875, size.height * 0.5, // Kontrol ke atas
      size.width, size.height * 0.4, // Akhir turun
    );

    path.lineTo(size.width, 0); // Garis horizontal bagian atas
    path.close(); // Tutup jalur
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
