import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  // Constructor untuk instans
  ApiService({this.baseUrl = 'http://localhost:3000/api'});

  // Instans default untuk akses static
  static final ApiService _defaultInstance =
      ApiService(baseUrl: 'http://localhost:3000/api');

  // Getter static untuk baseUrl
  static String get staticBaseUrl => _defaultInstance.baseUrl;

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
        Uri.parse('http://localhost:3000/api/kategori'),
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
    final url = Uri.parse('http://localhost:3000/api/kategori');
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
            'foto': kategori['foto'] as String,
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
}
