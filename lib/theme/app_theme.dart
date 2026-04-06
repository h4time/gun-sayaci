import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  // === Light Theme Colors ===
  static const Color bgLight = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF1A1A1A);
  static const Color secondaryText = Color(0xFF8E8E93);
  static const Color accent = Color(0xFFF5A623); // warm amber/gold
  static const Color cardBorder = Color(0x0F000000); // rgba(0,0,0,0.06)
  static const Color divider = Color(0xFFE5E5EA);
  static const Color toggleSelectedBg = Color(0xFFF2F2F7);
  static const Color buttonShadow = Color(0x14000000); // rgba(0,0,0,0.08)

  // === Dark Theme Colors ===
  static const Color bgDark = Color(0xFF0A0A0F);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color cardDark = Color(0xFF2C2C2E);
  static const Color darkDivider = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color darkInput = Color(0xFF2C2C2E);
  static const Color darkSwitchInactive = Color(0xFF3A3A3C);

  static Map<String, String> _categoryThemeCache = {};

  // Category image mapping
  static const Map<String, String> categoryImages = {
    'Doğum Günü': 'assets/images/birthday.jpg',
    'Tatil': 'assets/images/travel.jpg',
    'Düğün/Yıldönümü': 'assets/images/celebration.jpg',
    'Sınav/İş': 'assets/images/exam.jpg',
    'Seyahat': 'assets/images/seyahat.jpg',
    'Konser/Etkinlik': 'assets/images/concert.jpg',
    'Spor/Hedef': 'assets/images/spor.jpg',
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
    'Konser/Etkinlik': Icons.music_note_rounded,
    'Spor/Hedef': Icons.emoji_events_rounded,
  };

  static String getImageForCategory(String category) {
    // Önce kullanıcının seçtiği temayı kontrol et
    if (_categoryThemeCache.containsKey(category)) {
      return _categoryThemeCache[category]!;
    }
    // Custom kategoriler için 'other' temasını kontrol et
    if (!categoryImages.containsKey(category) && _categoryThemeCache.containsKey('other')) {
      return _categoryThemeCache['other']!;
    }
    // Varsayılan
    return categoryImages[category] ?? 'assets/images/other.jpg';
  }

  static bool isFilePath(String path) {
    return path.startsWith('/') || path.startsWith('file:');
  }

  static Future<void> loadCategoryThemes() async {
    final prefs = await SharedPreferences.getInstance();
    _categoryThemeCache.clear();
    for (final cat in categoryImages.keys) {
      final saved = prefs.getString('categoryTheme_$cat');
      if (saved != null) _categoryThemeCache[cat] = saved;
    }
    final otherSaved = prefs.getString('categoryTheme_other');
    if (otherSaved != null) _categoryThemeCache['other'] = otherSaved;
  }

  static Future<void> setCategoryTheme(String category, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    final key = categoryImages.containsKey(category) ? 'categoryTheme_$category' : 'categoryTheme_other';
    await prefs.setString(key, imagePath);
    _categoryThemeCache[categoryImages.containsKey(category) ? category : 'other'] = imagePath;
  }

  static Future<void> resetCategoryTheme(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final key = categoryImages.containsKey(category) ? 'categoryTheme_$category' : 'categoryTheme_other';
    await prefs.remove(key);
    _categoryThemeCache.remove(categoryImages.containsKey(category) ? category : 'other');
  }

  static String? getCurrentTheme(String category) {
    if (categoryImages.containsKey(category)) {
      return _categoryThemeCache[category];
    }
    return _categoryThemeCache['other'];
  }

  static String? getIconForCategory(String category) {
    return categoryIcons[category];
  }

  static IconData getFallbackIconForCategory(String category) {
    return categoryFallbackIcons[category] ?? Icons.event_rounded;
  }

  // === Card text styles ===
  static TextStyle cardTitleStyle() {
    return GoogleFonts.dmSerifDisplay(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      height: 1.15,
      shadows: [
        const Shadow(
          blurRadius: 8,
          color: Color(0x4D000000),
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  static TextStyle cardCountdownStyle() {
    return GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: const Color(0xCCFFFFFF), // white 80%
      letterSpacing: 2.0,
    );
  }

  // === Themes ===
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
        foregroundColor: primaryText,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: primaryText,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
        surface: surfaceDark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: bgDark,
      dividerColor: darkDivider,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: bgDark,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
