import 'package:flutter/material.dart';
import 'package:my_awesome_app/screen/admin/dashboard_screen.dart';
import 'package:my_awesome_app/screen/admin/home_admin_screen.dart';
import 'package:my_awesome_app/screen/admin/kategori_screen.dart';
import 'package:my_awesome_app/screen/category_screen.dart';
import 'package:my_awesome_app/screen/home_screen.dart';
// import 'package:my_awesome_app/screen/detail_screen.dart';
import 'package:my_awesome_app/screen/login_screen.dart';
import 'package:my_awesome_app/screen/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kuis Pintar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        // auth
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),

        // user
        '/home': (context) => HomeScreen(),
        '/category': (context) => CategoryScreen(),

        // admin
        '/home_admin': (context) => HomeAdminScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/kategori': (context) => KategoriScreen(),
      },
    );
  }
}
