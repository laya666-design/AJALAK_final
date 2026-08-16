import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'config/app_config.dart';
import 'screens/home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
  void initState() {
    super.initState();
    if (kDebugMode) {
      Future.delayed(const Duration(seconds: 2), _showDebugTokenDialog);
    }
  }

  Future<void> _showDebugTokenDialog() async {
    String tokenText;
    try {
      final String? token = await FirebaseAppCheck.instance.getToken(true);
      tokenText = token ?? 'Token null (aucune erreur mais vide)';
    } catch (e) {
      tokenText = 'ERREUR lors de la récupération du token :\n$e';
    }

    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('App Check Debug Token'),
        content: SelectableText(tokenText),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: tokenText));
              Navigator.of(context).pop();
            },
            child: const Text('Copier et fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.current();
    return MaterialApp(
      navigatorKey: navigatorKey,
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
