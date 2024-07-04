import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deefeed2/bottombar/bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class JadwalPage extends StatefulWidget {
  @override
  _JadwalPageState createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  bool showJadwal = true;
  String searchQuery = '';
  String filterOption = 'Terdekat';
  String searchKolamQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Data'),
        backgroundColor:
            Colors.blue.shade200, // Mengatur warna app bar menjadi putih
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        showJadwal = true;
                      });
                    },
                    child: Container(
                      color: showJadwal
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'List Jadwal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: showJadwal
                                ? Colors.blue.shade900
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        showJadwal = false;
                      });
                    },
                    child: Container(
                      color: showJadwal
                          ? Colors.grey.shade200
                          : Colors.blue.shade100,
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'List Alat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: showJadwal
                                ? Colors.grey.shade800
                                : Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showJadwal)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: filterOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          filterOption = newValue!;
                        });
                      },
                      items: <String>['Terdekat', 'Terjauh']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Urut Jadwal',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchKolamQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Cari Kolam',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!showJadwal)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          Expanded(
            child: showJadwal ? _buildJadwalList() : _buildAlatList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        onItemTapped: (index) {},
      ),
    );
  }

  Widget _buildJadwalList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('data_jadwal').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        var documents = snapshot.data!.docs.toList();

        documents.sort((a, b) {
          DateTime startDateA = a['startDate'] != null
              ? DateFormat('dd-MM-yyyy').parse(a['startDate'])
              : DateTime.now();
          DateTime startDateB = b['startDate'] != null
              ? DateFormat('dd-MM-yyyy').parse(b['startDate'])
              : DateTime.now();
          return filterOption == 'Terdekat'
              ? startDateA.compareTo(startDateB)
              : startDateB.compareTo(startDateA);
        });

        documents = documents.where((doc) {
          String namaKolam = doc['nama_kolam']?.toLowerCase() ?? '';
          return namaKolam.contains(searchKolamQuery);
        }).toList();

        return ListView(
          children: documents.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            return Card(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              color: Colors.blue.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data['nama_kolam'] ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              data['nama_alat'] ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.info_outline, color: Colors.grey),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Divider(height: 20, thickness: 2, color: Colors.black),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.date_range, color: Colors.grey),
                            SizedBox(width: 8.0),
                            Text(
                              ' ${data['startDate'] ?? 'Unknown'}',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Sampai',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.date_range, color: Colors.grey),
                            SizedBox(width: 8.0),
                            Text(
                              '${data['endDate'] ?? 'Unknown'}',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.grey),
                                SizedBox(width: 8.0),
                                Text(
                                  'Jam Pagi: ${data['jamPagi'] ?? 'Unknown'} (${(data['jumlah_pakan'] ?? 0).toStringAsFixed(0)} gram)',
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.grey),
                                SizedBox(width: 8.0),
                                Text(
                                  'Jam Sore: ${data['jamSore'] ?? 'Unknown'} (${(data['jumlah_pakan'] ?? 0).toStringAsFixed(0)} gram)',
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAlatList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('data_alat').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        var documents = snapshot.data!.docs.where((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String namaAlat = data['nama_alat']?.toLowerCase() ?? '';
          return namaAlat.contains(searchQuery);
        }).toList();

        return ListView(
          children: documents.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            int jumlahPakan = 255;
            double isiPakan = jumlahPakan /
                500; // Menyesuaikan dengan maksimum isi pakan (500)
            isiPakan =
                isiPakan.clamp(0.0, 1.0); // Clamp nilai isiPakan antara 0 dan 1
            return Card(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10.0),
                title: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.blue,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            height: isiPakan * 130,
                            decoration: BoxDecoration(
                              color: isiPakan >= 0.8
                                  ? Colors.green
                                  : isiPakan >= 0.5
                                      ? Colors.yellow
                                      : isiPakan >= 0.2
                                          ? Colors.orange
                                          : Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${(isiPakan * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: Text(
                              isiPakan >= 0.85
                                  ? 'Full'
                                  : isiPakan >= 0.55
                                      ? 'Normal'
                                      : isiPakan >= 0.25
                                          ? 'Warning'
                                          : 'Danger',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['nama_alat'] ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          Text(
                            'Kode Alat: ${data['kode_alat'] ?? 'Unknown'}',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // Tambahkan logika untuk menampilkan detail alat
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
