import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_awesome_app/service/api_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = loadDashboardData();
  }

  Future<Map<String, dynamic>> loadDashboardData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('id') ?? 0;

    if (userId == 0) {
      throw Exception('User ID tidak ditemukan');
    }

    return await ApiService().fetchDashboardData(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          final data = snapshot.data!;
          return Column(
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
                              Text(
                                "Hi, ${data['nama'] ?? data['username']}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.email,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    data['email'],
                                    style: const TextStyle(
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
                          backgroundImage: NetworkImage(
                            'http://192.168.94.110/mobile_programming/my_awesome_app/assets/images/profile/${data['foto'] ?? 'person.jpg'}',
                          ),
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
                  controller: ScrollController(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    _buildDashboardCard(
                      title: "${data['jumlah_kategori']} KATEGORI SOAL",
                      color: const Color(0xFFFF007A), // Pink
                      icon: Icons.folder,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/bottom',
                          arguments: 1,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDashboardCard(
                      title: "SOAL",
                      color: const Color(0xFF00FF00), // Hijau
                      icon: Icons.help_outline,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/bottom',
                          arguments: 0,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDashboardCard(
                      title: "${data['jumlah_pengguna']} PENGGUNA",
                      color: const Color(0xFF333333), // Hitam
                      icon: Icons.person,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/bottom',
                          arguments: 3,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
