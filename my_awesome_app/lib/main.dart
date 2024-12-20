import 'package:flutter/material.dart';
// import 'package:my_awesome_app/screen/detail_screen.dart';
// import 'package:my_awesome_app/screen/home_screen.dart';
import 'package:my_awesome_app/screen/login_screen.dart';
import 'package:my_awesome_app/screen/register_screen.dart';
import 'package:my_awesome_app/screen/welcome_screen.dart';

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
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/welcome': (context) => WelcomeScreen(),
      },
    );
  }
}
