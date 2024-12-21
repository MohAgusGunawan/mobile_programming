import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8E44AD),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.warning,
              color: Colors.yellow,
            ),
            onPressed: () {
              // Tambahkan aksi untuk ikon warning di sini
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8E44AD), // Ungu
              Color(0xFF3498DB), // Biru
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Selamat Datang Di Aplikasi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Game Kuis Pintar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Aksi tombol Mulai Bermain
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Mulai Bermain',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        backgroundColor:
            Color(0xFF3498DB), // Transparansi untuk efek melengkung
        color: Colors.white, // Warna bar navigasi
        buttonBackgroundColor: Colors.white, // Warna tombol aktif
        height: 60, // Tinggi untuk melengkung lebih jelas
        items: [
          Icon(Icons.home,
              size: 30,
              color:
                  _currentIndex == 0 ? const Color(0xFF8E44AD) : Colors.grey),
          Icon(Icons.emoji_events,
              size: 30,
              color:
                  _currentIndex == 1 ? const Color(0xFF8E44AD) : Colors.grey),
          Icon(Icons.show_chart,
              size: 30,
              color:
                  _currentIndex == 2 ? const Color(0xFF8E44AD) : Colors.grey),
          Icon(Icons.person,
              size: 30,
              color:
                  _currentIndex == 3 ? const Color(0xFF8E44AD) : Colors.grey),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
      ),
    );
  }
}
