import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_awesome_app/service/api_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class PenggunaScreen extends StatefulWidget {
  @override
  _PenggunaScreenState createState() => _PenggunaScreenState();
}

class _PenggunaScreenState extends State<PenggunaScreen> {
  String searchQuery = '';
  List<Map<String, dynamic>> penggunaData = [];
  List<Map<String, dynamic>> filteredData = [];
  PlatformFile? selectedPhoto;

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
        return username.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPenggunaData();
  }

  void _showEditModal(BuildContext context, Map<String, dynamic> pengguna) {
    final TextEditingController usernameController =
        TextEditingController(text: pengguna['username']);
    final TextEditingController namaController =
        TextEditingController(text: pengguna['nama']);

    PlatformFile? tempPhoto = selectedPhoto;

    // GlobalKey untuk Form
    final _formKey = GlobalKey<FormState>();

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
                child: Form(
                  key: _formKey, // Menambahkan Form
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Input Username
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Input Nama Pengguna
                      TextFormField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pengguna',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama Pengguna tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Foto Input & Preview
                      GestureDetector(
                        onTap: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                          );
                          if (result != null) {
                            setState(() {
                              tempPhoto = result.files.first;
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
                          child: tempPhoto != null
                              ? Image.memory(
                                  tempPhoto!.bytes!,
                                  fit: BoxFit.cover,
                                )
                              : pengguna['foto'] != null
                                  ? Image.network(
                                      'http://192.168.94.110/mobile_programming/my_awesome_app/assets/images/profile/${pengguna['foto'] ?? 'person.jpg'}',
                                      fit: BoxFit.cover,
                                    )
                                  : const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.photo,
                                            size: 48.0,
                                          ),
                                          Text('Pilih Foto'),
                                        ],
                                      ),
                                    ),
                        ),
                      ),
                    ],
                  ),
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
                // Validasi form
                if (_formKey.currentState?.validate() ?? false) {
                  final updatedData = {
                    'id': pengguna['id'],
                    'username': usernameController.text.isNotEmpty
                        ? usernameController.text
                        : pengguna['username'],
                    'nama': namaController.text.isNotEmpty
                        ? namaController.text
                        : pengguna['nama'],
                  };

                  try {
                    await ApiService().updatePengguna(
                      updatedData,
                      kIsWeb
                          ? null
                          : (tempPhoto != null ? File(tempPhoto!.path!) : null),
                      kIsWeb ? tempPhoto?.bytes : null,
                    );
                    Navigator.of(context).pop();
                    setState(() {
                      selectedPhoto = tempPhoto;
                    });
                    _showSnackbar('Berhasil menyimpan data', Colors.green);
                    await fetchPenggunaData();
                  } catch (e) {
                    print('Error saat update: $e');
                    _showSnackbar('Gagal menyimpan data', Colors.red);
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
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
        title: const Text(
          'DATA PENGGUNA',
          style: TextStyle(
            color: Colors.white,
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
                      columns: const [
                        DataColumn(label: Text('No')),
                        DataColumn(label: Text('Foto')),
                        DataColumn(label: Text('Username')),
                        DataColumn(label: Text('Nama Pengguna')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      source: _PenggunaDataSource(
                        filteredData,
                        context,
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
  final Function(BuildContext, Map<String, dynamic>) showEditModal;

  _PenggunaDataSource(
    this.data,
    this.context,
    this.showEditModal,
  );

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final pengguna = data[index];

    return DataRow(
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(
          CircleAvatar(
            backgroundImage: NetworkImage(
              'http://192.168.94.110/mobile_programming/my_awesome_app/assets/images/profile/${pengguna['foto'] ?? 'person.jpg'}',
            ),
          ),
        ),
        DataCell(Text(pengguna['username'])),
        DataCell(Text(pengguna['nama'] ?? '-')),
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
