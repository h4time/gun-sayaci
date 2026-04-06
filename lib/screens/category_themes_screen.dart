import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'category_theme_detail_screen.dart';

const Map<String, String> _kCategoryEmojis = {
  'Doğum Günü': '🎂',
  'Tatil': '✈️',
  'Düğün/Yıldönümü': '💍',
  'Sınav/İş': '💼',
  'Seyahat': '🧳',
  'Konser/Etkinlik': '🎵',
  'Spor/Hedef': '🏆',
  'Diğer': '✏️',
};

const Map<String, Color> _kBgLight = {
  'Doğum Günü': Color(0xFFFCEBEB),
  'Tatil': Color(0xFFE6F1FB),
  'Düğün/Yıldönümü': Color(0xFFFBEAF0),
  'Sınav/İş': Color(0xFFFAEEDA),
  'Seyahat': Color(0xFFE1F5EE),
  'Konser/Etkinlik': Color(0xFFEEEDFE),
  'Spor/Hedef': Color(0xFFEAF3DE),
  'Diğer': Color(0xFFF1EFE8),
};

const Map<String, Color> _kBgDark = {
  'Doğum Günü': Color(0xFF501313),
  'Tatil': Color(0xFF042C53),
  'Düğün/Yıldönümü': Color(0xFF4B1528),
  'Sınav/İş': Color(0xFF412402),
  'Seyahat': Color(0xFF04342C),
  'Konser/Etkinlik': Color(0xFF26215C),
  'Spor/Hedef': Color(0xFF173404),
  'Diğer': Color(0xFF2C2C2A),
};

const Map<String, Color> _kTextLight = {
  'Doğum Günü': Color(0xFF791F1F),
  'Tatil': Color(0xFF0C447C),
  'Düğün/Yıldönümü': Color(0xFF72243E),
  'Sınav/İş': Color(0xFF633806),
  'Seyahat': Color(0xFF085041),
  'Konser/Etkinlik': Color(0xFF3C3489),
  'Spor/Hedef': Color(0xFF27500A),
  'Diğer': Color(0xFF444441),
};

const Map<String, Color> _kTextDark = {
  'Doğum Günü': Color(0xFFF7C1C1),
  'Tatil': Color(0xFFB5D4F4),
  'Düğün/Yıldönümü': Color(0xFFF4C0D1),
  'Sınav/İş': Color(0xFFFAC775),
  'Seyahat': Color(0xFF9FE1CB),
  'Konser/Etkinlik': Color(0xFFCECBF6),
  'Spor/Hedef': Color(0xFFC0DD97),
  'Diğer': Color(0xFFD3D1C7),
};

class CategoryThemesScreen extends StatelessWidget {
  const CategoryThemesScreen({super.key});

  static const _categories = [
    'Doğum Günü',
    'Tatil',
    'Düğün/Yıldönümü',
    'Sınav/İş',
    'Seyahat',
    'Konser/Etkinlik',
    'Spor/Hedef',
    'Diğer',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF5F5F0);
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final secondaryColor =
        isDark ? Colors.grey[400]! : AppTheme.secondaryText;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: textColor),
                  ),
                  const Spacer(),
                  Text(
                    'Kategori Temaları',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Text(
                      'Arka plan görselini değiştirmek istediğiniz kategoriyi seçin',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: _categories.map((cat) {
                      final catBg = isDark
                          ? _kBgDark[cat] ?? const Color(0xFF2C2C2A)
                          : _kBgLight[cat] ?? const Color(0xFFF1EFE8);
                      final catTextColor = isDark
                          ? _kTextDark[cat] ?? const Color(0xFFD3D1C7)
                          : _kTextLight[cat] ?? const Color(0xFF444441);
                      final emoji = _kCategoryEmojis[cat] ?? '✏️';

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CategoryThemeDetailScreen(category: cat),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: catBg,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 10),
                              Text(
                                cat,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: catTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Özel kategorilerinizin ortak arka plan görseli',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark ? Colors.grey[600] : Colors.grey[500],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
