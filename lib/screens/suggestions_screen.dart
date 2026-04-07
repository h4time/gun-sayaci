import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  final _controller = TextEditingController();
  bool _sendPressed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF5F5F0);
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final secondaryColor = isDark ? Colors.grey[400]! : AppTheme.secondaryText;
    final fieldBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final btnColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final btnTextColor = isDark ? Colors.black : Colors.white;

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
                    'Öneriler',
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // App icon
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/icons/icon_white.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // TextField
                    TextField(
                      controller: _controller,
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w500, color: textColor),
                      maxLines: 8,
                      minLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Önerinizi buraya yazın...',
                        hintStyle: GoogleFonts.poppins(
                            color: secondaryColor, fontSize: 15, fontWeight: FontWeight.w400),
                        filled: true,
                        fillColor: fieldBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: AppTheme.accent, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Send button
                    GestureDetector(
                      onTapDown: (_) =>
                          setState(() => _sendPressed = true),
                      onTapUp: (_) =>
                          setState(() => _sendPressed = false),
                      onTapCancel: () =>
                          setState(() => _sendPressed = false),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        final body =
                            Uri.encodeComponent(_controller.text);
                        launchUrl(Uri.parse(
                            'mailto:info@ozelgunleriunutma.com?subject=Uygulama%20%C3%96nerisi&body=$body'));
                      },
                      child: AnimatedScale(
                        scale: _sendPressed ? 0.96 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: btnColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_forward_rounded,
                                  size: 18, color: btnTextColor),
                              const SizedBox(width: 8),
                              Text(
                                'Gönder',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: btnTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
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
