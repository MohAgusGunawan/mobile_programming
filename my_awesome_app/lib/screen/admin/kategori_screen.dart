import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_awesome_app/service/api_service.dart';

class KategoriScreen extends StatefulWidget {
  @override
  _KategoriScreenState createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  File? selectedImage;
  Uint8List? webImageBytes;
  String searchQuery = '';
  List<Map<String, dynamic>> kategoriData = [];

  Future<void> fetchKategoriData() async {
    try {
      final data = await ApiService().fetchKategori();
      setState(() {
        kategoriData = data;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id'); // Ambil ID pengguna
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
              title: const Text('Tambah Kategori', textAlign: TextAlign.center),
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
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.photo, // Ikon gambar
                                          size: 48.0, // Ukuran ikon
                                          color: imageError
                                              ? Colors.red
                                              : Colors.black, // Warna ikon
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
                          _showSnackbar(
                              'Kategori berhasil dibuat', Colors.green);
                          Navigator.of(context).pop();
                          await fetchKategoriData(); // Auto reload setelah tambah
                        } else {
                          _showSnackbar('Gagal membuat kategori', Colors.red);
                        }
                      } else {
                        _showSnackbar(
                            'Tidak dapat mengambil ID pengguna', Colors.red);
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

  void _showEditKategoriModal(
      BuildContext context, Map<String, dynamic> kategori) {
    final _formKey = GlobalKey<FormState>();
    String kategoriNama = kategori['nama_kategori'];
    File? selectedImage;
    Uint8List? webImageBytes = kategori['webImageBytes'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: const Text('Edit Kategori', textAlign: TextAlign.center),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: kategoriNama,
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
                      onChanged: (value) {
                        kategoriNama = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        if (kIsWeb) {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                          );

                          if (result != null &&
                              result.files.single.bytes != null) {
                            setModalState(() {
                              webImageBytes = result.files.single.bytes;
                              selectedImage = null;
                            });
                          }
                        } else {
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);

                          if (image != null) {
                            setModalState(() {
                              selectedImage = File(image.path);
                              webImageBytes = null;
                            });
                          }
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
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
                                : Image.network(
                                    kategori['foto'],
                                    fit: BoxFit.cover,
                                  ),
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
                    if (_formKey.currentState!.validate()) {
                      final updatedKategori = {
                        'id': kategori['id'],
                        'nama_kategori': kategoriNama,
                        'foto': selectedImage,
                        'webImageBytes': webImageBytes,
                      };

                      bool isSuccess =
                          await ApiService.updateKategori(updatedKategori);

                      if (isSuccess) {
                        _showSnackbar(
                            'Kategori berhasil diperbarui', Colors.green);
                        Navigator.of(context).pop();
                        await fetchKategoriData(); // Reload data
                      } else {
                        _showSnackbar('Gagal memperbarui kategori', Colors.red);
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
  void initState() {
    super.initState();
    fetchKategoriData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 17, 247),
        elevation: 0,
        title: const Text('DATA KATEGORI',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Cari kategori',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: PaginatedDataTable(
                columns: const [
                  DataColumn(label: Text('No')),
                  DataColumn(label: Text('Gambar')),
                  DataColumn(label: Text('Kategori')),
                  DataColumn(label: Text('Aksi')),
                ],
                source: _KategoriDataSource(
                  kategoriData
                      .where((item) => item['nama_kategori']
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery))
                      .toList(),
                  context,
                  onEditKategori: _showEditKategoriModal,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTambahKategoriModal(context);
        },
        backgroundColor: const Color(0xFF4A44A5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _KategoriDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final BuildContext context;
  final Function(BuildContext, Map<String, dynamic>) onEditKategori;

  _KategoriDataSource(this.data, this.context, {required this.onEditKategori});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final kategori = data[index];

    return DataRow(
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(
          CircleAvatar(
            backgroundImage: NetworkImage(
              kategori['foto'],
            ),
          ),
        ),
        DataCell(Text(kategori['nama_kategori'])),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.yellow),
                onPressed: () {
                  onEditKategori(context, kategori);
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
