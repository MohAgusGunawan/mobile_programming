import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Overlapping Images
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/2.png', // ganti dengan path gambar 2 (biru, kuning)
                    height: 380,
                    fit: BoxFit.cover,
                  ),
                  Image.asset(
                    'assets/images/flying.png', // ganti dengan path gambar burung
                    height: 450,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 40,
                    right: 20,
                    child: Image.asset(
                      'assets/images/1.png', // ganti dengan path gambar 1 (oranye, biru, hitam)
                      height: 140, // Ukuran gambar 1 dibuat kecil
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              // Stepper image
              Image.asset(
                'assets/images/stepper-1.png', // ganti dengan path gambar stepper Anda
                height: 7,
              ),
              // Text Content
              Column(
                children: [
                  Text(
                    'Discover the\npedigree of pet\nbirds!',
                    // textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Make the LABET Application easier to breed in\n'
                    'a relevant way and find offspring',
                    // textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              // Get Started Button
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Get Started',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
