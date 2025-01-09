import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_awesome_app/service/api_service.dart';
// import 'package:http/http.dart' as http;

class SoalScreen extends StatefulWidget {
  @override
  _SoalScreenState createState() => _SoalScreenState();
}

class _SoalScreenState extends State<SoalScreen> {
  File? selectedImage;
  Uint8List? webImageBytes;
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> soalList = [];
  List<Map<String, dynamic>> kategoriList = [];
  String? selectedKategori;
  bool isLoading = true;
  int rowsPerPage = 5;
  String? selectedJawaban;
  PlatformFile? pickedImage; // Menggunakan PlatformFile

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final kategori = await apiService.fetchKategori();
    if (kategori.isNotEmpty) {
      setState(() {
        kategoriList = kategori;
        selectedKategori = kategori.first['id'].toString();
      });
      await _fetchSoal(selectedKategori!);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id'); // Ambil ID pengguna
  }

  Future<void> _fetchSoal(String kategoriId) async {
    setState(() {
      isLoading = true;
    });
    final soal = await apiService.fetchSoal(int.parse(kategoriId));
    setState(() {
      soalList = soal;
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result != null && result.files.single.bytes != null) {
          setState(() {
            webImageBytes = result.files.single.bytes;
          });
        }
      } else {
        final ImagePicker picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);

        if (image != null) {
          setState(() {
            selectedImage = File(image.path);
            webImageBytes = null;
          });
        }
      }
    } catch (e) {
      print('Error saat memilih gambar: $e');
    }
  }

  // Future<Uint8List> _fetchImageBytesFromUrl(String imageUrl) async {
  //   final response = await http.get(Uri.parse(imageUrl));
  //   if (response.statusCode == 200) {
  //     return response.bodyBytes;
  //   } else {
  //     throw Exception('Gagal mengambil gambar dari URL');
  //   }
  // }

  void _showSoalDialog([Map<String, dynamic>? soal]) {
    bool imageError = false;
    setState(() {
      if (soal != null && soal['gambar'] != null) {
        if (kIsWeb) {
          // Jika platform web, gunakan URL dari gambar
          webImageBytes = null;
          selectedImage = null;
        } else {
          // Jika platform bukan web, gunakan path gambar dari soal sebagai File
          selectedImage = File(soal['gambar']);
          webImageBytes = null;
        }
      } else {
        webImageBytes = null;
        selectedImage = null;
      }
    });

    final TextEditingController soalController =
        TextEditingController(text: soal?['soal'] ?? '');
    final TextEditingController opsiAController =
        TextEditingController(text: soal?['opsi_a'] ?? '');
    final TextEditingController opsiBController =
        TextEditingController(text: soal?['opsi_b'] ?? '');
    final TextEditingController opsiCController =
        TextEditingController(text: soal?['opsi_c'] ?? '');
    final TextEditingController opsiDController =
        TextEditingController(text: soal?['opsi_d'] ?? '');

    String? selectedJawaban = soal?['id_jawaban'] ?? 'a';
    String? selectedKategoriId =
        soal?['id_kategori']?.toString() ?? selectedKategori;
    final int? soalId = soal?['id'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(soal == null ? 'Tambah Soal' : 'Edit Soal'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // DropdownButtonFormField<String>(
                    //   value: selectedKategoriId,
                    //   decoration: InputDecoration(labelText: 'Kategori'),
                    //   items: kategoriList.map((kategori) {
                    //     return DropdownMenuItem<String>(
                    //       value: kategori['id'].toString(),
                    //       child: Text(kategori['nama_kategori']),
                    //     );
                    //   }).toList(),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       selectedKategoriId = value;
                    //     });
                    //   },
                    // ),
                    TextField(
                      controller: soalController,
                      decoration: InputDecoration(labelText: 'Soal'),
                    ),
                    TextField(
                      controller: opsiAController,
                      decoration: InputDecoration(labelText: 'Opsi A'),
                    ),
                    TextField(
                      controller: opsiBController,
                      decoration: InputDecoration(labelText: 'Opsi B'),
                    ),
                    TextField(
                      controller: opsiCController,
                      decoration: InputDecoration(labelText: 'Opsi C'),
                    ),
                    TextField(
                      controller: opsiDController,
                      decoration: InputDecoration(labelText: 'Opsi D'),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedJawaban,
                      decoration: InputDecoration(labelText: 'Jawaban'),
                      items: ['a', 'b', 'c', 'd'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedJawaban = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        await _pickImage();
                        setState(() {
                          imageError = false;
                        });
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: imageError ? Colors.red : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: webImageBytes != null
                            ? Image.memory(
                                webImageBytes!,
                                fit: BoxFit.cover,
                              )
                            : selectedImage != null
                                ? Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                  )
                                : soal != null && soal['gambar'] != null
                                    ? Image.network(
                                        soal[
                                            'gambar'], // URL gambar dari server
                                        fit: BoxFit.cover,
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.photo,
                                              size: 48.0,
                                              color: imageError
                                                  ? Colors.red
                                                  : Colors.black,
                                            ),
                                            Text(
                                              'Pilih Foto',
                                              style: TextStyle(
                                                color: imageError
                                                    ? Colors.red
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                      ),
                    ),
                    if (imageError)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Silakan pilih gambar terlebih dahulu',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newSoal = {
                      'id': soalId,
                      'id_kategori': int.parse(selectedKategori!),
                      'soal': soalController.text,
                      'opsi_a': opsiAController.text,
                      'opsi_b': opsiBController.text,
                      'opsi_c': opsiCController.text,
                      'opsi_d': opsiDController.text,
                      'id_jawaban': selectedJawaban,
                      'gambar': webImageBytes != null
                          ? webImageBytes
                          : selectedImage?.path,
                    };

                    final userId = await getUserId();

                    try {
                      bool result;
                      if (soal == null) {
                        // Panggil createSoal untuk menambahkan soal
                        result = await apiService.createSoal(
                          newSoal,
                          selectedImage,
                          userId.toString(),
                          webImageBytes,
                        );
                      } else {
                        // Panggil editSoal untuk mengedit soal
                        result = await apiService.editSoal(
                          newSoal,
                          selectedImage,
                          userId.toString(),
                          webImageBytes,
                        );
                      }

                      if (result) {
                        _showSnackbar(
                            soal == null
                                ? 'Soal berhasil ditambahkan!'
                                : 'Soal berhasil diperbarui!',
                            Colors.green);
                        Navigator.pop(context);
                        _fetchSoal(selectedKategoriId!);
                      } else {
                        _showSnackbar(
                            'Gagal menambahkan atau memperbarui soal!',
                            Colors.red);
                      }
                    } catch (e) {
                      _showSnackbar(
                          'Terjadi kesalahan: ${e.toString()}', Colors.red);
                    }
                  },
                  child: Text(soal == null ? 'Tambah' : 'Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteSoal(int soalId) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin menghapus soal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final isSuccess = await apiService.deleteSoal(soalId);
      if (isSuccess) {
        _showSnackbar('Soal berhasil dihapus', Colors.green);
        _fetchSoal(selectedKategori!);
      } else {
        _showSnackbar('Gagal menghapus soal', Colors.red);
      }
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
            bottom: 300.0, left: 16.0, right: 16.0), // Atur margin
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('DATA SOAL',
            style: TextStyle(
                color: Color(0xFF4A44A5), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedKategori,
                    decoration: InputDecoration(
                      labelText: 'Pilih Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: kategoriList.map((kategori) {
                      return DropdownMenuItem<String>(
                        value: kategori['id'].toString(),
                        child: Text(kategori['nama_kategori']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedKategori = value;
                      });
                      _fetchSoal(value!);
                    },
                  ),
                ),
                Expanded(
                  child: soalList.isEmpty
                      ? Center(
                          child: Text(
                            'Soal Kosong!',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : PaginatedDataTable(
                          rowsPerPage: rowsPerPage,
                          availableRowsPerPage: [
                            5,
                            10,
                            15
                          ], // Pilihan rows per page
                          onRowsPerPageChanged: (value) {
                            setState(() {
                              rowsPerPage = value!;
                            });
                          },
                          columns: [
                            DataColumn(label: Text('No')),
                            DataColumn(label: Text('Soal')),
                            DataColumn(label: Text('Aksi')),
                          ],
                          source: SoalDataSource(
                              soalList, context, _showSoalDialog, _deleteSoal),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSoalDialog(),
        backgroundColor: const Color(0xFF4A44A5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class SoalDataSource extends DataTableSource {
  final List<Map<String, dynamic>> soalList;
  final BuildContext context;
  final Function(Map<String, dynamic>?) showSoalDialog;
  final Function(int) deleteSoal;

  SoalDataSource(
      this.soalList, this.context, this.showSoalDialog, this.deleteSoal);

  @override
  DataRow? getRow(int index) {
    if (index >= soalList.length) return null;
    final soal = soalList[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(Text(soal['soal'] ?? '-')),
        DataCell(Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => showSoalDialog(soal),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => deleteSoal(soal['id']),
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => soalList.length;

  @override
  int get selectedRowCount => 0;
}
