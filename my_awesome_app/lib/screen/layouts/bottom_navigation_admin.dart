import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:my_awesome_app/screen/admin/kategori_screen.dart';
import 'package:my_awesome_app/screen/admin/pengguna_screen.dart';
import 'package:my_awesome_app/screen/admin/dashboard_screen.dart';
import 'package:my_awesome_app/screen/admin/profile_screen.dart';
import 'package:my_awesome_app/screen/admin/soal_screen.dart';

class BottomNavigationAdmin extends StatefulWidget {
  @override
  _BottomNavigationAdminState createState() => _BottomNavigationAdminState();
}

class _BottomNavigationAdminState extends State<BottomNavigationAdmin> {
  int _currentIndex = 2; // Default ke Dashboard
  bool _isInitialPageSet = false;

  final List<Widget> _pages = [
    SoalScreen(),
    KategoriScreen(),
    DashboardScreen(),
    PenggunaScreen(),
    ProfileScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialPageSet) {
      final int? initialPage =
          ModalRoute.of(context)?.settings.arguments as int?;
      if (initialPage != null && initialPage != _currentIndex) {
        setState(() {
          _currentIndex = initialPage;
          _isInitialPageSet = true; // Pastikan hanya dijalankan sekali
        });
      }
    }
  }

  void _selectPage(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Tampilkan halaman berdasarkan index
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        backgroundColor: Colors.white,
        color: const Color.fromARGB(255, 0, 37, 245),
        buttonBackgroundColor: const Color.fromARGB(255, 1, 17, 247),
        height: 50,
        items: [
          _buildNavItem(Icons.folder, 'Soal', _currentIndex == 0),
          _buildNavItem(Icons.category, 'Kategori', _currentIndex == 1),
          _buildNavItem(Icons.home, 'Dashboard', _currentIndex == 2),
          _buildNavItem(Icons.people, 'Pengguna', _currentIndex == 3),
          _buildNavItem(Icons.person, 'Profile', _currentIndex == 4),
        ],
        onTap: _selectPage, // Panggil fungsi untuk mengubah halaman
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Container(
      width: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30,
            color: isSelected ? Colors.white : Colors.black,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
