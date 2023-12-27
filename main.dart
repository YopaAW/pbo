import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Data Mahasiswa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _jurusanList = [
    'Hukum Keluarga Islam (Ahwal Syakhshiyyah) S1',
    'Perbankan Syari\'ah S1',
    'Pendidikan Agama Islam S1',
    'Pendidikan Bahasa Inggris S1',
    'Pendidikan Guru PAUD S1',
    'Pendidikan Guru Sekolah Dasar S1',
    'Komunikasi dan Penyiaran Islam S1',
    'Manajemen S1',
    'Akuntansi S1',
    'Ekonomi Islam S1',
    'Desain Produk S1',
    'Teknik Industri S1',
    'Teknik Informatika S1',
    'Desain Komunikasi Visual S1',
    'Teknik Sipil S1',
    'Teknik Elektro S1',
    'Sistem Informasi S1',
    'Budidaya Perairan S1',
    'Manajemen Pendidikan Islam S2',
    'Teknik Nuklir S1',
    'Teknik Nuklir S2',
    'Teknik Nuklir S3',
    ];

  List<Map<String, dynamic>> _mahasiswa = [];
  bool _isLoading = true;
  File? _selectedImage;
  String _selectedJurusan = '';

  void _refreshMhs() async {
    final data = await SQLHelper.gettbmhs();
    setState(() {
      _mahasiswa = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshMhs();
  }

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

 Future<void> _addItem() async {
  Uint8List? photoBytes;
  if (_selectedImage != null) {
    photoBytes = await _convertImageToBytes(_selectedImage!);
  }

  await SQLHelper.insertMhs(
    _namaController.text,
    _nimController.text,
    _alamatController.text,
    photoBytes,
    _selectedJurusan, // Simpan jurusan ke dalam database
  );

  _refreshMhs();
}

Future<void> _updateItem(int id) async {
  Uint8List? photoBytes;
  if (_selectedImage != null) {
    photoBytes = await _convertImageToBytes(_selectedImage!);
  }

  await SQLHelper.updateMhs(
    id,
    _namaController.text,
    _nimController.text,
    _alamatController.text,
    photoBytes,
    _selectedJurusan, // Simpan jurusan ke dalam database
  );

  _refreshMhs();
}


  Future<void> _deleteItem(int id) async {
    await SQLHelper.deleteMhs(id);
    _refreshMhs();
  }

  Future<void> _selectImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

void _showForm(int? id) async {
  if (id != null) {
    final dataMhs =
        _mahasiswa.firstWhere((element) => element['id'] == id);
    _namaController.text = dataMhs['nama'];
    _nimController.text = dataMhs['nim'];
    _alamatController.text = dataMhs['alamat'];
    setState(() {
      _selectedJurusan = dataMhs['jurusan'];
    });
  }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      elevation: 5,
      builder: (_) => Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _namaController,
                decoration: const InputDecoration(hintText: 'Nama'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _nimController,
                decoration: const InputDecoration(hintText: 'NIM'),
              ),
              DropdownButton<String>(
                value: _selectedJurusan.isEmpty
                    ? null
                    : _selectedJurusan,
                items: _jurusanList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedJurusan = newValue ?? '';
                  });
                },
                hint: Text('Pilih Jurusan'),
              ),
              TextField(
                controller: _alamatController,
                decoration: const InputDecoration(hintText: 'ALAMAT'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _selectImage,
                child: Text(
                    _selectedImage != null ? 'Change Photo' : 'Select Photo'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addItem();
                  } else {
                    await _updateItem(id);
                  }

                  _namaController.text = '';
                  _nimController.text = '';
                  _alamatController.text = '';
                  setState(() {
                    _selectedImage = null;
                  });

                  Navigator.of(context).pop();
                },
                child: Text(id == null ? 'Buat Baru' : 'Update'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _convertImageToBytes(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return Uint8List.fromList(imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Mahasiswa'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
ListView.builder(
  shrinkWrap: true,
  itemCount: _mahasiswa.length,
  itemBuilder: (context, index) => Card(
    color: Colors.blue[200],
    margin: const EdgeInsets.all(15),
    child: ListTile(
      title: Text('Nama: ${_mahasiswa[index]['nama']}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NIM: ${_mahasiswa[index]['nim']}'),
          Text('Jurusan: ${_mahasiswa[index]['jurusan']}'), // Tampilkan jurusan
          Text('ALAMAT: ${_mahasiswa[index]['alamat']}'),
        ],
      ),
      leading: _mahasiswa[index]['photo'] != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.memory(
                _mahasiswa[index]['photo'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            )
          : null,
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showForm(_mahasiswa[index]['id']),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteItem(_mahasiswa[index]['id']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}