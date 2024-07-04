import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: MyApp2(),
  ));
}

class MyApp2 extends StatefulWidget {
  @override
  _MyApp2State createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> {
  DateTime selectedDateTime = DateTime.now();
  double feedingAmount = 100.0;
  double progress = 0.0;
  late Timer _timer;

  void _updateProgress() {
    setState(() {
      final now = DateTime.now();
      if (now.isAfter(selectedDateTime) && progress < 100) {
        double timeToComplete = (feedingAmount / 100) * 5;
        double progressPerSecond = 100 / timeToComplete;
        progress += progressPerSecond;
        if (progress >= 100) {
          progress = 100;
          _timer.cancel();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateProgress();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Pemilihan Tanggal dan Jam'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Pilih Tanggal dan Jam:',
              style: TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDateTime,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedDateTime = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      progress = 0.0;
                      _timer.cancel();
                      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
                        _updateProgress();
                      });
                    });
                  }
                }
              },
              child: Text('Pilih Tanggal dan Jam'),
            ),
            SizedBox(height: 20),
            Text(
              'Pilih Jumlah Pakan Ikan:',
              style: TextStyle(fontSize: 18),
            ),
            Slider(
              value: feedingAmount,
              min: 100,
              max: 2000,
              divisions: 19,
              label: feedingAmount.round().toString(),
              onChanged: (double value) {
                setState(() {
                  feedingAmount = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  progress = 0.0;
                });
              },
              child: Text('Mulai Pemberian Pakan'),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                Text(
                  'Tanggal dan Jam: ${DateFormat('dd/MM/yyyy HH:mm').format(selectedDateTime)}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Jumlah Pakan: ${feedingAmount.toInt()}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  'Progress: ${(progress).toStringAsFixed(2)}%',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
