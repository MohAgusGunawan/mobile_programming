import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:my_awesome_app/screen/home_screen.dart';
import 'package:my_awesome_app/screen/category_screen.dart';

class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigationWidget({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: currentIndex,
      backgroundColor:
          const Color(0xFF3498DB), // Transparansi untuk efek melengkung
      color: Colors.white, // Warna bar navigasi
      buttonBackgroundColor: Colors.white, // Warna tombol aktif
      height: 50, // Tinggi untuk melengkung lebih jelas
      items: [
        _buildNavItem(Icons.home, 'Home', currentIndex == 0),
        _buildNavItem(Icons.emoji_events, 'Ranking', currentIndex == 1),
        _buildNavItem(Icons.show_chart, 'Statistics', currentIndex == 2),
        _buildNavItem(Icons.person, 'Profile', currentIndex == 3),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
            break;
          case 1:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CategoryScreen()));
            break;
          case 2:
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
            break;
          case 3:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CategoryScreen()));
            break;
        }
      },
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
            color: isSelected ? const Color(0xFF8E44AD) : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isSelected ? const Color(0xFF8E44AD) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
