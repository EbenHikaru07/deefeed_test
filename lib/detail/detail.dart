import 'package:deefeed2/detail/tambah_jadwal.dart';
import 'package:deefeed2/jadwal/jadwal.dart';
import 'package:deefeed2/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

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
  late Map<String, dynamic> _userData;
  double progress = 0.0; // Buat variabel progress di luar build method
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  double _levelPakan = 0;
  @override
  void initState() {
    super.initState();
    _loadSchedules();
    _loadFeeders();
    _filterFeeders();
    _fetchLevelPakan();
    _userData = widget.data['user_data'];
  }

  void _fetchLevelPakan() async {
    final snapshot = await _databaseRef.child('data_pakan/level_pakan').get();
    if (snapshot.exists) {
      final levelPakan = snapshot.value as num?; // Mengambil level_pakan
      final levelPakanDouble = (levelPakan?.toDouble() ?? 0) /
          100.0; // Konversi dari persen ke desimal
      setState(() {
        _levelPakan = levelPakanDouble;
      });
    }
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
      filteredFeeders = filteredFeeders;
    });

    List<String> kodeAlatList = filteredFeeders
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

  //void _showAddFeederModal(BuildContext context) {
  //  // Implementasi untuk menambahkan feeder
  // }
  void _deleteSchedule(String uidJadwal) async {
    BuildContext currentContext = context;
    try {
      // Menampilkan dialog konfirmasi sebelum menghapus jadwal
      showDialog(
        context: currentContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Konfirmasi"),
            content: Text("Apakah Anda yakin ingin menghapus jadwal ini?"),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  // Hapus dokumen dengan UID yang sesuai dari koleksi 'data_jadwal'
                  await FirebaseFirestore.instance
                      .collection('data_jadwal')
                      .doc(uidJadwal)
                      .delete();
                  // Hapus jadwal dari daftar schedules
                  int indexToDelete = schedules.indexWhere(
                      (schedule) => schedule.uidJadwal == uidJadwal);
                  if (indexToDelete != -1) {
                    setState(() {
                      schedules.removeAt(indexToDelete);
                    });
                  }
                  // Tampilkan snackbar atau pesan sukses
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    SnackBar(
                      content: Text('Jadwal berhasil dihapus'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Text("Ya"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Tidak"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Tangani kesalahan jika penghapusan gagal
      print('Error deleting schedule: $e');
      // Tampilkan snackbar atau pesan kesalahan
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus jadwal'),
        ),
      );
    }
  }

  void _showEditScheduleModal(BuildContext context, FeedingSchedule schedule) {
    // Controller untuk mengatur nilai input pada form
    TextEditingController startDateController = TextEditingController();
    TextEditingController endDateController = TextEditingController();
    TextEditingController jamPagiController = TextEditingController();
    TextEditingController jamSoreController = TextEditingController();
    double jumlahPakanValue = schedule.jumlahPakan;

    // Mengisi controller dengan data jadwal yang akan diedit
    startDateController.text =
        DateFormat('yyyy-MM-dd').format(schedule.startDate);
    endDateController.text = DateFormat('yyyy-MM-dd').format(schedule.endDate);
    jamPagiController.text = schedule.jamPagi != null
        ? '${schedule.jamPagi!.hour.toString().padLeft(2, '0')}:${schedule.jamPagi!.minute.toString().padLeft(2, '0')}'
        : '';
    jamSoreController.text = schedule.jamSore != null
        ? '${schedule.jamSore!.hour.toString().padLeft(2, '0')}:${schedule.jamSore!.minute.toString().padLeft(2, '0')}'
        : '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Jadwal'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tanggal Mulai'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: startDateController,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'yyyy-mm-dd',
                          suffixIcon: OutlinedButton.icon(
                            onPressed: () async {
                              DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate: schedule.startDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (selectedDate != null) {
                                setState(() {
                                  startDateController.text =
                                      DateFormat('yyyy-MM-dd')
                                          .format(selectedDate);
                                });
                              }
                            },
                            icon: Icon(Icons.calendar_month_outlined),
                            label: Text('Edit'),
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(Colors.blue),
                              foregroundColor:
                                  WidgetStateProperty.all<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Text('Tanggal Selesai'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: endDateController,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'yyyy-mm-dd',
                          suffixIcon: OutlinedButton.icon(
                            onPressed: () async {
                              DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate: schedule.endDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (selectedDate != null) {
                                setState(() {
                                  endDateController.text =
                                      DateFormat('yyyy-MM-dd')
                                          .format(selectedDate);
                                });
                              }
                            },
                            icon: Icon(Icons.calendar_month_outlined),
                            label: Text('Edit'),
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(Colors.blue),
                              foregroundColor:
                                  WidgetStateProperty.all<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Text('Jam Pagi'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: jamPagiController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: OutlinedButton.icon(
                            onPressed: () async {
                              TimeOfDay? selectedTime = await showTimePicker(
                                context: context,
                                initialTime:
                                    schedule.jamPagi ?? TimeOfDay.now(),
                              );
                              if (selectedTime != null) {
                                setState(() {
                                  schedule.jamPagi = selectedTime;
                                  jamPagiController.text = schedule.jamPagi !=
                                          null
                                      ? '${schedule.jamPagi!.hour.toString().padLeft(2, '0')}:${schedule.jamPagi!.minute.toString().padLeft(2, '0')}'
                                      : '';
                                });
                              }
                            },
                            icon: Icon(Icons.timer_outlined),
                            label: Text('Edit'),
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(Colors.blue),
                              foregroundColor:
                                  WidgetStateProperty.all<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Text('Jam Sore'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: jamSoreController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: OutlinedButton.icon(
                            onPressed: () async {
                              TimeOfDay? selectedTime = await showTimePicker(
                                context: context,
                                initialTime:
                                    schedule.jamSore ?? TimeOfDay.now(),
                              );
                              if (selectedTime != null) {
                                setState(() {
                                  schedule.jamSore = selectedTime;
                                  jamSoreController.text = schedule.jamSore !=
                                          null
                                      ? '${schedule.jamSore!.hour.toString().padLeft(2, '0')}:${schedule.jamSore!.minute.toString().padLeft(2, '0')}'
                                      : '';
                                });
                              }
                            },
                            icon: Icon(Icons.timer_outlined),
                            label: Text('Edit'),
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(Colors.blue),
                              foregroundColor:
                                  WidgetStateProperty.all<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Text('Jumlah Pakan (g)'),
                InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                      value: jumlahPakanValue,
                      items: List.generate(10, (index) => (index + 1) * 100)
                          .map((value) => DropdownMenuItem<double>(
                                value: value.toDouble(),
                                child: Text(value.toString()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        jumlahPakanValue = value!;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Memperbarui data jadwal berdasarkan nilai yang dimasukkan dari formulir edit
                DateTime startDate = DateTime.parse(startDateController.text);
                DateTime endDate = DateTime.parse(endDateController.text);
                TimeOfDay? jamPagi = TimeOfDay(
                  hour: int.parse(jamPagiController.text.split(':')[0]),
                  minute: int.parse(jamPagiController.text.split(':')[1]),
                );
                TimeOfDay? jamSore = TimeOfDay(
                  hour: int.parse(jamSoreController.text.split(':')[0]),
                  minute: int.parse(jamSoreController.text.split(':')[1]),
                );

                FeedingSchedule updatedSchedule = FeedingSchedule(
                  uidJadwal: schedule.uidJadwal,
                  startDate: startDate,
                  endDate: endDate,
                  jamPagi: jamPagi,
                  jamSore: jamSore,
                  jumlahPakan: jumlahPakanValue.toDouble(),
                );

                // Panggil fungsi untuk menyimpan data jadwal yang telah diperbarui
                _updateSchedule(updatedSchedule);

                // Tutup dialog setelah data jadwal diperbarui
                Navigator.pop(context);
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _updateSchedule(FeedingSchedule updatedSchedule) {
    DateFormat formatter = DateFormat('dd-MM-yyyy');

    FirebaseFirestore.instance
        .collection('data_jadwal')
        .doc(updatedSchedule.uidJadwal)
        .update({
      'startDate': formatter.format(updatedSchedule.startDate),
      'endDate': formatter.format(updatedSchedule.endDate),
      'jamPagi': updatedSchedule.jamPagi != null
          ? '${updatedSchedule.jamPagi!.hour.toString().padLeft(2, '0')}:${updatedSchedule.jamPagi!.minute.toString().padLeft(2, '0')}'
          : null,
      'jamSore': updatedSchedule.jamSore != null
          ? '${updatedSchedule.jamSore!.hour.toString().padLeft(2, '0')}:${updatedSchedule.jamSore!.minute.toString().padLeft(2, '0')}'
          : null,
      'jumlah_pakan': updatedSchedule.jumlahPakan,
    }).then((_) {
      print("Update schedule success!");
    }).catchError((error) {
      print("Failed to update schedule: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  color: Colors.blue,
                  height: 110,
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
                                    'Solusi untuk ikan di kolam',
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
                    color: Colors.blue[100],
                    padding: EdgeInsets.all(1),
                    child: Column(
                      children: [
                        SizedBox(
                            height:
                                135), // Padding tambahan untuk menurunkan posisi
                        Center(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.settings_applications),
                                        SizedBox(width: 5),
                                        Text(
                                          'Feeder',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: feeders.map((feeder) {
                                      String? kodeAlat = feeder['kode_alat'];
                                      if (kodeAlat == null ||
                                          !alatNames.containsKey(kodeAlat)) {
                                        return SizedBox.shrink();
                                      }
                                      String namaAlat = alatNames[kodeAlat]!;
                                      double progress = 0.5;
                                      double isiPakan = 1;

                                      return Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 5),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 110,
                                                  height: 130,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: Colors.blue,
                                                      width: 4,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Stack(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    children: [
                                                      Container(
                                                        height: _levelPakan *
                                                            130, // Menggunakan levelPakan untuk tinggi indikator
                                                        decoration:
                                                            BoxDecoration(
                                                          color: _levelPakan >=
                                                                  0.8
                                                              ? Colors.green
                                                              : _levelPakan >=
                                                                      0.5
                                                                  ? Colors
                                                                      .yellow
                                                                  : _levelPakan >=
                                                                          0.2
                                                                      ? Colors
                                                                          .orange
                                                                      : Colors
                                                                          .red,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                      ),
                                                      Center(
                                                        child: Text(
                                                          '${(_levelPakan * 100).toStringAsFixed(0)} cm',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        bottom: 0,
                                                        child: Text(
                                                          _levelPakan >= 0.85
                                                              ? 'Full'
                                                              : _levelPakan >=
                                                                      0.55
                                                                  ? 'Normal'
                                                                  : _levelPakan >=
                                                                          0.25
                                                                      ? 'Warning'
                                                                      : 'Danger',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                VerticalDivider(
                                                  color: Colors.blue,
                                                  thickness: 2,
                                                  width: 22,
                                                  indent: 10,
                                                  endIndent: 10,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 15,
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  namaAlat,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                                Icon(Icons.wifi,
                                                                    color: Colors
                                                                        .blue),
                                                              ],
                                                            ),
                                                            Divider(
                                                              color:
                                                                  Colors.grey,
                                                              thickness: 1,
                                                              height: 20,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                IconButton(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .settings_applications,
                                                                      color: Colors
                                                                          .orange),
                                                                  onPressed:
                                                                      () {
                                                                    print(
                                                                        'Opening settings for device with code $kodeAlat');
                                                                  },
                                                                ),
                                                                IconButton(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .repeat_on_outlined,
                                                                      color: Colors
                                                                          .red),
                                                                  onPressed:
                                                                      () {
                                                                    print(
                                                                        'Stopping device with code $kodeAlat');
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 10),
                        //Divider(
                        //    // Custom divider
                        //    color: Colors.grey, // Set divider color to black
                        //    thickness: 5.0), // Set divider thickness to 2.0

                        Container(
                          padding: EdgeInsets.all(3),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white, // Background color grey
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset:
                                    Offset(0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons
                                        .calendar_month), // Icon for the device
                                    SizedBox(
                                        width:
                                            5), // Spacer between icon and text
                                    Text(
                                      ' Jadwal Pakan',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showAddScheduleModal(context);
                                },
                                icon: Icon(Icons.add_box_rounded),
                                label: Text('Buat Jadwal'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors
                                      .blue, // Text and icon color of button
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        6.0), // Rounded corners for button
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 2.0), // Padding for button
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('data_jadwal')
                                .where('kode_alat',
                                    isEqualTo: widget.data['kode_alat'])
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text(
                                    'Tidak ada jadwal',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot document =
                                      snapshot.data!.docs[index];
                                  FeedingSchedule schedule =
                                      FeedingSchedule.fromFirestore(document);
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 20.0),
                                    padding: EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.black87.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 3,
                                          offset: Offset(3, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Jadwal ${index + 1}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    // Add your edit action here
                                                    _showEditScheduleModal(
                                                        context, schedule);
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5), // Atur sudut border di sini
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit,
                                                            color:
                                                                Colors.white),
                                                        SizedBox(width: 5),
                                                        Text('Edit',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                        SizedBox(width: 5),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                InkWell(
                                                  onTap: () {
                                                    // Add your delete action here
                                                    _deleteSchedule(
                                                        schedule.uidJadwal);
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5), // Atur sudut border di sini
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete,
                                                            color:
                                                                Colors.white),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        //Text(
                                        //  'UID Jadwal: ${schedule.uidJadwal}',
                                        //  style: TextStyle(fontSize: 14.0),
                                        //),
                                        //SizedBox(height: 5),
                                        Text(
                                          '${DateFormat('dd MMM yyyy').format(schedule.startDate)} - ${DateFormat('dd MMM yyyy').format(schedule.endDate)}',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time,
                                                size: 20.0,
                                                color: Colors.green),
                                            SizedBox(width: 5.0),
                                            Stack(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 4.0,
                                                      horizontal: 8.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  child: Text(
                                                    'Jam Pagi: ${schedule.jamPagi != null ? schedule.jamPagi!.format(context) : '-'} - ${schedule.jumlahPakan.toStringAsFixed(0)} (g)',
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: Colors.black54),
                                                  ),
                                                ),
                                                Positioned.fill(
                                                  child: Center(
                                                    child:
                                                        LinearProgressIndicator(
                                                      minHeight: 40,
                                                      backgroundColor: Colors
                                                          .green
                                                          .withOpacity(0.1),
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.green),
                                                      value: progress /
                                                          100, // Gunakan variabel progress
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 5.0),
                                            Text(
                                              '${(progress).toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5.0),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time,
                                                size: 20.0, color: Colors.blue),
                                            SizedBox(width: 5.0),
                                            Stack(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 4.0,
                                                      horizontal: 8.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  child: Text(
                                                    'Jam Sore: ${schedule.jamSore != null ? schedule.jamSore!.format(context) : '-'} - ${schedule.jumlahPakan.toStringAsFixed(0)} (g)',
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: Colors.black54),
                                                  ),
                                                ),
                                                Positioned.fill(
                                                  child: Center(
                                                    child:
                                                        LinearProgressIndicator(
                                                      minHeight: 40,
                                                      backgroundColor: Colors
                                                          .green
                                                          .withOpacity(0.1),
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.blue),
                                                      value: progress /
                                                          100, // Gunakan variabel progress
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 5.0),
                                            Text(
                                              '${(progress).toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
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
              top: 70,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 300,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons
                                    .water_damage_rounded), // Icon for the device
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
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
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Alat Pakan',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                widget.data['nama_alat'],
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 35,
              left: 15,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Dashboard()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .start, // Mengatur main axis alignment ke start
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
      ),
    );
  }
}

class FirestoreService {
  final CollectionReference schedulesCollection =
      FirebaseFirestore.instance.collection('data_jadwal');
  final CollectionReference alatCollection =
      FirebaseFirestore.instance.collection('data_alat');
  final CollectionReference kolamCollection =
      FirebaseFirestore.instance.collection('datakolam');

  Future<void> addScheduleWithDetails(FeedingSchedule schedule, String kodeAlat,
      String namaAlat, String namaKolam) async {
    // Menambahkan jadwal ke Firestore dengan mengambil document reference
    DocumentReference docRef =
        schedulesCollection.doc(); // Document ID di-generate secara otomatis
    await docRef.set({
      ...schedule.toMap(),
      'uid_jadwal': docRef.id, // Menggunakan document ID sebagai uid_jadwal
      'kode_alat': kodeAlat,
      'nama_alat': namaAlat,
      'nama_kolam': namaKolam,
      'user_uid': FirebaseAuth.instance.currentUser?.uid,
    });
  }

  Future<List<FeedingSchedule>> getSchedulesByKodeAlat(String kodeAlat) async {
    QuerySnapshot querySnapshot =
        await schedulesCollection.where('kode_alat', isEqualTo: kodeAlat).get();
    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      DateFormat formatter = DateFormat('yyyy-MM-dd');

      return FeedingSchedule(
        startDate: formatter.parse(data['startDate']),
        endDate: formatter.parse(data['endDate']),
        jamPagi: TimeOfDay(
          hour: int.parse(data['jamPagi'].split(':')[0]),
          minute: int.parse(data['jamPagi'].split(':')[1]),
        ),
        jamSore: TimeOfDay(
          hour: int.parse(data['jamSore'].split(':')[0]),
          minute: int.parse(data['jamSore'].split(':')[1]),
        ),
        jumlahPakan: data['jumlah_pakan'] ?? 0.0,
        uidJadwal: data['uid_jadwal'] ?? '',
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

//logic untuk menambahkan data ke realtime database
class RealtimeDatabaseService {
  final DatabaseReference schedulesRef =
      FirebaseDatabase.instance.reference().child('data_jadwal');

  Future<void> addScheduleToRealtimeDatabase(
      String namaAlat,
      String email,
      DateTime tanggalMulai,
      DateTime tanggalSelesai,
      String jampagi,
      String jamsore,
      String jumlahPakan) async {
    // Menyiapkan data jadwal baru
    Map<String, dynamic> newSchedule = {
      'email': email,
      'tanggal_mulai': DateFormat('yyyy-MM-dd').format(tanggalMulai),
      'tanggal_selesai': DateFormat('yyyy-MM-dd').format(tanggalSelesai),
      'jamPagi': jampagi,
      'jamSore': jamsore,
      'jumlah_pakan': jumlahPakan,
    };

    // Menambahkan data jadwal ke Realtime Database
    DatabaseReference newScheduleRef = schedulesRef.child(namaAlat);
    await newScheduleRef.set(newSchedule);
  }
}
