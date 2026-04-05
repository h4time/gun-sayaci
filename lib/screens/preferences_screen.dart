import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF5F5F0);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final secondaryColor =
        isDark ? Colors.grey[400]! : AppTheme.secondaryText;
    final themeProvider = Provider.of<ThemeProvider>(context);

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
                    'Tercihler',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  // Section: Appearance
                  _sectionTitle('GÖRÜNÜM', secondaryColor),
                  const SizedBox(height: 8),

                  // Dark mode
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.dark_mode_outlined,
                            size: 22, color: secondaryColor),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Gece Modu',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                        CupertinoSwitch(
                          value: themeProvider.isDarkMode,
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            themeProvider.toggleTheme();
                          },
                          activeTrackColor: AppTheme.accent,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section: Notifications
                  _sectionTitle('BİLDİRİMLER', secondaryColor),
                  const SizedBox(height: 8),

                  _settingsCard(
                    icon: Icons.access_time_rounded,
                    label: 'Bildirim Zamanı',
                    trailing: Text(
                      '09:00',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: secondaryColor),
                    ),
                    cardBg: cardBg,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    onTap: () {
                      // Placeholder — TimeOfDay picker
                    },
                  ),

                  const SizedBox(height: 24),

                  // Section: Data
                  _sectionTitle('VERİ', secondaryColor),
                  const SizedBox(height: 8),

                  _settingsCard(
                    icon: Icons.cloud_upload_outlined,
                    label: 'Verileri Yedekle',
                    cardBg: cardBg,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    onTap: () {
                      // Placeholder
                    },
                  ),
                  const SizedBox(height: 8),
                  _settingsCard(
                    icon: Icons.cloud_download_outlined,
                    label: 'Verileri Geri Yükle',
                    cardBg: cardBg,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    onTap: () {
                      // Placeholder
                    },
                  ),
                  const SizedBox(height: 8),

                  // Delete all data — red
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showDeleteAllDialog(context, isDark);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.delete_forever_rounded,
                              size: 22, color: Color(0xFFFF3B30)),
                          const SizedBox(width: 14),
                          Text(
                            'Tüm Verileri Sil',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFFF3B30),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _settingsCard({
    required IconData icon,
    required String label,
    Widget? trailing,
    required Color cardBg,
    required Color textColor,
    required Color secondaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: secondaryColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    size: 22, color: secondaryColor),
          ],
        ),
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Tüm Verileri Sil',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.primaryText,
          ),
        ),
        content: Text(
          'Tüm etkinlikler kalıcı olarak silinecek. Bu işlem geri alınamaz.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isDark ? Colors.grey[300] : AppTheme.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Vazgeç',
              style: GoogleFonts.poppins(
                color: isDark ? Colors.grey[400] : AppTheme.secondaryText,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              // TODO: Clear all data
              Navigator.pop(ctx);
            },
            child: Text(
              'Sil',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF3B30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
