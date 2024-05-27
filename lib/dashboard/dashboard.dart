// Import yang diperlukan
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:deefeed2/bottombar/bottom_nav_bar.dart';
import 'package:deefeed2/detail/detail.dart';
import 'package:deefeed2/tambah_data/tambah_data.dart';

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
                            padding: EdgeInsets.all(15.0),
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
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 150,
                      child: TextButton.icon(
                        onPressed: () {
                          // Navigasi ke halaman penambahan data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PenambahanDataPage()), // Ganti dengan halaman penambahan data Anda
                          );
                        },
                        icon: Icon(Icons.add_circle_sharp,
                            color:
                                Colors.blue), // Ikon tambah dengan warna hitam
                        label: Text(
                          'Tambah Data',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight:
                                  FontWeight.bold), // Teks dengan warna hitam
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Colors.transparent, // Latar belakang transparan
                          padding: EdgeInsets.symmetric(
                              vertical: 10), // Atur padding
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigasi ke halaman detail
                        // Navigator.push(
                        //  context,
                        //  MaterialPageRoute(
                        //      builder: (context) =>
                        //          DetailPage()), // Ganti dengan halaman detail Anda
                        // );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 70,
                        margin: EdgeInsets.symmetric(vertical: 15),
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
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(
                                'assets/images/alat_keren1.png', // Ganti dengan path gambar Anda
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Nama Alat',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Deskripsi Alat',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 15.0), // Menggeser ikon lebih ke kiri
                              child: Icon(
                                Icons.chevron_right,
                                color: Colors.black87,
                                size: 40, // Memperbesar ukuran ikon
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 70,
                      margin: EdgeInsets.symmetric(vertical: 15),
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
                      child: Center(
                        child: Text(
                          'Rectangle 2',
                          style: TextStyle(color: Colors.green, fontSize: 20),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 70,
                      margin: EdgeInsets.symmetric(vertical: 15),
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
                      child: Center(
                        child: Text(
                          'Rectangle 3',
                          style: TextStyle(color: Colors.green, fontSize: 20),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 70,
                      margin: EdgeInsets.symmetric(vertical: 15),
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
                      child: Center(
                        child: Text(
                          'Rectangle 3',
                          style: TextStyle(color: Colors.green, fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
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
