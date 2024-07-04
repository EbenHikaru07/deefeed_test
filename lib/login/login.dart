import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deefeed2/pendaftaran/pendaftaran.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:deefeed2/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TestDart());
}

class TestDart extends StatelessWidget {
  const TestDart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TestAwal()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/mania_pakan.png',
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  'DeeFeed',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Solusi untuk ikan di kolam',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 80), // Menambahkan sedikit jarak di bawah teks
          ],
        ),
      ),
    );
  }
}

class TestAwal extends StatefulWidget {
  const TestAwal({super.key});

  @override
  _TestAwalState createState() => _TestAwalState();
}

class _TestAwalState extends State<TestAwal> with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  late AnimationController _animationController;
  late AnimationController _floatAnimationController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();

    _floatAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _floatAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatAnimationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Login failed'),
            content: Text('Email dan password tidak boleh kosong.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Menampilkan AlertDialog loading
    showDialog(
      context: context,
      barrierDismissible:
          false, // Membuat dialog tidak bisa ditutup dengan klik di luar dialog
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Logging in...'),
            ],
          ),
        );
      },
    );

    try {
      String email = _usernameController.text;
      // Cek apakah input adalah username
      if (!_usernameController.text.contains('@')) {
        // Cari email berdasarkan username di Firestore
        final QuerySnapshot result = await _firestore
            .collection('users')
            .where('username', isEqualTo: _usernameController.text)
            .limit(1)
            .get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.isNotEmpty) {
          email = documents.first.get('email');
        } else {
          throw FirebaseAuthException(
              code: 'user-not-found', message: 'Username tidak ditemukan');
        }
      }

      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );
      Navigator.pop(context); // Menutup AlertDialog loading
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Menutup AlertDialog loading
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Username atau email tidak ditemukan.';
          break;
        case 'wrong-password':
          errorMessage = 'Password salah.';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid.';
          break;
        case 'user-disabled':
          errorMessage = 'Akun pengguna dinonaktifkan.';
          break;
        default:
          errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Login failed'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Navigator.pop(context); // Menutup AlertDialog loading
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Login failed'),
            content: Text('Terjadi kesalahan. Silakan coba lagi.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height * 0.40,
              width: double.infinity,
              child: Stack(
                children: [
                  Center(
                    child: AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: Image.asset(
                            'assets/images/mania_pakan.png',
                            width: 250,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 4, 157, 234),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 5), // Menggeser bayangan ke bawah
                    ),
                  ],
                ),
                height: MediaQuery.of(context).size.height * 0.60,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'LOGIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Halo, DeeFeeders!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 35),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '    Email / Username',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Container(
                            child: TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                hintText: '@email atau username',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '    Password',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            child: TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                hintText: 'Kata sandi',
                                fillColor: Colors.white,
                                filled: true,
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              obscureText: !_isPasswordVisible,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      //Align(
                      //  alignment: Alignment.centerRight,
                      //  child: Text(
                      //    'Lupa Password?',
                      //    style: TextStyle(
                      //      color: Colors.white,
                      //      decoration: TextDecoration.underline,
                      //    ),
                      //  ),
                      //),
                      SizedBox(height: 40),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _login,
                          icon: Icon(Icons.login,
                              color: Colors.white), // Menambahkan ikon login
                          label: Text(
                            'Masuk',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor:
                                Color.fromARGB(255, 4, 157, 234), // Warna teks
                            side: BorderSide(
                                color: Colors.white30), // Garis tepi putih
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 26),
                      //  Expanded(
                      //    child: Align(
                      //      alignment: Alignment.bottomCenter,
                      //      child: Padding(
                      //        padding: const EdgeInsets.only(bottom: 16.0),
                      //        child: Text(
                      //          '© 2024 DeeFeed',
                      //          style: TextStyle(
                      //            color: Colors.white,
                      //            decoration: TextDecoration.none,
                      //          ),
                      //        ),
                      //      ),
                      //    ),
                      //  ),
                      Center(
                        child: Text(
                          'Created By DeeDeed ©',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '2024',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
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
      ),
    );
  }
}
