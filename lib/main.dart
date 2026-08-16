import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'config/app_config.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // OBLIGATOIRE pour que Gemini (firebase_ai) fonctionne.
  // En debug : provider "debug" (nÃ©cessite d'enregistrer le debug token
  // affichÃ© dans les logs, dans Firebase Console > App Check > GÃ©rer les tokens de dÃ©bogage).
  // En release : Play Integrity (nÃ©cessite que le SHA-256 de la clÃ© de
  // signature release soit enregistrÃ© dans Firebase Console > Project Settings).
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
  );

  runApp(const AjalakApp());
}

class AjalakApp extends StatefulWidget {
  const AjalakApp({super.key});
  @override
  State<AjalakApp> createState() => _AjalakAppState();
}

class _AjalakAppState extends State<AjalakApp> {
  final ValueNotifier<bool> isAr = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.current();
    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr'), Locale('ar')],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: config.primaryColor,
          primary: config.primaryColor,
        ),
      ),
      home: HomeScreen(config: config, isAr: isAr),
    );
  }
}
