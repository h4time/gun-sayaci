import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light theme colors
  static const Color bgLight = Color(0xFFFAFAFA);

  // Dark theme colors
  static const Color bgDark = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF16213E);
  static const Color cardDark = Color(0xFF0F3460);

  // Accent
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentLight = Color(0xFF8B83FF);
  static const Color accentEnd = Color(0xFF4ECDC4);

  // Category image mapping
  static const Map<String, String> categoryImages = {
    'Doğum Günü': 'assets/images/birthday.jpg',
    'Tatil': 'assets/images/travel.jpg',
    'Düğün/Yıldönümü': 'assets/images/celebration.jpg',
    'Sınav/İş': 'assets/images/celebration.jpg',
    'Seyahat': 'assets/images/travel.jpg',
    'Diğer': 'assets/images/other.jpg',
  };

  // Category icon mapping
  static const Map<String, String> categoryIcons = {
    'Doğum Günü': 'assets/icons/cake.png',
    'Tatil': 'assets/icons/beach.png',
    'Düğün/Yıldönümü': 'assets/icons/just-married.png',
    'Sınav/İş': 'assets/icons/task.png',
    'Seyahat': 'assets/icons/travel-bag.png',
  };

  // Category fallback icons (Material Icons)
  static const Map<String, IconData> categoryFallbackIcons = {
    'Doğum Günü': Icons.cake_rounded,
    'Tatil': Icons.beach_access_rounded,
    'Düğün/Yıldönümü': Icons.favorite_rounded,
    'Sınav/İş': Icons.work_rounded,
    'Seyahat': Icons.flight_rounded,
    'Diğer': Icons.more_horiz_rounded,
  };

  static String getImageForCategory(String category) {
    return categoryImages[category] ?? 'assets/images/celebration.jpg';
  }

  static String? getIconForCategory(String category) {
    return categoryIcons[category];
  }

  static IconData getFallbackIconForCategory(String category) {
    return categoryFallbackIcons[category] ?? Icons.event_rounded;
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      scaffoldBackgroundColor: bgLight,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: bgLight,
        foregroundColor: Colors.grey[900],
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.grey[900],
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: Colors.grey[500],
        indicatorColor: accent,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentLight,
        brightness: Brightness.dark,
        surface: surfaceDark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: bgDark,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: bgDark,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accentLight,
        unselectedLabelColor: Colors.grey[500],
        indicatorColor: accentLight,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
