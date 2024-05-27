import 'package:deefeed2/jadwal/jadwal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(DetailPage(
    data: {},
  ));
}

class DetailPage extends StatefulWidget {
  @override
  final Map<String, dynamic> data;

  DetailPage({required this.data});
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<FeedingSchedule> schedules = [];
  List<Map<String, dynamic>> feeders = [];
  final FirestoreService firestoreService = FirestoreService();
  Map<String, String> alatNames = {};
  List<Map<String, dynamic>> filteredFeeders = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
    _loadFeeders();
    _filterFeeders();
  }

  void _filterFeeders() {
    // Filter feeders based on selected kode_alat
    setState(() {
      filteredFeeders = feeders
          .where((feeder) => feeder['kode_alat'] == widget.data['kode_alat'])
          .toList();
    });
  }

  Future<void> _loadSchedules() async {
    List<FeedingSchedule> loadedSchedules =
        await firestoreService.getSchedulesByKodeAlat(widget.data['kode_alat']);
    setState(() {
      schedules = loadedSchedules;
    });
  }

  Future<void> _loadFeeders() async {
    Map<String, dynamic> selectedData = widget.data;

    List<Map<String, dynamic>> loadedFeeders =
        await firestoreService.getFeeders();
    setState(() {
      feeders = loadedFeeders;
    });

    List<Map<String, dynamic>> filteredFeeders = loadedFeeders.where((feeder) {
      return feeder['kode_alat'] == selectedData['kode_alat'];
    }).toList();
    setState(() {
      feeders = filteredFeeders;
    });
    List<String> kodeAlatList = loadedFeeders
        .where((feeder) =>
            feeder.containsKey('kode_alat') && feeder['kode_alat'] != null)
        .map((feeder) => feeder['kode_alat'] as String)
        .toList();

    if (kodeAlatList.isNotEmpty) {
      Map<String, String> loadedAlatNames =
          await firestoreService.getAlatNamesByKodeAlat(kodeAlatList);
      setState(() {
        alatNames = loadedAlatNames;
      });
    }
  }

  void _showAddScheduleModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddScheduleModal(
          onSave: (schedule) async {
            setState(() {
              schedules.add(schedule);
            });

            // Mendapatkan kode_alat, nama_alat, dan nama_kolam dari widget.data
            String kodeAlat = widget.data['kode_alat'];
            String namaAlat = widget.data['nama_alat'];
            String namaKolam = widget.data['nama_kolam'];

            // Menambahkan jadwal ke Firestore
            await firestoreService.addScheduleWithDetails(
                schedule, kodeAlat, namaAlat, namaKolam);
          },
          selectedData: {
            'kode_alat': widget.data['kode_alat'],
            'nama_alat': widget.data['nama_alat'],
            'nama_kolam': widget.data['nama_kolam'],
          },
        );
      },
    );
  }

  void _showAddFeederModal(BuildContext context) {
    // Implementasi untuk menambahkan feeder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: Colors.blue,
                height: 130,
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Opacity(
                        opacity: 0.6,
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/alat_keren1.png',
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DeeFeed',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Ikan aman, Hati ga aman',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.brown[100],
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      SizedBox(
                          height:
                              160), // Padding tambahan untuk menurunkan posisi
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Feeder',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    _showAddFeederModal(context);
                                  },
                                  icon: Icon(Icons.add),
                                  label: Text('Tambah Feeder'),
                                ),
                              ],
                            ),
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: feeders.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> feeder = feeders[index];
                                  String? kodeAlat = feeder['kode_alat'];
                                  if (kodeAlat == null ||
                                      !alatNames.containsKey(kodeAlat)) {
                                    return SizedBox.shrink();
                                  }
                                  String namaAlat = alatNames[kodeAlat]!;
                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 1),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.wifi),
                                              onPressed: () {
                                                // Tambahkan logika untuk tombol play di sini
                                              },
                                            ),
                                            Text(
                                              namaAlat,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.play_arrow),
                                              onPressed: () {
                                                // Tambahkan logika untuk tombol play di sini
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.stop),
                                              onPressed: () {
                                                // Tambahkan logika untuk tombol pause di sini
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.settings),
                                              onPressed: () {
                                                // Tambahkan logika untuk tombol setting di sini
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jadwal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              _showAddScheduleModal(context);
                            },
                            icon: Icon(Icons.add),
                            label: Text('Tambah Jadwal'),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: schedules.length,
                          itemBuilder: (context, index) {
                            FeedingSchedule schedule = schedules[index];
                            return ListTile(
                              title: Text(
                                'Jadwal ${index + 1}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Mulai: ${DateFormat('dd/MM/yyyy').format(schedule.startDate)}'),
                                  Text(
                                      'Selesai: ${DateFormat('dd/MM/yyyy').format(schedule.endDate)}'),
                                  ...schedule.feedings.map((feeding) {
                                    return Text(
                                        'Pemberian Makan: ${feeding.startTime.format(context)} - ${feeding.endTime.format(context)}');
                                  }).toList(),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 350,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white70, width: 5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp2()),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.data['nama_kolam'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.grey,
                      thickness: 2,
                      height: 0,
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jenis Ikan',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            widget.data['jenis_ikan'],
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Pakan (g)',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            widget.data['total_pakan'],
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jumlah Ikan (ekor)',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            widget.data['jumlah_ikan'],
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 45,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  Text(
                    'Kembali',
                    style: TextStyle(
                      color: Colors.white,
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
    );
  }
}

class FeedingSchedule {
  DateTime startDate;
  DateTime endDate;
  List<Feeding> feedings;

  FeedingSchedule({
    required this.startDate,
    required this.endDate,
    required this.feedings,
  });

  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'feedings': feedings.map((feeding) => feeding.toMap()).toList(),
    };
  }
}

