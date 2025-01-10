import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_awesome_app/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilScreen extends StatefulWidget {
  @override
  _ProfilScreenState createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final ApiService apiService = ApiService();
  String? _gender;
  DateTime? _birthDate;
  Uint8List? _profilePhotoBytes;
  String? _profilePhotoUrl;
  bool isLoading = true;
  int? _userId;

  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];

  @override
  void initState() {
    super.initState();
    _getUserIdAndLoadProfile();
  }

  Future<void> _getUserIdAndLoadProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id');
      if (userId == null) throw Exception('User ID tidak ditemukan.');

      setState(() {
        _userId = userId;
      });

      await _loadProfile();
    } catch (e) {
      print('Error getting user ID: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      final result = await apiService.fetchProfile(_userId!);
      if (result.isNotEmpty) {
        final profile = result[0];
        setState(() {
          _nameController.text = profile['nama'] ?? '';
          _bioController.text = profile['bio'] ?? '';
          _gender = profile['jenis_kelamin'];
          _birthDate = profile['tanggal_lahir'] != null
              ? DateTime.parse(profile['tanggal_lahir'])
              : null;
          _profilePhotoUrl = profile['foto'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk memilih file gambar menggunakan FilePicker
  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _profilePhotoBytes = result.files.first.bytes;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      isLoading = true;
    });

    // Membuat objek profile baru dengan hanya data yang diisi
    Map<String, dynamic> newProfile = {
      'id': _userId,
      if (_nameController.text.isNotEmpty) 'nama': _nameController.text,
      if (_birthDate != null)
        'tanggal_lahir': _birthDate!.toIso8601String().split('T')[0],
      if (_gender != null) 'jenis_kelamin': _gender,
      if (_bioController.text.isNotEmpty) 'bio': _bioController.text,
    };

    bool success = await apiService.editProfile(
      newProfile,
      null,
      _profilePhotoBytes,
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      _showSnackbar('Profile berhasil diperbarui', Colors.green);
      await _loadProfile();
    } else {
      _showSnackbar('Gagal memperbarui profile', Colors.red);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
        behavior:
            SnackBarBehavior.floating, // Membuat Snackbar tampil mengambang
        margin: EdgeInsets.only(
            bottom: 230.0, left: 16.0, right: 16.0), // Atur margin
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 17, 247),
        elevation: 0,
        title: const Text('PROFILE AKUN',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Foto Profil
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _profilePhotoBytes != null
                            ? MemoryImage(_profilePhotoBytes!)
                            : (_profilePhotoUrl != null &&
                                    _profilePhotoUrl!.isNotEmpty
                                ? NetworkImage(_profilePhotoUrl!)
                                : const AssetImage(
                                        'assets/images/profile/person.jpg')
                                    as ImageProvider),
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.black),
                        onPressed: _pickImage,
                        color: Colors.deepPurple,
                        padding: const EdgeInsets.all(8.0),
                        constraints: const BoxConstraints(),
                        iconSize: 24,
                        tooltip: 'Ganti Foto',
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  // Input Nama Lengkap
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Input Bio
                  TextField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      prefixIcon: const Icon(Icons.info),
                    ),
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                  ),
                  const SizedBox(height: 16.0),
                  // Dropdown Jenis Kelamin
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: InputDecoration(
                      labelText: 'Jenis Kelamin',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    items: _genderOptions
                        .map((gender) => DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Date Picker Tanggal Lahir
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: _birthDate == null
                          ? 'Tanggal Lahir'
                          : 'Tanggal Lahir: ${_birthDate!.toLocal().toString().split(' ')[0]}',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _birthDate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _birthDate = pickedDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24.0),
                  // Tombol Update
                  ElevatedButton(
                    onPressed: isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 12.0),
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Update Profile',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
