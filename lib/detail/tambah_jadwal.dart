import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deefeed2/detail/detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedingSchedule {
  final String uidJadwal;
  DateTime startDate;
  DateTime endDate;
  TimeOfDay? jamPagi;
  TimeOfDay? jamSore;
  double jumlahPakan;

  FeedingSchedule({
    required this.uidJadwal,
    required this.startDate,
    required this.endDate,
    required this.jamPagi,
    required this.jamSore,
    required this.jumlahPakan,
  });

  factory FeedingSchedule.fromFirestore(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    DateFormat formatter = DateFormat('dd-MM-yyyy');

    return FeedingSchedule(
      uidJadwal: document.id,
      startDate: formatter.parse(data['startDate']),
      endDate: formatter.parse(data['endDate']),
      jamPagi: data['jamPagi'] != null
          ? TimeOfDay(
              hour: int.parse(data['jamPagi'].split(':')[0]),
              minute: int.parse(data['jamPagi'].split(':')[1]),
            )
          : null,
      jamSore: data['jamSore'] != null
          ? TimeOfDay(
              hour: int.parse(data['jamSore'].split(':')[0]),
              minute: int.parse(data['jamSore'].split(':')[1]),
            )
          : null,
      jumlahPakan: data['jumlah_pakan'].toDouble(),
     
    );
  }

  Map<String, dynamic> toMap() {
    DateFormat formatter = DateFormat('dd-MM-yyyy');

    return {
      'startDate': formatter.format(startDate),
      'endDate': formatter.format(endDate),
      'jamPagi': jamPagi != null
          ? '${jamPagi!.hour.toString().padLeft(2, '0')}:${jamPagi!.minute.toString().padLeft(2, '0')}'
          : null,
      'jamSore': jamSore != null
          ? '${jamSore!.hour.toString().padLeft(2, '0')}:${jamSore!.minute.toString().padLeft(2, '0')}'
          : null,
      'jumlah_pakan': jumlahPakan,

    };
  }
}

class Feeding {
  TimeOfDay startTime;

