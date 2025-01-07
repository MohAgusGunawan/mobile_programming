import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_awesome_app/service/api_service.dart';
import 'result_screen.dart';

class KuisScreen extends StatefulWidget {
  final int kategoriId;

  KuisScreen({required this.kategoriId});

  @override
  _KuisScreenState createState() => _KuisScreenState();
}

class _KuisScreenState extends State<KuisScreen> {
  late Future<List<Map<String, dynamic>>> _soalFuture;
  late List<Map<String, dynamic>> soalList;
  int _currentIndex = 0;
  int _skor = 0;
  // bool _isFinished = false;
  int _remainingTime = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _soalFuture = ApiService().fetchSoal(widget.kategoriId).then((soal) {
      soal.shuffle();
      return soal;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _finishQuiz();
      }
    });
  }

  void _nextSoal(bool isCorrect) {
    if (isCorrect) {
      _skor++;
      if (_currentIndex < (soalList.length - 1)) {
        setState(() {
          _currentIndex++;
          _resetTimer();
        });
      } else {
        _finishQuiz();
      }
    } else {
      _finishQuiz();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _remainingTime = 30;
    _startTimer();
  }

  void _finishQuiz() {
    _timer?.cancel();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          skor: _skor,
          kategori: 'Pengetahuan Umum',
          peringkat: 4,
          onRestart: _restartKuis,
        ),
      ),
    );
  }

  void _restartKuis() {
    setState(() {
      _skor = 0; // Reset skor
      _currentIndex = 0; // Reset index ke soal pertama
      _remainingTime = 30; // Reset waktu
      _soalFuture = ApiService().fetchSoal(widget.kategoriId).then((soal) {
        soal.shuffle();
        return soal;
      }); // Ambil soal baru
      _startTimer();
    });

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuis'),
      ),
      body: Container(
        color: const Color(0xFF8E44AD),
        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [Colors.blueAccent, const Color(0xFF8E44AD)],
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //   ),
        // ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _soalFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Terjadi kesalahan: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Tidak ada soal.'));
            }

            soalList = snapshot.data!;
            final soal = soalList[_currentIndex];

            // if (_isFinished) {
            //   return Center(
            //     child: Text(
            //       'Kuis Selesai!',
            //       style: const TextStyle(
            //           fontSize: 24, fontWeight: FontWeight.bold),
            //     ),
            //   );
            // }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Soal ${_currentIndex + 1} dari ${soalList.length}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.timer, color: Colors.red),
                                  const SizedBox(width: 5),
                                  Text(
                                    '$_remainingTime detik',
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (soal['gambar'] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                soal['gambar'],
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            soal['soal'],
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...['opsi_a', 'opsi_b', 'opsi_c', 'opsi_d']
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final opsi = entry.value;
                    final opsiEnum = ['a', 'b', 'c', 'd'][index];
                    final opsiColors = [
                      Colors.blueAccent,
                      Colors.green,
                      Colors.orange,
                      Colors.red
                    ]; // Warna tombol berbeda

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: opsiColors[index],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _nextSoal(opsiEnum == soal['id_jawaban']);
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '${opsiEnum.toUpperCase()}. ${soal[opsi]}',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
