import 'package:flutter/material.dart';
import 'package:my_awesome_app/screen/layouts/bottom_navigation_admin.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 2;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header bagian atas
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color(0xFF4A00E0), // Warna biru gelap
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hi, Admin",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: const [
                              Icon(
                                Icons.email,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "admin@gmail.com",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/profile.png'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Tombol kategori soal
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildDashboardCard(
                  title: "5 KATEGORI SOAL",
                  color: const Color(0xFFFF007A), // Pink
                  icon: Icons.folder,
                  onTap: () {
                    Navigator.pushNamed(context, '/kategori');
                  },
                ),
                const SizedBox(height: 16),
                _buildDashboardCard(
                  title: "SOAL",
                  color: const Color(0xFF00FF00), // Hijau
                  icon: Icons.help_outline,
                  onTap: () {
                    // Aksi untuk soal
                  },
                ),
                const SizedBox(height: 16),
                _buildDashboardCard(
                  title: "10 PENGGUNA",
                  color: const Color(0xFF333333), // Hitam
                  icon: Icons.person,
                  onTap: () {
                    // Aksi untuk pengguna
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      // Navigasi bawah
      bottomNavigationBar: BottomNavigationAdmin(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  // Widget untuk kartu dashboard
  Widget _buildDashboardCard({
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(
              Icons.play_arrow,
              size: 30,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
