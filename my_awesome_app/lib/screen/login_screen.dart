import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF7A94AD),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Selamat Datang Di Aplikasi\nQuiz Pintar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                decoration: InputDecoration(
                  hintText: "Username",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "LOGIN",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1, // Ketebalan garis
                      color: Colors.black26, // Warna garis
                      indent: 20, // Jarak dari kiri
                      endIndent: 10, // Jarak menuju teks
                    ),
                  ),
                  Text(
                    'Lanjut Dengan Akun',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1, // Ketebalan garis
                      color: Colors.black26, // Warna garis
                      indent: 10, // Jarak menuju teks
                      endIndent: 20, // Jarak dari kanan
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        EdgeInsets.all(8), // Padding untuk jarak di dalam box
                    decoration: BoxDecoration(
                      color: Colors.white, // Warna box putih
                      borderRadius:
                          BorderRadius.circular(8), // Sudut melengkung
                    ),
                    child: Image.asset(
                      'assets/images/google.jpg',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  SizedBox(width: 20), // Jarak antar box

                  Container(
                    padding:
                        EdgeInsets.all(8), // Padding untuk jarak di dalam box
                    decoration: BoxDecoration(
                      color: Colors.white, // Warna box putih
                      borderRadius:
                          BorderRadius.circular(8), // Sudut melengkung
                    ),
                    child: Image.asset(
                      'assets/images/apple.jpg',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  SizedBox(width: 20), // Jarak antar box

                  Container(
                    padding:
                        EdgeInsets.all(8), // Padding untuk jarak di dalam box
                    decoration: BoxDecoration(
                      color: Colors.white, // Warna box putih
                      borderRadius:
                          BorderRadius.circular(8), // Sudut melengkung
                    ),
                    child: Image.asset(
                      'assets/images/fb.jpg',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              RichText(
                text: const TextSpan(
                  text: "Dont Have An Account? ",
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Register Now",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
