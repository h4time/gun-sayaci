import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _version = 'v${info.version}+${info.buildNumber}');
    }
  }

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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // App icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.accent,
                              AppTheme.accent.withValues(alpha: 0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.accent.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.timer_rounded,
                            size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Gün Sayacı',
                        style: GoogleFonts.poppins(
                          fontSize: 30,
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
                      const SizedBox(height: 6),
                      Text(
                        _version,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Özel günlerinizi asla unutmayın.\nDoğum günleri, bayramlar, yıldönümleri\nve daha fazlası için geri sayım yapın.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: secondaryColor,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Developer section
                      Text(
                        'Geliştirici',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: secondaryColor,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ömer Faruk Öztürk',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
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
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Social icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialButton(
                            icon: Icons.camera_alt_outlined,
                            label: 'Instagram',
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
                            label: 'Threads',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              launchUrl(Uri.parse(
                                  'https://www.threads.net/@ozelgunleriunutma'));
                            },
                            isDark: isDark,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      Text(
                        'Sevgiyle yapıldı ❤️',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
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
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.accent.withValues(alpha: 0.15),
                  AppTheme.accent.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Icon(icon, size: 24, color: AppTheme.accent),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
