import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class FormPengisianDataPage extends StatefulWidget {
  @override
  _FormPengisianDataPageState createState() => _FormPengisianDataPageState();
}

class _FormPengisianDataPageState extends State<FormPengisianDataPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  File? _image;
  String? _kodeAlat;
  String? _namaAlat;
  String? _ukuranAlat;
  String? _dayaTampung;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageAndAddData() async {
    if (_image != null) {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images')
          .child('alat')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(_image!);
      String imageUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('data_alat').add({
        'image': imageUrl,
        'kode_alat': _kodeAlat,
        'nama_alat': _namaAlat,
        'ukuran_alat': _ukuranAlat,
        'daya_tampung': _dayaTampung,
        'status_alat': "pending",
      });
      Navigator.pop(context);
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _uploadImageAndAddData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Data Alat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: _image == null
                      ? Icon(Icons.add_a_photo, size: 50)
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Kode Alat'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kode Alat tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _kodeAlat = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nama Alat'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Alat tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _namaAlat = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Ukuran Alat (cm)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ukuran Alat tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _ukuranAlat = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Daya Tampung (kg)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Daya Tampung tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _dayaTampung = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
