import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:my_awesome_app/screen/home_screen.dart';
import 'package:my_awesome_app/screen/ranking_screen.dart';
import 'package:my_awesome_app/screen/statistic_screen.dart';
import 'package:my_awesome_app/screen/profil_screen.dart';

class BottomNavigationWidget extends StatefulWidget {
  @override
  _BottomNavigationWidgetState createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    RankingScreen(),
    StatisticScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        backgroundColor: Colors.white,
        color: const Color.fromARGB(255, 0, 37, 245),
        buttonBackgroundColor: const Color.fromARGB(255, 1, 17, 247),
        height: 50,
        items: [
          _buildNavItem(Icons.home, 'Home', _currentIndex == 0),
          _buildNavItem(Icons.emoji_events, 'Ranking', _currentIndex == 1),
          _buildNavItem(Icons.show_chart, 'Statistics', _currentIndex == 2),
          _buildNavItem(Icons.person, 'Profile', _currentIndex == 3),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
