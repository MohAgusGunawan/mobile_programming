import 'package:flutter/material.dart';
import 'dart:io';
// import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_awesome_app/service/api_service.dart';

class PenggunaScreen extends StatefulWidget {
  @override
  _PenggunaScreenState createState() => _PenggunaScreenState();
}

class _PenggunaScreenState extends State<PenggunaScreen> {
  String searchQuery = '';
  List<Map<String, dynamic>> penggunaData = [];
  List<Map<String, dynamic>> filteredData = [];

  Future<void> fetchPenggunaData() async {
    try {
      final data = await ApiService().fetchPengguna();
      setState(() {
        penggunaData = data;
        filteredData = data;
      });
    } catch (error) {
      print('Error fetching pengguna: $error');
    }
  }

  void _filterData(String query) {
    setState(() {
      searchQuery = query;
      filteredData = penggunaData.where((user) {
        final username = user['username']?.toLowerCase() ?? '';
        final email = user['email']?.toLowerCase() ?? '';
        return username.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase());
      }).toList();
    });
  }

  String _sensorEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final localPart = parts[0];
    final domain = parts[1];
    final visiblePart = localPart.length <= 3
        ? localPart
        : localPart.substring(localPart.length - 3);
    return '***$visiblePart@$domain';
  }

  @override
  void initState() {
    super.initState();
    fetchPenggunaData();
  }

  void _showEditModal(BuildContext context, Map<String, dynamic> pengguna) {
    final TextEditingController usernameController =
        TextEditingController(text: pengguna['username']);
    File? selectedPhoto;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Text('Edit Pengguna'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input Username
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Foto Input & Preview
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          setState(() {
                            selectedPhoto = File(pickedFile.path);
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: selectedPhoto != null
                            ? Image.file(
                                selectedPhoto!,
                                fit: BoxFit.cover,
                              )
                            : pengguna['photo'] != null
                                ? Image.network(
                                    pengguna['photo'], // URL foto lama
                                    fit: BoxFit.cover,
                                  )
                                : const Center(
                                    child: Text('Klik untuk memilih foto'),
                                  ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Update pengguna di sini
                final updatedData = {
                  'id': pengguna['id'],
                  'username': usernameController.text,
                  'photo': selectedPhoto,
                };

                try {
                  await ApiService().updatePengguna(updatedData);
                  Navigator.of(context).pop();
                  setState(() {}); // Refresh data setelah update
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'DATA PENGGUNA',
          style: TextStyle(
            color: Color(0xFF4A44A5),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterData,
              decoration: InputDecoration(
                labelText: 'Cari pengguna',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredData.isEmpty
                ? const Center(child: Text('Tidak ada data pengguna'))
                : SingleChildScrollView(
                    child: PaginatedDataTable(
                      header: const Text(
                        'Tabel Pengguna',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      columns: const [
                        DataColumn(label: Text('No')),
                        DataColumn(label: Text('Nama Pengguna')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      source: _PenggunaDataSource(
                        filteredData,
                        context,
                        _sensorEmail,
                        _showEditModal,
                      ),
                      rowsPerPage: 5,
                      availableRowsPerPage: const [5, 10, 15],
                      onRowsPerPageChanged: (value) {},
                      showCheckboxColumn: false,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PenggunaDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final BuildContext context;
  final String Function(String) sensorEmail;
  final Function(BuildContext, Map<String, dynamic>) showEditModal;

  _PenggunaDataSource(
    this.data,
    this.context,
    this.sensorEmail,
    this.showEditModal,
  );

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final pengguna = data[index];

    return DataRow(
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(Text(pengguna['username'])),
        DataCell(Text(sensorEmail(pengguna['email']))),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.yellow),
                onPressed: () => showEditModal(context, pengguna),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
