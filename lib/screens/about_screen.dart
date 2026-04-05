import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final secondaryColor = isDark ? Colors.grey[400]! : AppTheme.secondaryText;

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
                    'Hakkında',
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
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isDark
                              ? const Color(0xFF1C1C1E)
                              : const Color(0xFFF5F5F0),
                        ),
                        child: Icon(Icons.timer_rounded,
                            size: 40, color: textColor),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Gün Sayacı',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#ozelgunleriunutma',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          color: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'v1.0.0',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bu uygulama ile özel günlerinizi\nasla unutmayın.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: secondaryColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Geliştirici',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ömer Faruk Öztürk',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Website
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          launchUrl(
                              Uri.parse('https://ozelgunleriunutma.com'));
                        },
                        child: Text(
                          'ozelgunleriunutma.com',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.accent,
                            decoration: TextDecoration.underline,
                            decorationColor: AppTheme.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Social icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialButton(
                            icon: Icons.camera_alt_outlined,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              launchUrl(Uri.parse(
                                  'https://instagram.com/ozelgunleriunutma'));
                            },
                            isDark: isDark,
                          ),
                          const SizedBox(width: 16),
                          _socialButton(
                            icon: Icons.alternate_email_rounded,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              launchUrl(Uri.parse(
                                  'https://x.com/ozelgunlerunutm'));
                            },
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF5F5F0),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 22,
            color: isDark ? Colors.white : AppTheme.primaryText),
      ),
    );
  }
}
