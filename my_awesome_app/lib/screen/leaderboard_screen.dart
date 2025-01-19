import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_awesome_app/service/api_service.dart';

class LeaderboardScreen extends StatelessWidget {
  final int kategoriId;
  final String namaKategori;

  const LeaderboardScreen({
    Key? key,
    required this.kategoriId,
    required this.namaKategori,
  }) : super(key: key);

  Future<int?> getLoggedInUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 17, 247),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Papan Peringkat",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24.0, // Ukuran font lebih kecil dari nama kategori
              ),
            ),
            Text(
              namaKategori,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.0, // Ukuran font lebih besar untuk nama kategori
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: ApiService().fetchLeaderboard(kategoriId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("Papan peringkat masih kosong.",
                    style: TextStyle(color: Colors.black, fontSize: 18)),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Terjadi kesalahan: ${snapshot.error}"),
              );
            }

            final leaderboard = snapshot.data!;
            return FutureBuilder<int?>(
              future: getLoggedInUserId(),
              builder: (context, userIdSnapshot) {
                if (userIdSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final loggedInUserId = userIdSnapshot.data;

                return Column(
                  children: [
                    // Widget untuk peringkat 1, 2, 3
                    buildTopRankers(leaderboard, loggedInUserId),
                    const SizedBox(height: 16),
                    // Widget untuk peringkat lainnya
                    buildOtherRankers(leaderboard, loggedInUserId),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildTopRankers(
      List<Map<String, dynamic>> leaderboard, int? loggedInUserId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (leaderboard.length > 1)
          buildTopRankCard(leaderboard[1], Colors.green, '2', loggedInUserId),
        if (leaderboard.isNotEmpty)
          buildTopRankCard(leaderboard[0], Colors.yellow, '1', loggedInUserId),
        if (leaderboard.length > 2)
          buildTopRankCard(leaderboard[2], Colors.blue, '3', loggedInUserId),
      ],
    );
  }

  Widget buildTopRankCard(Map<String, dynamic> user, Color color, String rank,
      int? loggedInUserId) {
    final isLoggedInUser =
        user['user_id']?.toString() == loggedInUserId?.toString();

    return Column(
      children: [
        const SizedBox(height: 10),
        CircleAvatar(
          radius: 40,
          backgroundImage: user['foto'] != null && user['foto'] != ''
              ? NetworkImage(
                  'http://192.168.94.110/mobile_programming/my_awesome_app/assets/images/profile/${user['foto']}')
              : AssetImage('assets/images/profile/person.jpg') as ImageProvider,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            rank,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user['nama'] ?? user['username'],
          style: TextStyle(
            color: isLoggedInUser ? Colors.yellow : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${user['nilai_skor']} Poin',
          style: TextStyle(
            color: isLoggedInUser ? Colors.yellow : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget buildOtherRankers(
      List<Map<String, dynamic>> leaderboard, int? loggedInUserId) {
    return Expanded(
      child: ListView.builder(
        itemCount: leaderboard.length - 3,
        itemBuilder: (context, index) {
          final user = leaderboard[index + 3];
          final isLoggedInUser =
              user['user_id']?.toString() == loggedInUserId?.toString();

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: user['foto'] != null && user['foto'] != ''
                  ? NetworkImage(
                      'http://192.168.94.110/mobile_programming/my_awesome_app/assets/images/profile/${user['foto']}')
                  : AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
            ),
            title: Text(
              user['nama'] ?? 'Tidak diketahui',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isLoggedInUser ? Colors.yellow : Colors.black,
              ),
            ),
            subtitle: Text(
              '${user['nilai_skor']} Poin',
              style: TextStyle(
                color: isLoggedInUser ? Colors.yellow : Colors.black87,
              ),
            ),
            trailing: Text(
              '#${index + 4}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isLoggedInUser ? Colors.yellow : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }
}
