import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> categories = [
      {
        "title": "Pengetahuan Umum",
        "image": "assets/images/umum.png",
      },
      {
        "title": "Matematika",
        "image": "assets/images/matematika.png",
      },
      {
        "title": "Bahasa Inggris",
        "image": "assets/images/inggris.png",
      },
      {
        "title": "Agama Islam",
        "image": "assets/images/agama.png",
      },
      {
        "title": "Bahasa Indonesia",
        "image": "assets/images/indo.png",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8E44AD),
        title: const Text(
          "PILIH KATEGORI SOAL",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFF8E44AD),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Aksi saat kategori dipilih
                print("Kategori: ${categories[index]['title']}");
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      child: Image.asset(
                        categories[index]["image"]!,
                        height: 50,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      categories[index]["title"]!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
