import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Phase 1: Title (0-1000ms)
  late Animation<double> _titleFade;
  late Animation<double> _titleSlide;

  // Phase 2: Quote (400-1400ms)
  late Animation<double> _quoteFade;
  late Animation<double> _quoteSlide;

  // Phase 3: Cards fade from transparent — staggered diagonal pairs
  // Pair A (cards 0,5): 800-2200ms  — first diagonal
  // Pair B (cards 1,3): 1200-2600ms — second diagonal
  // Pair C (cards 2,4): 1600-3000ms — third diagonal (latest)
  late List<Animation<double>> _cardFades;

  // Phase 4: Screen fade out (4000-5000ms)
  late Animation<double> _screenFade;

  static const _cards = [
    // Row 1
    ('assets/images/birthday.jpg', '28 GÜN SONRA', 'Doğum Günü', 200.0, false),
    ('assets/images/travel.jpg', '3 GÜN SONRA', 'Tatil', 160.0, true),
    ('assets/images/seyahat.jpg', '16 HAFTA SONRA', 'Seyahat', 220.0, true),
    // Row 2
    ('assets/images/celebration.jpg', 'YARIN', 'Yıldönümü', 180.0, true),
    ('assets/images/spor.jpg', '3 SAAT SONRA', 'Antrenman', 160.0, false),
    ('assets/images/concert.jpg', '1 AY SONRA', 'Konser', 180.0, true),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    // --- PHASE 1: Title first (0-1000ms) ---
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.20, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.22, curve: Curves.easeOutCubic),
      ),
    );

    // --- PHASE 2: Quote (400-1400ms) ---
    _quoteFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.08, 0.28, curve: Curves.easeOut),
      ),
    );
    _quoteSlide = Tween<double>(begin: 14.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.08, 0.30, curve: Curves.easeOutCubic),
      ),
    );

    // --- PHASE 3: Cards — slow fade from transparent ---
    // Pair A: cards 0,5 (top-left + bottom-right diagonal)
    // Pair B: cards 1,3 (top-center + bottom-left)
    // Pair C: cards 2,4 (top-right + bottom-center) — latest
    final cardPairIndex = [0, 1, 2, 1, 2, 0]; // which pair each card belongs to

    // Pair A: 0.16-0.52 (800ms-2600ms)  = 1800ms fade duration
    // Pair B: 0.24-0.58 (1200ms-2900ms) = 1700ms fade duration
    // Pair C: 0.32-0.64 (1600ms-3200ms) = 1600ms fade duration
    final pairStarts = [0.16, 0.24, 0.32];
    final pairEnds = [0.52, 0.58, 0.64];

    _cardFades = [];
    for (int i = 0; i < 6; i++) {
      final pair = cardPairIndex[i];
      _cardFades.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(pairStarts[pair], pairEnds[pair],
                curve: Curves.easeOut),
          ),
        ),
      );
    }

    // --- PHASE 4: Screen fade out (4000-5000ms) ---
    _screenFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.80, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const HomeScreen(),
            transitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (_, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.bgDark : Colors.white;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: bgColor,
      body: Opacity(
        opacity: _screenFade.value,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48),

              // Card grid — fades in AFTER text
              ClipRect(
                child: Column(
                  children: [
                    // Row 1 — shifted left
                    Transform.translate(
                      offset: const Offset(-20, 0),
                      child: SizedBox(
                        width: screenWidth + 40,
                        height: 220,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _animatedCard(0, 200),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: _animatedCard(1, 160),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: _animatedCard(2, 220),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Row 2 — shifted right
                    Transform.translate(
                      offset: const Offset(20, 0),
                      child: SizedBox(
                        width: screenWidth + 40,
                        height: 180,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _animatedCard(3, 180),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: _animatedCard(4, 160),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: _animatedCard(5, 180),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Title: "Gün Sayacı" — appears FIRST
              Transform.translate(
                offset: Offset(0, _titleSlide.value),
                child: Opacity(
                  opacity: _titleFade.value,
                  child: Text(
                    'Gün Sayacı',
                    style: TextStyle(
                      fontFamily: '.SF Pro Display',
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Quote — appears right after title
              Transform.translate(
                offset: Offset(0, _quoteSlide.value),
                child: Opacity(
                  opacity: _quoteFade.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      '"Her özel gün, hatırlanmayı hak eder."',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.caveat(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? Colors.grey[400]
                            : const Color(0xFF8E8E93),
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }

  Widget _animatedCard(int index, double height) {
    final card = _cards[index];
    final image = card.$1;
    final countdown = card.$2;
    final title = card.$3;
    final showText = card.$5;
    final opacity = _cardFades[index].value;

    // Subtle zoom settle: starts at 1.03, settles to 1.0
    final scale = 1.0 + (1.0 - opacity) * 0.03;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: _sampleCard(image, countdown, title, height,
            showText: showText, textOpacity: opacity),
      ),
    );
  }

  Widget _sampleCard(
      String image, String countdown, String title, double height,
      {bool showText = true, double textOpacity = 1.0}) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover, cacheWidth: 400),
            if (showText)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: height * 0.6,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xAA000000)],
                    ),
                  ),
                ),
              ),
            if (showText)
              Positioned(
                bottom: 12,
                left: 10,
                right: 10,
                child: Opacity(
                  opacity: textOpacity.clamp(0.0, 1.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        countdown,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
