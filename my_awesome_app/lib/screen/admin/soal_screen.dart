import 'package:flutter/material.dart';
import 'package:my_awesome_app/service/api_service.dart';

class SoalScreen extends StatefulWidget {
  @override
  _SoalScreenState createState() => _SoalScreenState();
}

class _SoalScreenState extends State<SoalScreen> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> soalList = [];
  List<Map<String, dynamic>> kategoriList = [];
  String? selectedKategori;
  bool isLoading = true;
  int rowsPerPage = 5;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Soal'),
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
                          header: Text('Tabel Soal'),
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
                          source: SoalDataSource(soalList, context),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tambahkan logika untuk menambah soal
        },
        backgroundColor: const Color(0xFF4A44A5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class SoalDataSource extends DataTableSource {
  final List<Map<String, dynamic>> soalList;
  final BuildContext context;

  SoalDataSource(this.soalList, this.context);

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
              onPressed: () {
                // Tambahkan logika untuk mengedit soal
              },
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
