import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class EventSizeScreen extends StatefulWidget {
  const EventSizeScreen({super.key});

  @override
  State<EventSizeScreen> createState() => _EventSizeScreenState();
}

class _EventSizeScreenState extends State<EventSizeScreen> {
  String _selected = 'large';

  static const _sizes = ['large', 'medium', 'small'];
  static const _labels = {
    'large': 'Büyük',
    'medium': 'Orta',
    'small': 'Küçük',
  };
  // Same aspect ratios as CountdownCard
  static const _ratios = {
    'large': 16 / 9,
    'medium': 16 / 7,
    'small': 16 / 5,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString('eventCardSize') ?? 'large';
    if (mounted) setState(() => _selected = val);
  }

  Future<void> _save(String size) async {
    HapticFeedback.selectionClick();
    setState(() => _selected = size);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('eventCardSize', size);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF5F5F0);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
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
                    'Etkinlik Boyutu',
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Preview card — uses AspectRatio like the real card
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: AspectRatio(
                        aspectRatio: _ratios[_selected]!,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final h = constraints.maxHeight;
                            final titleFontSz =
                                (h * 0.1058).clamp(12.65, 23.0);
                            final dateFontSz =
                                (h * 0.05).clamp(7.0, 11.0);
                            final bottomPad = h * 0.065;

                            return Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white
                                          .withValues(alpha: 0.1)
                                      : const Color(0x0F000000),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    'assets/images/seyahat.jpg',
                                    fit: BoxFit.cover,
                                    cacheWidth: 800,
                                    cacheHeight: 400,
                                  ),
                                  // Gradient
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    height: h * 0.65,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0x00000000),
                                            Color(0xB3000000),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Text
                                  Positioned(
                                    bottom: bottomPad,
                                    left: 14,
                                    right: 14,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Trip to New York',
                                          textAlign: TextAlign.center,
                                          maxLines: h < 140 ? 1 : 2,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: titleFontSz,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.5,
                                            color: Colors.white,
                                            height: 1.15,
                                          ),
                                        ),
                                        SizedBox(height: h * 0.01),
                                        Text(
                                          '15 Temmuz 2026 Çarşamba',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: dateFontSz,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                const Color(0xA6FFFFFF),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Size options
                    ...List.generate(_sizes.length, (i) {
                      final size = _sizes[i];
                      final isSelected = size == _selected;
                      final label = _labels[size]!;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: GestureDetector(
                          onTap: () => _save(size),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? cardBg
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              label,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? textColor
                                    : secondaryColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
