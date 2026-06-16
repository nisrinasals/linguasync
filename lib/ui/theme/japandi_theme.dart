import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  JAPANDI PALETTE
//  Minimalist fusion of Japanese wabi-sabi and Scandinavian hygge.
//  Warm neutrals, earthy muted greens, natural charcoal, cream.
// ─────────────────────────────────────────────────────────────────────────────
class JC {
  JC._();

  // Core backgrounds
  static const Color bg         = Color(0xFFF5F0E8); // warm cream
  static const Color bgCard     = Color(0xFFFBF8F3); // near-white card
  static const Color bgMuted    = Color(0xFFEDE8DE); // muted sand

  // Primary accent – muted sage green (Japanese moss)
  static const Color primary    = Color(0xFF7A8C6E); // sage
  static const Color primaryDk  = Color(0xFF5A6B52); // deep moss
  static const Color primaryLt  = Color(0xFFB8C9A8); // pale sage
  static const Color primarySfc = Color(0xFFEAF0E4); // very pale sage surface

  // Secondary accent – warm clay/terracotta
  static const Color clay       = Color(0xFFC4866A); // warm clay
  static const Color clayLt     = Color(0xFFF3E0D6); // pale clay

  // Neutrals & typography
  static const Color ink        = Color(0xFF2E2C28); // deep warm charcoal
  static const Color inkMd      = Color(0xFF5C5850); // medium warm grey
  static const Color inkLt      = Color(0xFF9E9A92); // light warm grey
  static const Color border     = Color(0xFFD6D0C5); // soft warm border
  static const Color divider    = Color(0xFFE4DFDA); // very soft divider

  // Status
  static const Color success    = Color(0xFF6B8E5A); // muted forest green
  static const Color successLt  = Color(0xFFEAF0E4); // pale green surface
  static const Color warning    = Color(0xFFC4866A); // clay = warning
  static const Color warningLt  = Color(0xFFF3E0D6); // pale clay surface
  static const Color error      = Color(0xFFB05A5A); // muted red
  static const Color errorLt    = Color(0xFFF3E4E4); // pale red surface

  // Gold for rankings
  static const Color gold       = Color(0xFFB8963A);
  static const Color silver     = Color(0xFF9A9A8E);
  static const Color bronze     = Color(0xFFA07850);
}

// ─────────────────────────────────────────────────────────────────────────────
//  TEXT STYLES  (Inter-inspired, clean letterforms)
// ─────────────────────────────────────────────────────────────────────────────
class JT {
  JT._();

  static const TextStyle displayLg = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w700,
    color: JC.ink, letterSpacing: -0.5, height: 1.2,
  );

  static const TextStyle displaySm = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700,
    color: JC.ink, letterSpacing: -0.3, height: 1.3,
  );

  static const TextStyle titleLg = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w600,
    color: JC.ink, letterSpacing: -0.2,
  );

  static const TextStyle titleMd = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: JC.ink, letterSpacing: 0,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: JC.ink, height: 1.6,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: JC.inkMd, height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: JC.inkLt, letterSpacing: 0.2,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600,
    color: JC.inkMd, letterSpacing: 1.0,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  THEME DATA
// ─────────────────────────────────────────────────────────────────────────────
ThemeData buildJapandiTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: JC.bg,
    primaryColor: JC.primary,
    colorScheme: ColorScheme.light(
      primary: JC.primary,
      onPrimary: Colors.white,
      secondary: JC.clay,
      onSecondary: Colors.white,
      surface: JC.bgCard,
      onSurface: JC.ink,
      outline: JC.border,
      error: JC.error,
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: JC.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: JC.ink),
      titleTextStyle: TextStyle(
        color: JC.ink,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),

    // Cards
    cardTheme: CardThemeData(
      color: JC.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: JC.border, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: JC.divider,
      thickness: 1,
      space: 1,
    ),

    // Bottom navigation bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: JC.bgCard,
      selectedItemColor: JC.primary,
      unselectedItemColor: JC.inkLt,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
    ),

    // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: JC.bgCard,
      labelStyle: const TextStyle(color: JC.inkMd, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: JC.primary, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: JC.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: JC.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: JC.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: JC.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: JC.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Elevated buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: JC.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3),
      ),
    ),

    // Outlined buttons
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: JC.primary,
        side: const BorderSide(color: JC.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    // Text buttons
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: JC.primary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // Icon theme
    iconTheme: const IconThemeData(color: JC.inkMd, size: 22),

    // ListTile
    listTileTheme: const ListTileThemeData(
      iconColor: JC.primary,
      tileColor: Colors.transparent,
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: JC.ink,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: JC.bgMuted,
      labelStyle: const TextStyle(color: JC.ink, fontSize: 12),
      side: const BorderSide(color: JC.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),

    // Progress indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: JC.primary,
      linearTrackColor: JC.bgMuted,
    ),
  );
}
