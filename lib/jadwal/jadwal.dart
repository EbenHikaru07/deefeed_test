import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp2());
}

class MyApp2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<FeedingSchedule> schedules = [];

  void _showAddScheduleModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddScheduleModal(onSave: (schedule) {
          setState(() {
            schedules.add(schedule);
          });
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sistem Pemberi Pakan Ikan Otomatis'),
      ),
      body: schedules.isEmpty
          ? Center(child: Text('Belum ada jadwal'))
          : ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Text(
                      'Tanggal: ${DateFormat('d MMMM yyyy').format(schedule.startDate)} - ${DateFormat('d MMMM yyyy').format(schedule.endDate)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: schedule.feedings.map((feeding) {
                      return ListTile(
                        title: Text(
                          'Waktu Pemberian Pakan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${feeding.startTime.format(context)} - ${feeding.endTime.format(context)}',
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddScheduleModal(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddScheduleModal extends StatefulWidget {
  final Function(FeedingSchedule) onSave;

  AddScheduleModal({required this.onSave});

  @override
  _AddScheduleModalState createState() => _AddScheduleModalState();
}

class _AddScheduleModalState extends State<AddScheduleModal> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 1));
  int _feedTimesPerDay = 1;
  List<FeedingTime> _feedTimes = [
    FeedingTime(
        startTime: TimeOfDay(hour: 8, minute: 0),
        endTime: TimeOfDay(hour: 10, minute: 0))
  ];

  _pickDateRange() async {
    DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (dateRange != null) {
      setState(() {
        _startDate = dateRange.start;
        _endDate = dateRange.end;
      });
    }
  }

  _pickTime(int index, bool isStartTime) async {
    TimeOfDay initialTime =
        isStartTime ? _feedTimes[index].startTime : _feedTimes[index].endTime;
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (time != null) {
      setState(() {
        if (isStartTime) {
          _feedTimes[index] =
              FeedingTime(startTime: time, endTime: _feedTimes[index].endTime);
        } else {
          _feedTimes[index] = FeedingTime(
              startTime: _feedTimes[index].startTime, endTime: time);
        }
      });
    }
  }

  int _timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  bool _isEndTimeBeforeStartTime(FeedingTime feeding) {
    int startTimeInMinutes = _timeOfDayToMinutes(feeding.startTime);
    int endTimeInMinutes = _timeOfDayToMinutes(feeding.endTime);
    return endTimeInMinutes <= startTimeInMinutes;
  }

  _saveSchedule() {
    if (_feedTimes.any((feeding) => _isEndTimeBeforeStartTime(feeding))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Waktu mulai harus sebelum waktu selesai')),
      );
      return;
    }

    final newSchedule = FeedingSchedule(
      startDate: _startDate,
      endDate: _endDate,
      feedings: _feedTimes,
    );
    widget.onSave(newSchedule);
    Navigator.pop(context);
  }

  _updateFeedTimes(int times) {
    setState(() {
      _feedTimesPerDay = times;
      _feedTimes = List<FeedingTime>.generate(
        times,
        (index) => index < _feedTimes.length
            ? _feedTimes[index]
            : FeedingTime(
                startTime: TimeOfDay(hour: 8 + index * 2, minute: 0),
                endTime: TimeOfDay(hour: 10 + index * 2, minute: 0),
              ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Tambah Jadwal Pemberian Pakan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ListTile(
            title: Text(
                'Tanggal: ${DateFormat('d MMMM yyyy').format(_startDate)} - ${DateFormat('d MMMM yyyy').format(_endDate)}'),
            trailing: Icon(Icons.calendar_today),
            onTap: _pickDateRange,
          ),
          DropdownButton<int>(
            value: _feedTimesPerDay,
            items: [1, 2, 3, 4, 5].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value kali sehari'),
              );
            }).toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                _updateFeedTimes(newValue);
              }
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _feedTimesPerDay,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Pemberian Pakan ${index + 1}'),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(
                              'Mulai: ${_feedTimes[index].startTime.format(context)}'),
                          trailing: Icon(Icons.access_time),
                          onTap: () => _pickTime(index, true),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ListTile(
                          title: Text(
                              'Selesai: ${_feedTimes[index].endTime.format(context)}'),
                          trailing: Icon(Icons.access_time),
                          onTap: () => _pickTime(index, false),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveSchedule,
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class FeedingSchedule {
  final DateTime startDate;
  final DateTime endDate;
  final List<FeedingTime> feedings;

  FeedingSchedule({
    required this.startDate,
    required this.endDate,
    required this.feedings,
  });
}

class FeedingTime {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  FeedingTime({
    required this.startTime,
    required this.endTime,
  });
}
