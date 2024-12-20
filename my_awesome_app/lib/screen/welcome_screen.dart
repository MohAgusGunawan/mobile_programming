import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF37474F), // Warna latar belakang biru tua
      appBar: AppBar(
        backgroundColor: const Color(0xFF37474F),
        centerTitle: true, // Pusatkan ikon atau teks di AppBar
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.warning, color: Colors.yellow),
            onPressed: () {
              // Tambahkan aksi ikon di sini
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Selamat Datang di Aplikasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Game Quiz Pintar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aksi tombol Mulai Bermain
              },
              child: const Text('Mulai Bermain'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0, // Tinggi untuk menjaga ikon tetap di tengah
        items: <Widget>[
          _buildIcon(Icons.home, 0),
          _buildIcon(Icons.emoji_events, 1),
          _buildIcon(Icons.show_chart, 2),
          _buildIcon(Icons.person, 3),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.transparent,
        backgroundColor: const Color(0xFF37474F),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _controller.forward(from: 0.0); // Animasi ikon aktif
          });
        },
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    final isActive = index == _currentIndex;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animationValue =
            isActive ? 1.0 - _controller.value : _controller.value;
        return Transform.translate(
          offset: Offset(0, 6 * animationValue),
          child: Center(
            child: Icon(
              icon,
              size: 30,
              color: isActive ? Colors.amber[800] : Colors.black,
            ),
          ),
        );
      },
    );
  }
}
