// ARCHIVO PLACEHOLDER.
//
// Este archivo lo genera Firebase con el comando:
//     dart pub global activate flutterfire_cli
//     flutterfire configure
// Al ejecutarlo se REEMPLAZA este archivo con las claves reales de TU proyecto
// de Firebase. Mientras no se reemplace, la app compila pero no podrá conectarse.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAJDDcgz1xp4xbOLs41Regu9X-oiy53mhU',
    appId: '1:510540702041:android:c0bf1855a1174baf402c48',
    messagingSenderId: '510540702041',
    projectId: 'keepinventory-e686b',
    storageBucket: 'keepinventory-e686b.firebasestorage.app',
  );
}
