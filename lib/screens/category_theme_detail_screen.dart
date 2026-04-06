import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_theme.dart';

const Map<String, String> _categoryFolders = {
  'Doğum Günü': 'birthday',
  'Tatil': 'holiday',
  'Düğün/Yıldönümü': 'wedding',
  'Sınav/İş': 'exam',
  'Seyahat': 'travel',
  'Konser/Etkinlik': 'concert',
  'Spor/Hedef': 'sport',
  'Diğer': 'other',
};

const Map<String, String> _categoryEmojis = {
  'Doğum Günü': '🎂',
  'Tatil': '✈️',
  'Düğün/Yıldönümü': '💍',
  'Sınav/İş': '💼',
  'Seyahat': '🧳',
  'Konser/Etkinlik': '🎵',
  'Spor/Hedef': '🏆',
  'Diğer': '✏️',
};

const Map<String, Color> _categoryColors = {
  'Doğum Günü': Color(0xFFFF4B77),
  'Tatil': Color(0xFF2EC4B6),
  'Düğün/Yıldönümü': Color(0xFFFF6B9D),
  'Sınav/İş': Color(0xFFF5A623),
  'Seyahat': Color(0xFF8B5CF6),
  'Konser/Etkinlik': Color(0xFF6C5CE7),
  'Spor/Hedef': Color(0xFF4CAF50),
  'Diğer': Color(0xFF8E8E93),
};

class CategoryThemeDetailScreen extends StatefulWidget {
  final String category;

  const CategoryThemeDetailScreen({super.key, required this.category});

  @override
  State<CategoryThemeDetailScreen> createState() =>
      _CategoryThemeDetailScreenState();
}

class _CategoryThemeDetailScreenState extends State<CategoryThemeDetailScreen> {
  String? _selectedTheme;
  List<String> _availableThemes = [];

  @override
  void initState() {
    super.initState();
    _selectedTheme = AppTheme.getCurrentTheme(widget.category);
    _loadAvailableThemes();
  }

  Future<void> _loadAvailableThemes() async {
    final folder = _categoryFolders[widget.category] ?? 'other';
    final themes = <String>[];
    for (int i = 1; i <= 10; i++) {
      final path = 'assets/category_themes/$folder/${folder}_$i.jpg';
      try {
        await rootBundle.load(path);
        themes.add(path);
      } catch (_) {
        // Dosya yok, atla
      }
    }
    if (mounted) setState(() => _availableThemes = themes);
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
    if (picked == null) return;

    // App documents dir'e kopyala (kalıcı depolama)
    final appDir = await getApplicationDocumentsDirectory();
    final folder = _categoryFolders[widget.category] ?? 'other';
    final fileName =
        'theme_${folder}_custom_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = await File(picked.path).copy('${appDir.path}/$fileName');

    await AppTheme.setCategoryTheme(widget.category, savedFile.path);
    if (mounted) {
      setState(() => _selectedTheme = savedFile.path);
      HapticFeedback.mediumImpact();
    }
  }

  String get _defaultImage =>
      AppTheme.categoryImages[widget.category] ?? 'assets/images/celebration.jpg';

  String get _previewImage => _selectedTheme ?? _defaultImage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF5F5F0);
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final secondaryColor =
        isDark ? Colors.grey[400]! : AppTheme.secondaryText;
    final emoji = _categoryEmojis[widget.category] ?? '✏️';
    final catColor = _categoryColors[widget.category] ?? const Color(0xFF8E8E93);

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
                    '$emoji ${widget.category}',
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
                  // Preview card
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Preview image
                            AppTheme.isFilePath(_previewImage)
                                ? Image.file(
                                    File(_previewImage),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) {
                                      return Image.asset(
                                        _defaultImage,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    _previewImage,
                                    fit: BoxFit.cover,
                                    cacheWidth: 800,
                                    cacheHeight: 400,
                                  ),

                            // Gradient overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 180 * 0.65,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0x00000000),
                                      Color(0x8C000000),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Category badge (top left)
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(emoji,
                                        style: const TextStyle(fontSize: 9)),
                                    const SizedBox(width: 3),
                                    Text(
                                      widget.category,
                                      style: GoogleFonts.poppins(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Countdown circle (top right)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                  color: Color(0x55000000),
                                  shape: BoxShape.circle,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '148',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                    ),
                                    Text(
                                      'GÜN',
                                      style: GoogleFonts.poppins(
                                        fontSize: 6,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xB3FFFFFF),
                                        height: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Title + date (bottom center)
                            Positioned(
                              bottom: 14,
                              left: 14,
                              right: 14,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Örnek Etkinlik',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                      color: Colors.white,
                                      height: 1.15,
                                      shadows: const [
                                        Shadow(
                                          blurRadius: 8,
                                          color: Color(0x80000000),
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '1 Eylül 2026 Salı',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xA6FFFFFF),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section title
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'TEMA SEÇİN',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: secondaryColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Theme grid
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Default theme thumbnail
                      _buildThemeThumbnail(
                        imagePath: _defaultImage,
                        isSelected: _selectedTheme == null,
                        isAsset: true,
                        onTap: () async {
                          HapticFeedback.selectionClick();
                          await AppTheme.resetCategoryTheme(widget.category);
                          setState(() => _selectedTheme = null);
                        },
                      ),

                      // Available theme thumbnails
                      ..._availableThemes.map((path) => _buildThemeThumbnail(
                            imagePath: path,
                            isSelected: _selectedTheme == path,
                            isAsset: true,
                            onTap: () async {
                              HapticFeedback.selectionClick();
                              await AppTheme.setCategoryTheme(
                                  widget.category, path);
                              setState(() => _selectedTheme = path);
                            },
                          )),

                      // Gallery button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _pickFromGallery();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : const Color(0xFFC7C7CC),
                              width: 1.5,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 28,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[400],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Galeri',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildThemeThumbnail({
    required String imagePath,
    required bool isSelected,
    required bool isAsset,
    required VoidCallback onTap,
  }) {
    final isFile = AppTheme.isFilePath(imagePath);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: const Color(0xFFF5A623), width: 2.5)
              : null,
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(isSelected ? 11.5 : 14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              isFile
                  ? Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) {
                        return Container(color: const Color(0xFF2C2C2E));
                      },
                    )
                  : Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      cacheWidth: 200,
                    ),
              if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5A623),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
