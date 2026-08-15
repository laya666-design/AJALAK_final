import 'package:flutter/material.dart';

/// El Bouni Pièces Auto — rouge — package com.elbouni.annaba
/// (variante unique ; l'ancienne variante bleue "Annaba Edition" a été retirée)
class AppConfig {
  final String appName;
  final Color primaryColor;
  final Color primaryDark;

  const AppConfig._({
    required this.appName,
    required this.primaryColor,
    required this.primaryDark,
  });

  static const _instance = AppConfig._(
    appName: 'El Bouni Pièces Auto',
    primaryColor: Color(0xFFDC2626), // rouge
    primaryDark: Color(0xFFA31515),
  );

  static AppConfig current() => _instance;
}

/// Clé API Gemini.
///
/// ⚠️ SÉCURITÉ : ne jamais committer une vraie clé en dur si le repo est
/// (ou peut devenir) public. Deux options :
///   1) Build local / repo privé -> tu peux laisser la valeur en dur ci-dessous.
///   2) GitHub Actions -> passe-la en secret et compile avec :
///      flutter build apk --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
/// Le code lit TOUJOURS la variable d'environnement de compilation en priorité ;
/// si elle est vide, il retombe sur la constante ci-dessous.
class ApiKeys {
  static const String _fallbackGeminiKey =
      'AQ.Ab8RN6IGbMPrMy9ZToZdd_F2BWlqQoVfBlBcH80H8aP90BRLGg';

  static const String gemini = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: _fallbackGeminiKey,
  );
}
