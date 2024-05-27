import 'package:flutter/material.dart';


class PenambahanDataPage extends StatelessWidget {
  const PenambahanDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            // Bagian atas dengan warna biru
            Container(
              color: Colors.blue,
              height: MediaQuery.of(context).size.height * 0.5, // Setengah dari tinggi layar
              width: double.infinity,
              child: Center(
                child: Text(
                  'Bagian Atas',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            // Bagian bawah dengan warna hijau
            Container(
              color: Colors.green,
              height: MediaQuery.of(context).size.height * 0.5, // Setengah dari tinggi layar
              width: double.infinity,
              child: Center(
                child: Text(
                  'Bagian Bawah',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