  Feeding({
    required this.startTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'startTime': '${startTime.hour}:${startTime.minute}',
    };
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
  bool _isAdvanced = false;
  double _jumlahPakan = 100;
  GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Initialize _scaffoldKey here
  TimeOfDay? _selectedTimePagi;
  TimeOfDay? _selectedTimeSore;

  void _addFeeding(TimeOfDay startTime) {
    setState(() {
      _feedings.add(Feeding(startTime: startTime));
    });
  }

  void _removeFeeding(int index) {
    setState(() {
      _feedings.removeAt(index);
    });
  }

  Future<void> _selectDateMode(BuildContext context) async {
    bool? selectedMode = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Mode Pemilihan Tanggal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Basic ( Sehari )'),
                onTap: () {
                  Navigator.pop(context, false);
                },
              ),
              ListTile(
                title: Text('Advanced ( Lebih dari sehari)'),
                onTap: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          ),
        );
      },
    );
    if (selectedMode != null) {
      setState(() {
        _isAdvanced = selectedMode;
      });
      _selectDate(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    if (_isAdvanced) {
      // Advanced: Select a date range
      DateTimeRange? picked = await showDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        setState(() {
          _startDate = picked.start;
          _endDate = picked.end;
        });
      }
    } else {
      // Basic: Select a single date
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _startDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        setState(() {
          _startDate = picked;
          _endDate = picked;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) {
      return; // Do nothing if the state is no longer mounted
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }



  void _validateAndSave() async {
    if (_isAdvanced && _endDate.isBefore(_startDate)) {
      _showErrorSnackbar('Tanggal akhir harus setelah tanggal mulai.');
      return;
    }

    if (_selectedTimePagi == null && _selectedTimeSore == null) {
      _showErrorSnackbar('Pilih setidaknya satu waktu pemberian makan.');
      return;
    }


    // Membuat objek FeedingSchedule dari input pengguna
    FeedingSchedule schedule = FeedingSchedule(
      uidJadwal: FirebaseFirestore.instance.collection('data_jadwal').doc().id,
      startDate: _startDate,
      endDate: _endDate,
      jamPagi: _selectedTimePagi,
      jamSore: _selectedTimeSore,
      jumlahPakan: _jumlahPakan,
  
    );

    // Memanggil metode addScheduleWithDetails dari FirestoreService
    await FirestoreService().addScheduleWithDetails(
      schedule,
      widget.selectedData['kode_alat'] ?? '',
      widget.selectedData['nama_alat'] ?? '',
      widget.selectedData['nama_kolam'] ?? '',
    );

    // Memanggil metode addScheduleToRealtimeDatabase dari RealtimeDatabaseService
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    int jumlahPakanInt = _jumlahPakan.toInt();
    if (userEmail != null) {
      await RealtimeDatabaseService().addScheduleToRealtimeDatabase(
        widget.selectedData['nama_alat'] ?? '',
        FirebaseAuth.instance.currentUser?.email ?? '',
        _startDate,
        _endDate,
        _selectedTimePagi != null
            ? '${_selectedTimePagi!.hour.toString().padLeft(2, '0')}:${_selectedTimePagi!.minute.toString().padLeft(2, '0')}'
            : '',
        _selectedTimeSore != null
            ? '${_selectedTimeSore!.hour.toString().padLeft(2, '0')}:${_selectedTimeSore!.minute.toString().padLeft(2, '0')}'
            : '',
        jumlahPakanInt.toString(), // Mengubah jumlah pakan ke string
      );
    }

    // Menampilkan snackbar untuk memberitahu bahwa jadwal telah disimpan
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Jadwal pemberian makan telah disimpan.'),
        duration: Duration(seconds: 2),
      ),
    );

    // Menutup modal setelah menampilkan snackbar
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15.0),
            color: Colors.white54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tambah Jadwal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.selectedData['nama_kolam'] ?? '',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.0),
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
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tanggal:'),
                              TextButton.icon(
                                icon: Icon(Icons.calendar_today),
                                label: Text(
                                  _isAdvanced
                                      ? '${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}'
                                      : DateFormat('dd/MM/yyyy')
                                          .format(_startDate),
                                ),
                                onPressed: () => _selectDateMode(context),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.0),
                        // Expanded(
                        //   child: Column(
                        //    crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //    Text('Pemberian Makan:'),
                        //   ElevatedButton(
                        //    onPressed: () async {
                        //     TimeOfDay? newTime = await showTimePicker(
                        //     context: context,
                        //    initialTime: TimeOfDay.now(),
                        // );
                        //if (newTime != null) {
                        // _addFeeding(newTime);
                        // }
                        //},
                        //child: Text('Tambah'),
                        // ),
                        //  ],
                        // ),
                        // ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Jam Pagi:'),
                        SizedBox(width: 15),
                        ElevatedButton(
                          onPressed: () async {
                            TimeOfDay? selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (selectedTime != null) {
                              setState(() {
                                _selectedTimePagi = selectedTime;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.access_time),
                              SizedBox(width: 4),
                              Text(
                                _selectedTimePagi != null
                                    ? '${_selectedTimePagi!.hour.toString().padLeft(2, '0')}:${_selectedTimePagi!.minute.toString().padLeft(2, '0')}'
                                    : 'Pilih Jam',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Text('Jam Sore:'),
                        SizedBox(width: 15),
                        ElevatedButton(
                          onPressed: () async {
                            TimeOfDay? selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (selectedTime != null) {
                              setState(() {
                                _selectedTimeSore = selectedTime;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.access_time),
                              SizedBox(width: 4),
                              Text(
                                _selectedTimeSore != null
                                    ? '${_selectedTimeSore!.hour.toString().padLeft(2, '0')}:${_selectedTimeSore!.minute.toString().padLeft(2, '0')}'
                                    : 'Pilih Jam',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jumlah Pakan',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
                                value: _jumlahPakan,
                                max: 1000,
                                divisions: 10,
                                label: _jumlahPakan.round().toString(),
                                onChanged: (double value) {
                                  setState(() {
                                    _jumlahPakan = value;
                                  });
                                },
                              ),
                              Text(' Total: ${_jumlahPakan.round()} (g)'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Mengatur sudut tombol
                              ),
                            ),
                            backgroundColor:
                                WidgetStateProperty.all<Color>(Colors.red),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        // Ini button untuk menyimpan data jadwal
                        ElevatedButton(
                          style: ButtonStyle(
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            backgroundColor:
                                WidgetStateProperty.all<Color>(Colors.blue),
                          ),
                          onPressed: () {
                            // ketika button simpan di tekan maka logic __validateAndSave(); bekerja
                            _validateAndSave();
                          },
                          child: Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
