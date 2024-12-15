import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> Login(BuildContext context) async {
    final username = usernameController.text;
    final password = passwordController.text;

    final response = await http.post(
      Uri.parse('https://api.unira.ac.id/v1/token'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final message = data['message'];
      final token = data['token'];
      print('Message: $message');
      print('Token: $token');
      print(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login Success'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print('Failed to login');
      print(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to login'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        height: double.infinity,
        width: double.infinity,
        decoration:
            const BoxDecoration(color: Color.fromARGB(255, 253, 253, 253)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login Kuis Pintar',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0)),
            ),
            const SizedBox(
              height: 20,
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person),
                      labelText: 'NIS / NIM',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'NIS / NIM tidak boleh kosong' : null,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: 'Password / PIN',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) => value!.isEmpty
                        ? 'Password / PIN tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final username = usernameController.text;
                        final password = passwordController.text;
                        print('Username: $username');
                        print('Password: $password');
                        Login(context);
                      }
                    },
                    icon: const Icon(Icons.login),
                    label: const Text(
                      'Login',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
