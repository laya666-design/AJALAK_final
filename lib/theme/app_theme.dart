// Thème centralisé de l'app — nouvelle identité visuelle.
//
// À placer dans lib/theme/app_theme.dart. Puis dans votre main.dart :
//
//   MaterialApp(
//     theme: AppTheme.light,
//     ...
//   )
//
// Tous les écrans qui utilisent des widgets Material standards (ElevatedButton,
// Card, TextField, AppBar...) hériteront automatiquement du nouveau look,
// sans avoir à toucher au code de chaque écran individuellement.

import 'package:flutter/material.dart';

class AppColors {
  // Couleur principale : indigo profond — remplace le rouge de marque.
  static const primary = Color(0xFF2B2D6E);
  static const primaryLight = Color(0xFF4B4E9E);
  static const primaryDark = Color(0xFF1A1B4B);

  // Accent : orange corail — CTA, badges, urgence (ex: "EN DIRECT",
  // "expire bientôt").
  static const accent = Color(0xFFFF6B4A);
  static const accentLight = Color(0xFFFF8F73);

  // Fond & surfaces
  static const background = Color(0xFFF7F7FA);
  static const surface = Color(0xFFFFFFFF);

  // États
  static const success = Color(0xFF2E9E5B);
  static const warning = Color(0xFFE8A33D);
  static const error = Color(0xFFE0483E);

  // Texte
  static const textPrimary = Color(0xFF1C1C28);
  static const textSecondary = Color(0xFF6B6B7B);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Inter', // ou la police de votre choix (voir note en bas)
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.primary.withValues(alpha: 0.08),
        labelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
      ),
      textTheme: base.textTheme.copyWith(
        headlineSmall: const TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        titleLarge: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyMedium: const TextStyle(color: AppColors.textPrimary),
        bodySmall: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

// Note police : "Inter" n'est pas incluse par défaut dans Flutter. Deux options :
// 1. Retirez la ligne "fontFamily: 'Inter'" pour garder la police système (plus
//    simple, résultat déjà propre avec ce thème).
// 2. Ajoutez le package google_fonts (pub.dev/packages/google_fonts) et utilisez
//    GoogleFonts.interTextTheme() à la place — rendu plus soigné mais une
//    dépendance de plus.
