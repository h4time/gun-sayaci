import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final Map<int, bool> _expandedFaq = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF5F5F0);
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final secondaryColor = isDark ? Colors.grey[400]! : AppTheme.secondaryText;
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final iconBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);

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
                    'Destek',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // App icon
                    Image.asset(
                      'assets/images/logo_transparent.png',
                      width: 72,
                      height: 72,
                    ),
                    const SizedBox(height: 32),

                    // Website card
                    _contactCard(
                      icon: Icons.language_rounded,
                      label: 'Website',
                      subtitle: 'ozelgunleriunutma.com',
                      cardBg: cardBg,
                      iconBg: iconBg,
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        launchUrl(
                            Uri.parse('https://ozelgunleriunutma.com'));
                      },
                    ),
                    const SizedBox(height: 8),

                    // Email card
                    _contactCard(
                      icon: Icons.mail_outline_rounded,
                      label: 'E-posta',
                      subtitle: 'info@ozelgunleriunutma.com',
                      cardBg: cardBg,
                      iconBg: iconBg,
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        launchUrl(Uri.parse(
                            'mailto:info@ozelgunleriunutma.com?subject=Destek%20Talebi'));
                      },
                    ),

                    const SizedBox(height: 24),

                    // FAQ section title
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'SIKÇA SORULAN SORULAR',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: secondaryColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // FAQ grouped container
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _faqItem(
                            0,
                            'Etkinlik nasıl eklenir?',
                            'Ana sayfadaki + butonuna tıklayın, etkinlik adını ve kategorisini seçin, ardından tarihi belirleyip kaydedin.',
                            isDark,
                            textColor,
                            secondaryColor,
                          ),
                          _faqDivider(isDark),
                          _faqItem(
                            1,
                            'Bildirimler nasıl çalışır?',
                            'Tercihler\'den bildirim zamanını ayarlayabilirsiniz. Etkinlik günü ve öncesinde belirlediğiniz saatte hatırlatma alırsınız.',
                            isDark,
                            textColor,
                            secondaryColor,
                          ),
                          _faqDivider(isDark),
                          _faqItem(
                            2,
                            'Verilerimi nasıl yedeklerim?',
                            'Tercihler > Verileri Yedekle seçeneğiyle tüm etkinliklerinizi JSON dosyası olarak dışa aktarabilirsiniz.',
                            isDark,
                            textColor,
                            secondaryColor,
                          ),
                          _faqDivider(isDark),
                          _faqItem(
                            3,
                            'Kategori temasını nasıl değiştiririm?',
                            'Tercihler > Kategori Temaları\'ndan istediğiniz kategoriye tıklayıp hazır görsellerden birini seçebilir veya galeriden kendi fotoğrafınızı yükleyebilirsiniz.',
                            isDark,
                            textColor,
                            secondaryColor,
                          ),
                          _faqDivider(isDark),
                          _faqItem(
                            4,
                            'Geçmiş etkinliklerimi görebilir miyim?',
                            'Ana sayfadaki Geçmiş/Yaklaşan toggle\'ından Geçmiş\'e tıklayarak tamamlanmış etkinliklerinizi görüntüleyebilirsiniz.',
                            isDark,
                            textColor,
                            secondaryColor,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color cardBg,
    required Color iconBg,
    required Color textColor,
    required Color secondaryColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: secondaryColor),
          ],
        ),
      ),
    );
  }

  Widget _faqDivider(bool isDark) {
    return Divider(
      height: 0.5,
      thickness: 0.5,
      color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
      indent: 20,
      endIndent: 20,
    );
  }

  Widget _faqItem(
    int index,
    String question,
    String answer,
    bool isDark,
    Color textColor,
    Color secondaryColor,
  ) {
    final isExpanded = _expandedFaq[index] ?? false;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _expandedFaq[index] = !isExpanded;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more_rounded,
                    size: 22,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          answer,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: secondaryColor,
                            height: 1.6,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
