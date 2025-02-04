// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBsvd-2TIcOfeLcoAnGG-W5PtdcMxILafU',
    appId: '1:866408196709:web:2f85493c2e16c46210f48c',
    messagingSenderId: '866408196709',
    projectId: 'deefeed-test-4af92',
    authDomain: 'deefeed-test-4af92.firebaseapp.com',
    storageBucket: 'deefeed-test-4af92.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCsOHAnm8uYtOfPgdwz-Fd6sKWXxq1glSw',
    appId: '1:866408196709:android:4d1be4aa168f992710f48c',
    messagingSenderId: '866408196709',
    projectId: 'deefeed-test-4af92',
    storageBucket: 'deefeed-test-4af92.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC3MXvQIqL_Dn8Ia561UBmyLN1s_she6Vo',
    appId: '1:866408196709:ios:d660e80ecb3d60be10f48c',
    messagingSenderId: '866408196709',
    projectId: 'deefeed-test-4af92',
    storageBucket: 'deefeed-test-4af92.appspot.com',
    iosBundleId: 'com.example.deefeed2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC3MXvQIqL_Dn8Ia561UBmyLN1s_she6Vo',
    appId: '1:866408196709:ios:d660e80ecb3d60be10f48c',
    messagingSenderId: '866408196709',
    projectId: 'deefeed-test-4af92',
    storageBucket: 'deefeed-test-4af92.appspot.com',
    iosBundleId: 'com.example.deefeed2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBsvd-2TIcOfeLcoAnGG-W5PtdcMxILafU',
    appId: '1:866408196709:web:23dfbb0b8842d85510f48c',
    messagingSenderId: '866408196709',
    projectId: 'deefeed-test-4af92',
    authDomain: 'deefeed-test-4af92.firebaseapp.com',
    storageBucket: 'deefeed-test-4af92.appspot.com',
  );
}
