import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  final String baseUrl;

  // Constructor untuk instans
  ApiService({this.baseUrl = 'http://192.168.94.110:3000/api'});

  // Instans default untuk akses static
  static final ApiService _defaultInstance =
      ApiService(baseUrl: 'http://192.168.94.110:3000/api');
  static final ApiService _default = ApiService(
      baseUrl: 'http://192.168.94.110/mobile_programming/my_awesome_app');

  // Getter static untuk baseUrl
  static String get staticBaseUrl => _defaultInstance.baseUrl;
  // Getter static untuk baseUrl
  static String get localUrl => _default.baseUrl;

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Login Gagal';
        return {'success': false, 'message': error};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  Future<Map<String, dynamic>> register(
      String email, String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final error =
            jsonDecode(response.body)['message'] ?? 'Registrasi Gagal';
        return {'success': false, 'message': error};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // Metode static untuk createKategori
  static Future<bool> createKategori(String namaKategori, File? image,
      String userId, Uint8List? webImageBytes) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$staticBaseUrl/kategori'),
      );

      request.fields['nama_kategori'] = namaKategori;
      request.fields['id'] = userId;

      print(
          'Mengirim gambar sebagai bytes: ${webImageBytes != null ? 'Ada' : 'Tidak Ada'}');

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto',
          image.path,
        ));
      } else if (webImageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'foto',
          webImageBytes,
          filename: 'image.png',
          contentType: MediaType('image', 'png'), // MIME type untuk gambar
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Kategori berhasil ditambahkan.');
        return true;
      } else {
        var responseBody = await http.Response.fromStream(response);
        print('Error: ${responseBody.body}');
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchKategori() async {
    final url = Uri.parse('$baseUrl/kategori');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parsing JSON dari body response
        final List<dynamic> data = jsonDecode(response.body);

        // Memastikan tipe data yang benar
        return data.map((kategori) {
          return {
            'id': kategori['id'] as int, // pastikan id bertipe int
            'nama_kategori': kategori['nama_kategori'] as String,
            'foto':
                'http://192.168.94.110/mobile_programming/my_awesome_app/assets/images/kategori/${kategori['foto'] ?? 'default.png'}',
            'dibuat_oleh': kategori['dibuat_oleh']
                as int, // pastikan dibuat_oleh bertipe int
          };
        }).toList();
      } else {
        throw Exception(
            'Failed to load kategori: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching kategori: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchPengguna() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('Data pengguna tidak ditemukan');
        }
      } else {
        throw Exception(
            'Gagal mengambil data pengguna. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data pengguna: $e');
    }
  }

  Future<void> updatePengguna(
      Map<String, dynamic> data, File? image, Uint8List? webImageBytes) async {
    try {
      var uri = Uri.parse('$baseUrl/pengguna/${data['id']}');
      var request = http.MultipartRequest('PUT', uri);

      request.fields['username'] = data['username'];
      request.fields['nama'] = data['nama'];

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto',
          image.path,
        ));
      } else if (webImageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'foto',
          webImageBytes,
          filename: 'image.png',
          contentType: MediaType('image', 'png'),
        ));
      }

      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        print('Failed response: $responseBody');
        throw Exception('Failed to update pengguna: $responseBody');
      }
    } catch (e) {
      throw Exception('Error updating pengguna: $e');
    }
  }

  static Future<bool> updateKategori(Map<String, dynamic> kategori) async {
    try {
      final uri = Uri.parse('$staticBaseUrl/kategori/${kategori['id']}');
      final request = http.MultipartRequest('PUT', uri);

      request.fields['nama_kategori'] = kategori['nama_kategori'];

      if (kategori['foto'] != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto',
          kategori['foto'].path,
        ));
      } else if (kategori['webImageBytes'] != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'foto',
          kategori['webImageBytes'],
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      // Debug log
      print('Fields: ${request.fields}');
      print('Files: ${request.files}');

      final response = await request.send();

      // Debugging jika response gagal
      if (response.statusCode != 200) {
        final responseBody = await http.Response.fromStream(response);
        print('Response status: ${response.statusCode}');
        print('Response body: ${responseBody.body}');
      }

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating kategori: $e');
      return false;
    }
  }

  // Ambil data soal
  Future<List<Map<String, dynamic>>> fetchSoal(int kategoriId) async {
    final url = Uri.parse('$baseUrl/soal?kategori_id=$kategoriId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parsing JSON dari body response
        final List<dynamic> data = jsonDecode(response.body);

        // Memastikan tipe data yang benar
        return data.map((soal) {
          return {
            'id': soal['id'] as int, // pastikan id bertipe int
            'soal': soal['soal'] as String, // pastikan soal bertipe String
            'id_kategori':
                soal['id_kategori'] as int, // pastikan kategori_id bertipe int
            'nama_kategori': soal['nama_kategori']
                as String, // pastikan nama_kategori bertipe String
            'gambar':
                'http://192.168.94.110/mobile_programming/my_awesome_app/assets/images/soal/${soal['gambar'] ?? 'default.png'}',
            'opsi_a': soal['opsi_a'],
            'opsi_b': soal['opsi_b'],
            'opsi_c': soal['opsi_c'],
            'opsi_d': soal['opsi_d'],
            'id_jawaban': soal['id_jawaban'],
            'dibuat_oleh': soal['dibuat_oleh']
          };
        }).toList();
      } else {
        throw Exception(
            'Failed to load soal: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching soal: $e');
      return [];
    }
  }

  // Fungsi untuk menambahkan soal dengan upload gambar
  Future<bool> createSoal(Map<String, dynamic> newSoal, File? image,
      String userId, Uint8List? webImageBytes) async {
    try {
      final uri = Uri.parse('$baseUrl/soal'); // Endpoint untuk menambahkan soal
      var request = http.MultipartRequest('POST', uri);

      // Menambahkan data form lainnya
      request.fields['id_kategori'] = newSoal['id_kategori'].toString();
      request.fields['soal'] = newSoal['soal'];
      request.fields['opsi_a'] = newSoal['opsi_a'];
      request.fields['opsi_b'] = newSoal['opsi_b'];
      request.fields['opsi_c'] = newSoal['opsi_c'];
      request.fields['opsi_d'] = newSoal['opsi_d'];
      request.fields['id_jawaban'] = newSoal['id_jawaban'];
      request.fields['id'] = userId;

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'gambar',
          image.path,
        ));
      } else if (webImageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'gambar',
          webImageBytes,
          filename: 'image.png',
          contentType: MediaType('image', 'png'), // MIME type untuk gambar
        ));
      }

      // Kirim request
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Soal berhasil ditambahkan');
        return true;
      } else {
        var responseBody = await http.Response.fromStream(response);
        print('Error: ${responseBody.body}');
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }

  Future<bool> editSoal(Map<String, dynamic> newSoal, File? image,
      String userId, Uint8List? webImageBytes) async {
    final uri = Uri.parse('$baseUrl/soal/${newSoal['id']}');

    var request = http.MultipartRequest('PUT', uri);

    // Menambahkan data form lainnya
    request.fields['id_kategori'] = newSoal['id_kategori'].toString();
    request.fields['soal'] = newSoal['soal'];
    request.fields['opsi_a'] = newSoal['opsi_a'];
    request.fields['opsi_b'] = newSoal['opsi_b'];
    request.fields['opsi_c'] = newSoal['opsi_c'];
    request.fields['opsi_d'] = newSoal['opsi_d'];
    request.fields['id_jawaban'] = newSoal['id_jawaban'];
    request.fields['id'] = userId;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'gambar',
        image.path,
      ));
    } else if (webImageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'gambar',
        webImageBytes,
        filename: 'image.png',
        contentType: MediaType('image', 'png'), // MIME type untuk gambar
      ));
    }

    // Kirim request dan cek respons
    var response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // Hapus soal
  Future<bool> deleteSoal(int id) async {
    final url = Uri.parse('$baseUrl/soal/$id');
    try {
      final response = await http.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting soal: $e');
      return false;
    }
  }

  // Profile
  Future<List<Map<String, dynamic>>> fetchProfile(int userId) async {
    final url = Uri.parse('$baseUrl/profile?user_id=$userId');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parsing JSON dari body response
        final List<dynamic> data = jsonDecode(response.body);

        // Memastikan tipe data yang benar
        return data.map((profile) {
          return {
            'id': profile['id'] as int,
            'id_user': profile['id_user'] as int,
            'nama': profile['nama'],
            'foto':
                'http://192.168.94.110/mobile_programming/my_awesome_app/assets/images/profile/${profile['foto'] ?? 'person.jpg'}',
            'tanggal_lahir': profile['tanggal_lahir'],
            'jenis_kelamin': profile['jenis_kelamin'],
            'bio': profile['bio'],
          };
        }).toList();
      } else {
        throw Exception(
            'Failed to load Pengguna: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching Pengguna: $e');
      return [];
    }
  }

  Future<bool> editProfile(Map<String, dynamic> newProfile, File? image,
      Uint8List? webImageBytes) async {
    final uri = Uri.parse('$baseUrl/profile/${newProfile['id']}');

    var request = http.MultipartRequest('PUT', uri);

    // Menambahkan data form lainnya
    request.fields['id_user'] = newProfile['id_user'].toString();
    if (newProfile['nama'] != null) {
      request.fields['nama'] = newProfile['nama'];
    }
    if (newProfile['tanggal_lahir'] != null) {
      request.fields['tanggal_lahir'] = newProfile['tanggal_lahir'];
    }
    if (newProfile['jenis_kelamin'] != null) {
      request.fields['jenis_kelamin'] = newProfile['jenis_kelamin'];
    }
    if (newProfile['bio'] != null) {
      request.fields['bio'] = newProfile['bio'];
    }

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'foto',
        image.path,
      ));
    } else if (webImageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'foto',
        webImageBytes,
        filename: 'image.png',
        contentType: MediaType('image', 'png'), // MIME type untuk foto
      ));
    }

    // Kirim request dan cek respons
    var response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error: ${response.statusCode} ${response.reasonPhrase}');
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchDashboardData(int userId) async {
    final uri = Uri.parse('$baseUrl/dashboard?user_id=$userId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil data dashboard');
    }
  }

  // Fungsi untuk menyimpan skor dan papan peringkat
  Future<void> submitQuiz({
    required int idUser,
    required int idKategori,
    required int nilaiSkor,
    required int totalSoal,
    required int jawabanBenar,
    required int waktuPengerjaan,
    required DateTime selesaiPada,
  }) async {
    final url = Uri.parse('$baseUrl/submit-quiz');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_user': idUser,
        'id_kategori': idKategori,
        'nilai_skor': nilaiSkor,
        'total_soal': totalSoal,
        'jawaban_benar': jawabanBenar,
        'waktu_pengerjaan': waktuPengerjaan,
        'selesai_pada': selesaiPada.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menyimpan skor: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLeaderboard(int kategoriId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/leaderboard/$kategoriId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData = json.decode(response.body);

      // Pastikan Anda mengakses properti `data`
      return List<Map<String, dynamic>>.from(decodedData['data']);
    } else {
      throw Exception('Gagal memuat leaderboard');
    }
  }
}
