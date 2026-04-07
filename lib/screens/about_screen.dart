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
    final bgColor = isDark ? Colors.black : const Color(0xFFF5F5F0);
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final secondaryColor = isDark ? Colors.grey[400]! : AppTheme.secondaryText;
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    const linkColor = Color(0xFF4A90D9);

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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Card 1: App Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              'assets/icons/icon_white.png',
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gün Sayacı',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _version,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: secondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        launchUrl(Uri.parse(
                                            'https://ozelgunleriunutma.com'));
                                      },
                                      child: Row(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Website',
                                            style:
                                                GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.w500,
                                              color: linkColor,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          const Icon(
                                            Icons
                                                .arrow_outward_rounded,
                                            size: 14,
                                            color: linkColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        launchUrl(Uri.parse(
                                            'https://instagram.com/ozelgunleriunutma'));
                                      },
                                      child: Row(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Instagram',
                                            style:
                                                GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.w500,
                                              color: linkColor,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          const Icon(
                                            Icons
                                                .arrow_outward_rounded,
                                            size: 14,
                                            color: linkColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Card 2: Developer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(36),
                            child: Image.asset(
                              'assets/images/developer.jpg',
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ömer Faruk Öztürk',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Geliştirici',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: secondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        launchUrl(Uri.parse(
                                            'https://ozelgunleriunutma.com'));
                                      },
                                      child: Row(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Website',
                                            style:
                                                GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.w500,
                                              color: linkColor,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          const Icon(
                                            Icons
                                                .arrow_outward_rounded,
                                            size: 14,
                                            color: linkColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        launchUrl(Uri.parse(
                                            'https://youtube.com/@ozelgunleriunutma'));
                                      },
                                      child: Row(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          Text(
                                            'YouTube',
                                            style:
                                                GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.w500,
                                              color: linkColor,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          const Icon(
                                            Icons
                                                .arrow_outward_rounded,
                                            size: 14,
                                            color: linkColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
