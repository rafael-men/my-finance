import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyAp4HrWWG7NvsPxqk6BS5Jj4OA4EmbLc1k',
    appId: '1:114535796016:web:16e1d871603ce738db8cf5',
    messagingSenderId: '114535796016',
    projectId: 'finance-7f1c9',
    authDomain: 'finance-7f1c9.firebaseapp.com',
    storageBucket: 'finance-7f1c9.firebasestorage.app',
    measurementId: 'G-1ZDZQHCZLS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-L3uHdV62pcpVZsmW86z73n-AHnHypXc',
    appId: '1:114535796016:android:ce98156bbb5a7f96db8cf5',
    messagingSenderId: '114535796016',
    projectId: 'finance-7f1c9',
    storageBucket: 'finance-7f1c9.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCaSufnvMfPRjmLZ3Ur-qnbnlZW1oXLMTU',
    appId: '1:114535796016:ios:e45381a3c7068dafdb8cf5',
    messagingSenderId: '114535796016',
    projectId: 'finance-7f1c9',
    storageBucket: 'finance-7f1c9.firebasestorage.app',
    iosBundleId: 'com.example.myFinance',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCaSufnvMfPRjmLZ3Ur-qnbnlZW1oXLMTU',
    appId: '1:114535796016:ios:e45381a3c7068dafdb8cf5',
    messagingSenderId: '114535796016',
    projectId: 'finance-7f1c9',
    storageBucket: 'finance-7f1c9.firebasestorage.app',
    iosBundleId: 'com.example.myFinance',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAp4HrWWG7NvsPxqk6BS5Jj4OA4EmbLc1k',
    appId: '1:114535796016:web:4fb25c5b24640397db8cf5',
    messagingSenderId: '114535796016',
    projectId: 'finance-7f1c9',
    authDomain: 'finance-7f1c9.firebaseapp.com',
    storageBucket: 'finance-7f1c9.firebasestorage.app',
    measurementId: 'G-NB0K61FXME',
  );
}
