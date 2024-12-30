import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BottomNavigationAdmin extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigationAdmin({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: currentIndex,
      backgroundColor: Colors.white, // Transparansi untuk efek melengkung
      color: const Color.fromARGB(255, 0, 37, 245), // Warna bar navigasi
      buttonBackgroundColor:
          const Color.fromARGB(255, 1, 17, 247), // Warna tombol aktif
      height: 50, // Tinggi untuk melengkung lebih jelas
      items: [
        _buildNavItem(Icons.folder, 'Soal', currentIndex == 0),
        _buildNavItem(Icons.category, 'Kategori', currentIndex == 1),
        _buildNavItem(Icons.home, 'Home', currentIndex == 2),
        _buildNavItem(Icons.people, 'Pengguna', currentIndex == 3),
        _buildNavItem(Icons.person, 'Profile', currentIndex == 4),
      ],
      onTap: onTap,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 600),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Container(
      width: 80,
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
