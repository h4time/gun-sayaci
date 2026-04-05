import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_icon_service.dart';
import '../theme/app_theme.dart';

class _IconOption {
  final String preview; // asset path
  final String? alternateIconName; // null = primary
  final String label;
  const _IconOption(this.preview, this.alternateIconName, this.label);
}

const _icons = [
  _IconOption('assets/icons/icon_white.png', null, 'Beyaz'),
  _IconOption('assets/icons/icon_dark.png', 'IconDark', 'Koyu'),
  _IconOption('assets/icons/icon_pink_purple.png', 'IconPinkPurple', 'Pembe Mor'),
  _IconOption('assets/icons/icon_pink.png', 'IconPink', 'Pembe'),
  _IconOption('assets/icons/icon_amber.png', 'IconAmber', 'Amber'),
  _IconOption('assets/icons/icon_mint.png', 'IconMint', 'Mint'),
  _IconOption('assets/icons/icon_blue.png', 'IconBlue', 'Mavi'),
  _IconOption('assets/icons/icon_orange_bold.png', 'IconOrange', 'Turuncu'),
  _IconOption('assets/icons/icon_lavender.png', 'IconLavender', 'Lavanta'),
  _IconOption('assets/icons/icon_party.png', 'IconParty', 'Parti'),
  _IconOption('assets/icons/icon_teal_calendar.png', 'IconTeal', 'Takvim'),
];

class AppIconScreen extends StatefulWidget {
  const AppIconScreen({super.key});

  @override
  State<AppIconScreen> createState() => _AppIconScreenState();
}

class _AppIconScreenState extends State<AppIconScreen> {
  String _selectedKey = 'primary'; // "primary" or alternate icon name

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString('selectedAppIcon') ?? 'primary';
    if (mounted) setState(() => _selectedKey = val);
  }

  Future<void> _changeIcon(_IconOption option) async {
    final key = option.alternateIconName ?? 'primary';
    if (key == _selectedKey) return;

    HapticFeedback.selectionClick();

    if (!Platform.isIOS) {
      setState(() => _selectedKey = key);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedAppIcon', key);
      return;
    }

    try {
      final success =
          await AppIconService.setAlternateIcon(option.alternateIconName);
      if (!success) throw Exception('Not supported');
      setState(() => _selectedKey = key);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedAppIcon', key);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'İkon değiştirilemedi',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xE61C1C1E),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        ),
      );
    }
  }

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
                    'Uygulama İkonu',
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

            const SizedBox(height: 16),

            // Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
                childAspectRatio: 0.75,
                physics: const BouncingScrollPhysics(),
                children: _icons.map((option) {
                  final key = option.alternateIconName ?? 'primary';
                  final isSelected = key == _selectedKey;

                  return GestureDetector(
                    onTap: () => _changeIcon(option),
                    child: AnimatedScale(
                      scale: isSelected ? 0.97 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon preview
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.accent
                                        : (isDark
                                            ? Colors.white
                                                .withValues(
                                                    alpha: 0.12)
                                            : Colors.grey.shade300),
                                    width: isSelected ? 2.5 : 0.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppTheme.accent
                                                .withValues(
                                                    alpha: 0.25),
                                            blurRadius: 12,
                                            offset:
                                                const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(18),
                                      child: Image.asset(
                                        option.preview,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: AppTheme.accent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Label
                          Text(
                            option.label,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? textColor
                                  : secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
