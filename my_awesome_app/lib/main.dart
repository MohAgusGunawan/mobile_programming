import 'package:flutter/material.dart';
// import 'package:my_awesome_app/screen/detail_screen.dart';
// import 'package:my_awesome_app/screen/home_screen.dart';
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
      title: 'Demo Routing & HTTP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => LoginScreen());
        }
        if (settings.name == '/register') {
          return MaterialPageRoute(builder: (context) => RegisterScreen());
        }
        return null;
      },
    );
  }
}
