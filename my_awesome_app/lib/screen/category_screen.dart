import 'package:flutter/material.dart';
import 'package:my_awesome_app/service/api_service.dart';
import 'kuis_screen.dart';

class CategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: ApiService().fetchKategori(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Terjadi kesalahan: ${snapshot.error}"),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("Tidak ada kategori yang tersedia."),
              );
            }

            final categories = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: ApiService().fetchSoal(category['id']),
                  builder: (context, soalSnapshot) {
                    bool hasSoal =
                        soalSnapshot.hasData && soalSnapshot.data!.isNotEmpty;

                    return GestureDetector(
                      onTap: hasSoal
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KuisScreen(
                                    kategoriId: category['id'],
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: hasSoal ? Colors.white : Colors.grey[300],
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
                              child: Image.network(
                                category['foto'],
                                height: 50,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              category['nama_kategori'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: hasSoal ? Colors.black : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