class Feeding {
  TimeOfDay startTime;
  TimeOfDay endTime;

  Feeding({
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
    };
  }
}

class FirestoreService {
  final CollectionReference schedulesCollection =
      FirebaseFirestore.instance.collection('schedules');
  final CollectionReference alatCollection =
      FirebaseFirestore.instance.collection('data_alat');
  final CollectionReference kolamCollection =
      FirebaseFirestore.instance.collection('datakolam');
  Future<void> addSchedule(FeedingSchedule schedule) async {
    await schedulesCollection.add(schedule.toMap());
  }

  Future<void> addScheduleWithDetails(FeedingSchedule schedule, String kodeAlat,
      String namaAlat, String namaKolam) async {
    // Menambahkan jadwal ke Firestore
    DocumentReference docRef = await schedulesCollection.add(schedule.toMap());

    // Menambahkan detail jadwal (kode_alat, nama_alat, nama_kolam) ke Firestore
    await docRef.update({
      'kode_alat': kodeAlat,
      'nama_alat': namaAlat,
      'nama_kolam': namaKolam,
    });
  }

  Future<List<FeedingSchedule>> getSchedulesByKodeAlat(String kodeAlat) async {
    QuerySnapshot querySnapshot =
        await schedulesCollection.where('kode_alat', isEqualTo: kodeAlat).get();
    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return FeedingSchedule(
        startDate: (data['startDate'] as Timestamp).toDate(),
        endDate: (data['endDate'] as Timestamp).toDate(),
        feedings: (data['feedings'] as List<dynamic>).map((feedingData) {
          Map<String, dynamic> feedingMap = feedingData as Map<String, dynamic>;
          List<String> startTimeParts =
              (feedingMap['startTime'] as String).split(':');
          List<String> endTimeParts =
              (feedingMap['endTime'] as String).split(':');
          return Feeding(
            startTime: TimeOfDay(
              hour: int.parse(startTimeParts[0]),
              minute: int.parse(startTimeParts[1]),
            ),
            endTime: TimeOfDay(
              hour: int.parse(endTimeParts[0]),
              minute: int.parse(endTimeParts[1]),
            ),
          );
        }).toList(),
      );
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getFeeders() async {
    QuerySnapshot querySnapshot = await kolamCollection.get();
    return querySnapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  }

  Future<Map<String, String>> getAlatNamesByKodeAlat(
      List<String> kodeAlatList) async {
    QuerySnapshot querySnapshot =
        await alatCollection.where('kode_alat', whereIn: kodeAlatList).get();
    Map<String, String> alatNames = {};
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String kodeAlat = data['kode_alat'] as String;
      String namaAlat = data['nama_alat'] as String;
      alatNames[kodeAlat] = namaAlat;
    }
    return alatNames;
  }
}

