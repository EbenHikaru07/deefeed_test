// Import yang diperlukan
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user?.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        _userData = userDoc.data() as Map<String, dynamic>;
      });
    }
  }

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
                        size: 45,
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userData?['nama_lengkap'] ?? 'Nama Profil',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _userData?['pekerjaan'] ?? 'Pekerjaan',
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
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications,
                        color: Colors.black,
                        size: 34,
                      ),
                      SizedBox(width: 16),
                    ],
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
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 1),
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
                                'assets/images/alat_keren1.png',
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
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(8.0),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('data_alat')
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
                                final int totalAlat = documents.length;
                                final int alatAktif = documents
                                    .where((doc) =>
                                        doc['status_alat'] == 'Berjalan')
                                    .length;

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$totalAlat Alat Pakan',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$alatAktif/$totalAlat Alat Pakan Aktif',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              },
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
              color: const Color.fromARGB(255, 174, 196, 214),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors
                          .blue[200], // Warna latar belakang dengan opacity 0.1
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Kolam',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.water, // menggunakan ikon air
                              color: Colors.blue, // warna biru
                              size: 30, // ukuran 40
                            ),
                            SizedBox(
                                width: 8), // memberi jarak antara ikon dan teks
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () {
                                _showAddDataForm(context);
                              },
                              icon: Icon(Icons.add_circle_sharp,
                                  color: Colors.blue),
                              label: Text(
                                'Tambah Kolam',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('datakolam')
                                .where('user_uid', isEqualTo: _user?.uid)
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
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
                                );
                              }

                              return Column(
                                children:
                                    documents.map((DocumentSnapshot document) {
                                  final Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;
                                  return GestureDetector(
                                    onTap: () async {
                                      final DocumentSnapshot userDoc =
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(_user?.uid)
                                              .get();

                                      if (userDoc.exists) {
                                        final Map<String, dynamic> userData =
                                            userDoc.data()
                                                as Map<String, dynamic>;

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailPage(
                                              data: {
                                                'kode_alat': data['kode_alat'],
                                                'nama_alat': data['nama_alat'],
                                                'nama_kolam':
                                                    data['nama_kolam'],
                                                'luas_kolam':
                                                    data['luas_kolam'],
                                                'jenis_ikan':
                                                    data['jenis_ikan'],
                                                'jumlah_ikan':
                                                    data['jumlah_ikan'],
                                                'user_data': userData,
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Dismissible(
                                      key: Key(data['uid_kolam']),
                                      confirmDismiss: (direction) async {
                                        // Membuat dialog konfirmasi penghapusan
                                        return showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Konfirmasi"),
                                              content: Text(
                                                  "Apakah Anda yakin ingin menghapus kolam ini?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                  child: Text("Tidak"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('datakolam')
                                                        .doc(data['uid_kolam'])
                                                        .delete();
                                                  },
                                                  child: Text("Ya"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      background: Container(
                                        color: Colors.red,
                                        child: Icon(Icons.delete),
                                        alignment: Alignment.centerRight,
                                        padding: EdgeInsets.only(right: 20),
                                      ),
                                      direction: DismissDirection.endToStart,
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        width: double.infinity,
                                        height: 85,
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              spreadRadius: 1,
                                              blurRadius: 1,
                                              offset: Offset(1, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Image.network(
                                                data['image'],
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    data['nama_kolam'],
                                                    style: TextStyle(
                                                      color: Colors.blue[600],
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    data['nama_alat'],
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 5.0),
                                              child: Icon(
                                                Icons.chevron_right,
                                                color: Colors.black87,
                                                size: 40,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
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
  String? _userUid;

  @override
  void initState() {
    super.initState();
    // Simulasi pengambilan user_uid dari autentikasi pengguna saat ini
    _userUid = FirebaseAuth.instance.currentUser?.uid;
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
        String uidAlat = alatSnapshot.docs.first['uid_alat'];

        // Update status_alat ke 'berjalan' di data_alat
        await FirebaseFirestore.instance
            .collection('data_alat')
            .doc(alatDocId)
            .update({'status_alat': 'Berjalan'});

        // Tambahkan data ke datakolam
        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('datakolam').add({
          'image': imageUrl,
          'user_uid': _userUid,
          'uid_alat': uidAlat,
          'kode_alat': _kodeAlat,
          'nama_alat': _namaAlat,
          'nama_kolam': _namaKolam,
          'luas_kolam': _luasKolam,
          'jenis_ikan': _jenisIkan,
          'jumlah_ikan': _jumlahIkan,
          'uid_kolam': '',
        });

        // Perbarui dokumen dengan uid_kolam
        await docRef.update({'uid_kolam': docRef.id});

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

  Future<List<String>> _getPendingNamaAlat() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('data_alat')
        .where('status_alat', isEqualTo: 'Pending')
        .get();

    return snapshot.docs.map((doc) => doc['nama_alat'] as String).toList();
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
            Container(
              padding: EdgeInsets.all(15.0),
              color: Colors.white54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tambah Data Kolam',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
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
            SizedBox(height: 10),
            FutureBuilder<List<String>>(
              future: _getPendingNamaAlat(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<String> pendingNamaAlat = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Nama Alat',
                      border: OutlineInputBorder(),
                    ),
                    value: _namaAlat,
                    onChanged: (String? value) async {
                      setState(() {
                        _namaAlat = value;
                      });

                      final QuerySnapshot snapshot = await FirebaseFirestore
                          .instance
                          .collection('data_alat')
                          .where('nama_alat', isEqualTo: value)
                          .get();
                      final List<DocumentSnapshot> documents = snapshot.docs;
                      if (documents.isNotEmpty) {
                        setState(() {
                          _kodeAlat = documents.first.get('kode_alat');
                        });
                      } else {
                        setState(() {
                          _kodeAlat = '';
                        });
                      }
                    },
                    items: pendingNamaAlat
                        .map((namaAlat) => DropdownMenuItem<String>(
                              value: namaAlat,
                              child: Text(namaAlat),
                            ))
                        .toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama Alat tidak boleh kosong';
                      }
                      return null;
                    },
                  );
                }
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Kode Alat',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _kodeAlat),
              enabled: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kode Alat tidak boleh kosong';
                }
                return null;
              },
              onSaved: (value) {
                _kodeAlat = value ?? '';
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Nama Kolam',
                border: OutlineInputBorder(),
              ),
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
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Luas Kolam (m²)',
                border: OutlineInputBorder(),
              ),
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
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Jenis Ikan',
                border: OutlineInputBorder(),
              ),
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
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Jumlah Ikan (ekor)',
                border: OutlineInputBorder(),
              ),
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
            SizedBox(height: 18),
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
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
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
