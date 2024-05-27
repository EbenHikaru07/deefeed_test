// Import yang diperlukan
import 'package:deefeed2/tambah_alat.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:deefeed2/bottombar/bottom_nav_bar.dart';
import 'package:deefeed2/detail/detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

// Main function
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Dashboard());
}

// Dashboard StatelessWidget
class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: DashboardPage(),
    );
  }
}

// DashboardPage StatefulWidget
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

// DashboardPage State
class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  void _showAddDataForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: AddDataForm(),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Bagian atas dengan warna biru
// Container 1
          Container(
            color: Colors.blue[100],
            height: MediaQuery.of(context).size.height * 0.42,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned(
                  top: 50,
                  left: 16,
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_circle_sharp,
                        color: Colors.black,
                        size: 35,
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nama Profil',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Pekerjaan',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 16,
                  child: Icon(
                    Icons.notifications,
                    color: Colors.black,
                    size: 34,
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.16,
                  left: (MediaQuery.of(context).size.width - 320) / 2,
                  child: Container(
                    width: 320,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          spreadRadius: 3,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Image.asset(
                                'assets/images/alat_keren1.png', // Ganti dengan path gambar Anda
                                width: 300,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12, // Warna bayangan
                                  spreadRadius: 2, // Penyebaran bayangan
                                  blurRadius: 2, // Jarak blur bayangan
                                  offset: Offset(0, 1), // Offset bayangan
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '15 Alat Pakan',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '10 Alat Pakan Aktif',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bagian bawah dengan warna hijau
          // Container 2
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: SingleChildScrollView(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kolam',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 150,
                          child: TextButton.icon(
                            onPressed: () {
                              _showAddDataForm(context);
                            },
                            icon: Icon(Icons.add_circle_sharp,
                                color: Colors
                                    .blue), // Ikon tambah dengan warna hitam
                            label: Text(
                              'Tambah Data',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight
                                      .bold), // Teks dengan warna hitam
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors
                                  .transparent, // Latar belakang transparan
                            ),
                          ),
                        ),
                      ],
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('datakolam')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        final List<DocumentSnapshot> documents =
                            snapshot.data!.docs;
                        if (documents.isEmpty) {
                          return Center(
                            child: Text(
                              'Tidak ada data',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: documents.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Map<String, dynamic> data =
                                documents[index].data() as Map<String, dynamic>;
                            return GestureDetector(
                              onTap: () {
                                // Navigasi ke halaman detail dengan membawa data kolam yang dipilih
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPage(data: {
                                      'kode_alat': data['kode_alat'],
                                      'nama_alat': data[
                                          'nama_alat'], // Mengirim nama_alat dari data Firestore
                                      'nama_kolam': data[
                                          'nama_kolam'], // Mengirim nama_alat dari data Firestore
                                      'luas_kolam': data[
                                          'luas_kolam'], // Mengirim nama_alat dari data Firestore
                                      'jenis_ikan': data[
                                          'jenis_ikan'], // Mengirim nama_alat dari data Firestore
                                      'jumlah_ikan': data[
                                          'jumlah_ikan'], // Mengirim nama_alat dari data Firestore
                                      'total_pakan': data[
                                          'total_pakan'], // Tambahkan data lainnya yang ingin Anda kirim ke DetailPage
                                    }),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                height: 100,
                                margin: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Image.network(
                                        data[
                                            'image'], // Tampilkan gambar dari URL Firebase
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            data[
                                                'nama_alat'], // Tampilkan nama alat dari data Firestore
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            data[
                                                'nama_kolam'], // Tampilkan deskripsi alat dari data Firestore
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 15,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            data[
                                                'nama_kolam'], // Tampilkan deskripsi alat dari data Firestore
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 15,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right:
                                              15.0), // Menggeser ikon lebih ke kiri
                                      child: Icon(
                                        Icons.chevron_right,
                                        color: Colors.black87,
                                        size: 40, // Memperbesar ukuran ikon
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAlatForm(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class AddDataForm extends StatefulWidget {
  @override
  _AddDataFormState createState() => _AddDataFormState();
}

class _AddDataFormState extends State<AddDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  File? _image;
  String? _kodeAlat;
  String? _namaAlat;
  String? _namaKolam;
  String? _luasKolam;
  String? _jenisIkan;
  String? _jumlahIkan;
  String? _totalPakan;
  double _currentSliderValue = 20;
  @override
  void initState() {
    super.initState();
  }

  Future<void> _showLoadingDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Loading..."),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Data telah ditambah"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close the form modal as well
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageAndAddData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Tampilkan modal loading
        _showLoadingDialog();

        String? imageUrl;
        if (_image != null) {
          firebase_storage.Reference ref = firebase_storage
              .FirebaseStorage.instance
              .ref()
              .child('images')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
          await ref.putFile(_image!);
          imageUrl = await ref.getDownloadURL();
        }

        // Ambil ID dokumen dari data_alat berdasarkan kode_alat yang dipilih
        QuerySnapshot alatSnapshot = await FirebaseFirestore.instance
            .collection('data_alat')
            .where('kode_alat', isEqualTo: _kodeAlat)
            .get();
        String alatDocId = alatSnapshot.docs.first.id;

        // Update status_alat ke 'berjalan' di data_alat
        await FirebaseFirestore.instance
            .collection('data_alat')
            .doc(alatDocId)
            .update({'status_alat': 'berjalan'});

        // Tambahkan data ke datakolam
        await FirebaseFirestore.instance.collection('datakolam').add({
          'image': imageUrl,
          'kode_alat': _kodeAlat,
          'nama_alat': _namaAlat,
          'nama_kolam': _namaKolam,
          'luas_kolam': _luasKolam,
          'jenis_ikan': _jenisIkan,
          'jumlah_ikan': _jumlahIkan,
          'total_pakan': _currentSliderValue.toInt().toString(),
        });

        Navigator.of(context).pop();
        _showConfirmationDialog();
      } catch (e) {
        Navigator.of(context).pop();
        print('Error uploading image and adding data: $e');
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _uploadImageAndAddData();
    }
  }

  Future<List<String>> _getPendingKodeAlat() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('data_alat')
        .where('status_alat', isEqualTo: 'pending')
        .get();

    return snapshot.docs.map((doc) => doc['kode_alat'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            if (_image == null)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: Icon(Icons.add_a_photo, size: 50),
                ),
              )
            else
              Container(
                height: 250,
                color: Colors.grey[200],
                child: Image.file(_image!, fit: BoxFit.cover),
              ),
            Row(
              children: <Widget>[
                Expanded(
                  child: FutureBuilder<List<String>>(
                    future: _getPendingKodeAlat(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        List<String> pendingKodeAlat = snapshot.data!;
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(labelText: 'Kode Alat'),
                          value: _kodeAlat,
                          onChanged: (String? value) async {
                            setState(() {
                              _kodeAlat = value;
                            });

                            final QuerySnapshot snapshot =
                                await FirebaseFirestore.instance
                                    .collection('data_alat')
                                    .where('kode_alat', isEqualTo: value)
                                    .get();
                            final List<DocumentSnapshot> documents =
                                snapshot.docs;
                            if (documents.isNotEmpty) {
                              setState(() {
                                _namaAlat = documents.first.get('nama_alat');
                              });
                            } else {
                              setState(() {
                                _namaAlat = '';
                              });
                            }
                          },
                          items: pendingKodeAlat
                              .map((kodeAlat) => DropdownMenuItem<String>(
                                    value: kodeAlat,
                                    child: Text(kodeAlat),
                                  ))
                              .toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Kode Alat tidak boleh kosong';
                            }
                            return null;
                          },
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Nama Alat'),
                    controller: TextEditingController(text: _namaAlat),
                    enabled: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama Alat tidak boleh kosong';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _namaAlat = value ?? '';
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Nama Kolam'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama Kolam tidak boleh kosong';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _namaKolam = value;
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Luas Kolam (m²)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Luas Kolam tidak boleh kosong';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _luasKolam = value;
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Jenis Ikan'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jenis Ikan tidak boleh kosong';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _jenisIkan = value;
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration:
                        InputDecoration(labelText: 'Jumlah Ikan (ekor)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah Ikan tidak boleh kosong';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _jumlahIkan = value;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jumlah Pakan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Slider(
                        value: _currentSliderValue,
                        max: 1000,
                        divisions: 10,
                        label: _currentSliderValue.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _currentSliderValue = value;
                          });
                        },
                      ),
                      Text(' Total: ${_currentSliderValue.round()} (g)'),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.red, width: 2.0),
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                  ),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.green, width: 2.0),
                    ),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showAddAlatForm(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => FormPengisianDataPage()),
  );
}
