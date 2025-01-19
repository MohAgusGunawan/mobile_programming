import 'package:flutter/material.dart';
import 'package:my_awesome_app/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticScreen extends StatefulWidget {
  @override
  _StatisticScreenState createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  late Future<List<dynamic>> _kategoriData;
  int? loggedInUserId;

  @override
  void initState() {
    super.initState();
    _getLoggedInUserId();
    _kategoriData = ApiService().fetchKategori();
  }

  // Ambil ID user yang sedang login dari SharedPreferences
  Future<void> _getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInUserId = prefs.getInt('id');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 17, 247),
        elevation: 0,
        title: const Text('STATISTIK SEMUA KATEGORI',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _kategoriData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada data kategori"));
          } else {
            final kategoriList = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Table(
                border: TableBorder(
                  horizontalInside: BorderSide(color: Colors.grey.shade300),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                },
                children: [
                  // Header row
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "Kategori",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Text(
                        "Skor",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Peringkat",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  // Data rows for each category
                  for (var kategori in kategoriList)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  kategori['foto'],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(kategori['nama_kategori']),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future:
                                ApiService().fetchLeaderboard(kategori['id']),
                            builder: (context, leaderboardSnapshot) {
                              if (leaderboardSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (leaderboardSnapshot.hasError) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 14),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "-",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                );
                              }

                              final leaderboard = leaderboardSnapshot.data!;
                              final userEntry = leaderboard.firstWhere(
                                (entry) => entry['user_id'] == loggedInUserId,
                                orElse: () => {
                                  'nilai_skor': '-',
                                },
                              );

                              return Container(
                                margin: const EdgeInsets.only(top: 14),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  userEntry['nilai_skor'].toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                          ),
                        ),
                        Center(
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future:
                                ApiService().fetchLeaderboard(kategori['id']),
                            builder: (context, leaderboardSnapshot) {
                              if (leaderboardSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (leaderboardSnapshot.hasError) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 14),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "-",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                );
                              }

                              final leaderboard = leaderboardSnapshot.data!;
                              final userEntry = leaderboard.firstWhere(
                                (entry) => entry['user_id'] == loggedInUserId,
                                orElse: () => {
                                  'ranking': '-',
                                },
                              );

                              return Container(
                                margin: const EdgeInsets.only(top: 14),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  userEntry['ranking'].toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
