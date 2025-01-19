import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final int skor;
  final VoidCallback onRestart;

  const ResultScreen({
    Key? key,
    required this.skor,
    required this.onRestart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tentukan gambar dan pesan berdasarkan skor
    String imagePath =
        skor < 50 ? 'assets/images/sedih.png' : 'assets/images/senang.png';
    String message = skor < 50 ? 'Belajar lagi ya dek...!!!' : 'Kerja Bagus...';

    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 1, 17, 247),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath, // Menggunakan variable imagePath
                width: 100, // Ukuran gambar
                height: 100, // Ukuran gambar
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Skor Anda : $skor' + ' Poin',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/ranking');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 13, 233, 21),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Peringkat',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onRestart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Main Ulang',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
