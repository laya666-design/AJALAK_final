import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

classe DefaultFirebaseOptions {
  statique FirebaseOptions obtenir currentPlatform {
    si (kIsWeb) {
      lancer Une erreur non prise en charge(
        Les options DefaultFirebaseOptions n'ont pas été configurées pour le Web.
      );
    }
    switch (defaultTargetPlatform) {
      cas TargetPlatform.android :
        retourner Android ;
      défaut:
        lancer Une erreur non prise en charge(
          Les options DefaultFirebaseOptions ne sont pas prises en charge par cette plateforme.
        );
    }
  }

  const statique FirebaseOptions android = FirebaseOptions(
    Clé API : 'AIzaSyBHpypQOAQnMmifFtJcX97Mnbrb8ORnd6U',
    appId: '1:994131871524:android:25fd653f1e6da976ea15b1',
    messagingSenderId: '994131871524',
    ID du projet : « fakerni-b96c2 »,
    storageBucket : 'fakerni-b96c2.firebasestorage.app',
  );
}
