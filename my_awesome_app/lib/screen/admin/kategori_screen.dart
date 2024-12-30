import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:my_awesome_app/screen/layouts/bottom_navigation_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_awesome_app/service/api_service.dart';

class KategoriScreen extends StatefulWidget {
  @override
  _KategoriScreenState createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  int _currentIndex = 2;
  File? selectedImage;
  Uint8List? webImageBytes;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Fungsi ambil ID
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id'); // Ambil ID pengguna
  }

  // Fungsi untuk memilih gambar
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
            print('webImageBytes berhasil diisi.');
          });
        } else {
          print('webImageBytes tetap null.');
        }
      } else {
        final ImagePicker picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);

        if (image != null) {
          setState(() {
            selectedImage = File(image.path);
            webImageBytes = null; // Reset gambar web
          });
          print('Gambar berhasil dipilih dari perangkat: ${image.path}');
        } else {
          print('Tidak ada gambar yang dipilih di perangkat.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada gambar yang dipilih')),
          );
        }
      }
    } catch (e) {
      print('Error saat memilih gambar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  // Fungsi untuk menampilkan modal tambah kategori
  void _showTambahKategoriModal(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String kategoriNama = '';
    bool imageError = false;

    setState(() {
      webImageBytes = null;
      selectedImage = null;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: const Text(
                'Tambah Kategori',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nama Kategori',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama kategori tidak boleh kosong';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        kategoriNama = value!;
                      },
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        await _pickImage();
                        setModalState(() {
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
                                : Center(
                                    child: Text(
                                      'Klik untuk memilih gambar',
                                      style: TextStyle(
                                        color: imageError
                                            ? Colors.red
                                            : Colors.black,
                                      ),
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
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    bool isFormValid = _formKey.currentState!.validate();
                    bool isImageSelected =
                        webImageBytes != null || selectedImage != null;

                    if (isFormValid && isImageSelected) {
                      _formKey.currentState!.save();

                      final userId = await getUserId();

                      if (userId != null) {
                        bool isSuccess = await ApiService.createKategori(
                          kategoriNama,
                          selectedImage,
                          userId.toString(),
                          webImageBytes,
                        );

                        if (isSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Kategori berhasil dibuat')),
                          );
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Gagal membuat kategori')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Tidak dapat mengambil ID pengguna')),
                        );
                      }
                    } else {
                      if (!isImageSelected) {
                        setModalState(() {
                          imageError = true;
                        });
                      }
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
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
          'SEMUA KATEGORI SOAL',
          style: TextStyle(
            color: Color(0xFF4A44A5),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService().fetchKategori(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data kategori'));
          }

          final kategoriData = snapshot.data!;

          return SingleChildScrollView(
            child: PaginatedDataTable(
              header: const Text(
                'Tabel Kategori',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              columns: const [
                DataColumn(label: Text('No')),
                DataColumn(label: Text('Gambar')),
                DataColumn(label: Text('Kategori')),
                DataColumn(label: Text('Aksi')),
              ],
              source: _KategoriDataSource(kategoriData, context),
              rowsPerPage: 5,
              availableRowsPerPage: const [5, 10, 15],
              onRowsPerPageChanged: (value) {},
              showCheckboxColumn: false,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTambahKategoriModal(context);
        },
        backgroundColor: const Color(0xFF4A44A5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationAdmin(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class _KategoriDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final BuildContext context;

  _KategoriDataSource(this.data, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final kategori = data[index];

    return DataRow(
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(CircleAvatar(
          backgroundImage: AssetImage('assets/images/profile.png'),
        )),
        DataCell(Text(kategori['nama_kategori'])),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.yellow),
                onPressed: () {
                  // Logika edit kategori
                },
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