class AddScheduleModal extends StatefulWidget {
  final Function(FeedingSchedule) onSave;
  final Map<String, String> selectedData;

  AddScheduleModal({required this.onSave, required this.selectedData});

  @override
  _AddScheduleModalState createState() => _AddScheduleModalState();
}

class _AddScheduleModalState extends State<AddScheduleModal> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  List<Feeding> _feedings = [];

  void _addFeeding(TimeOfDay startTime, TimeOfDay endTime) {
    setState(() {
      _feedings.add(Feeding(startTime: startTime, endTime: endTime));
    });
  }

  void _removeFeeding(int index) {
    setState(() {
      _feedings.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tambah Jadwal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: false, // Menyembunyikan widget
                  child: Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Kode Alat',
                      ),
                      initialValue: widget.selectedData['kode_alat'],
                      enabled: false,
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Kolam',
                    ),
                    initialValue: widget.selectedData['nama_kolam'],
                    enabled: false,
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Alat',
                    ),
                    initialValue: widget.selectedData['nama_alat'],
                    enabled: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tanggal Mulai',
                    ),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                        });
                      }
                    },
                    readOnly: true,
                    controller: TextEditingController(
                      text: DateFormat('dd/MM/yyyy').format(_startDate),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tanggal Selesai',
                    ),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {
                          _endDate = picked;
                        });
                      }
                    },
                    readOnly: true,
                    controller: TextEditingController(
                      text: DateFormat('dd/MM/yyyy').format(_endDate),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              'Pemberian Makan',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            // Menampilkan daftar jam pakan tambahan
            // Menampilkan daftar jam pakan tambahan
            ListView.builder(
              shrinkWrap: true,
              itemCount: _feedings.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pemberian Makan ${index + 1}'),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Waktu Mulai:'),
                              TextButton(
                                onPressed: () async {
                                  TimeOfDay? newTime = await showTimePicker(
                                    context: context,
                                    initialTime: _feedings[index].startTime,
                                  );
                                  if (newTime != null) {
                                    setState(() {
                                      _feedings[index].startTime = newTime;
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time),
                                    SizedBox(width: 4.0),
                                    Text(_feedings[index]
                                        .startTime
                                        .format(context)),
                                  ],
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
                              Text('Waktu Selesai:'),
                              TextButton(
                                onPressed: () async {
                                  TimeOfDay? newTime = await showTimePicker(
                                    context: context,
                                    initialTime: _feedings[index].endTime,
                                  );
                                  if (newTime != null) {
                                    setState(() {
                                      _feedings[index].endTime = newTime;
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time),
                                    SizedBox(width: 4.0),
                                    Text(_feedings[index]
                                        .endTime
                                        .format(context)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _feedings.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                  ],
                );
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _feedings.add(Feeding(
                      startTime: TimeOfDay.now(), endTime: TimeOfDay.now()));
                });
              },
              child: Text('Tambah Pemberian Makan'),
            ),

            SizedBox(height: 10),

            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                widget.onSave(
                  FeedingSchedule(
                    startDate: _startDate,
                    endDate: _endDate,
                    feedings: _feedings,
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('Simpan Jadwal'),
            ),
          ],
        ),
      ),
    );
  }
}
