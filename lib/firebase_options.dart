
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
    apiKey: 'AIzaSyCkPkGyBSQWRPgbh8W5tpYaBEF4cGO6eng',
    appId: '1:694159240178:web:52e6db053438089a20996b',
    messagingSenderId: '694159240178',
    projectId: 'ecommerceapp-85dff',
    authDomain: 'ecommerceapp-85dff.firebaseapp.com',
    storageBucket: 'ecommerceapp-85dff.firebasestorage.app',
    measurementId: 'G-T3CKWLS7DW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD5RLcMBqGQ_YWNiWdHeFJS8Iu8Wnpz4PY',
    appId: '1:694159240178:android:f1112ecf1059fac320996b',
    messagingSenderId: '694159240178',
    projectId: 'ecommerceapp-85dff',
    storageBucket: 'ecommerceapp-85dff.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyANUfA38SUxEcSW-NkgHT5wrIi5J-Rwygw',
    appId: '1:694159240178:ios:234cef7dd22e433a20996b',
    messagingSenderId: '694159240178',
    projectId: 'ecommerceapp-85dff',
    storageBucket: 'ecommerceapp-85dff.firebasestorage.app',
    iosClientId: '694159240178-bslhi6e3mf8umn1tcqid72si31hu36sp.apps.googleusercontent.com',
    iosBundleId: 'com.example.ecommerceapp',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyANUfA38SUxEcSW-NkgHT5wrIi5J-Rwygw',
    appId: '1:694159240178:ios:234cef7dd22e433a20996b',
    messagingSenderId: '694159240178',
    projectId: 'ecommerceapp-85dff',
    storageBucket: 'ecommerceapp-85dff.firebasestorage.app',
    iosClientId: '694159240178-bslhi6e3mf8umn1tcqid72si31hu36sp.apps.googleusercontent.com',
    iosBundleId: 'com.example.ecommerceapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCkPkGyBSQWRPgbh8W5tpYaBEF4cGO6eng',
    appId: '1:694159240178:web:387112bb0bed2cbc20996b',
    messagingSenderId: '694159240178',
    projectId: 'ecommerceapp-85dff',
    authDomain: 'ecommerceapp-85dff.firebaseapp.com',
    storageBucket: 'ecommerceapp-85dff.firebasestorage.app',
    measurementId: 'G-CQT8KXW8M2',
  );
}
