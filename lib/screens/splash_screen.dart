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

  // Title + quote
  late Animation<double> _titleFade;
  late Animation<double> _titleSlide;
  late Animation<double> _quoteFade;
  late Animation<double> _quoteSlide;

  // Cards — diagonal pairs, slow fade
  late List<Animation<double>> _cardFades;

  // Card overlay text — fades in slightly after card image
  late List<Animation<double>> _cardTextFades;

  // Screen fade out
  late Animation<double> _screenFade;

  // Card data: image, line1, line2
  static const _cards = [
    // Row 1
    (
      'assets/images/birthday.jpg',
      'Kankamın\nDoğum Günü',
      '12 gün kaldı',
    ),
    (
      'assets/images/travel.jpg',
      'Antalya\nTatili',
      '3 gün sonra',
    ),
    (
      'assets/images/seyahat.jpg',
      'Paris\nSeyahati',
      '16 hafta sonra',
    ),
    // Row 2
    (
      'assets/images/celebration.jpg',
      'Sevdiceğim\nDoğmuş',
      '17 Nisan',
    ),
    (
      'assets/images/spor.jpg',
      'Maraton\nGünü',
      '2 ay kaldı',
    ),
    (
      'assets/images/concert.jpg',
      'Konser\nGecesi',
      '1 ay sonra',
    ),
  ];

  // Heights per card
  static const _heights = [200.0, 160.0, 220.0, 180.0, 160.0, 180.0];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6500),
    );

    // --- Title: 0 - 1200ms (0.0 - 0.185) ---
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.185, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.20, curve: Curves.easeOutCubic),
      ),
    );

    // --- Quote: 500 - 1700ms (0.077 - 0.262) ---
    _quoteFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.077, 0.262, curve: Curves.easeOut),
      ),
    );
    _quoteSlide = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.077, 0.28, curve: Curves.easeOutCubic),
      ),
    );

    // --- Cards: diagonal pairs, very slow fade ---
    // Pair A (cards 0,5): 1000 - 3200ms (0.154 - 0.492)
    // Pair B (cards 1,3): 1500 - 3700ms (0.231 - 0.569)
    // Pair C (cards 2,4): 2000 - 4200ms (0.308 - 0.646)
    final cardPairIndex = [0, 1, 2, 1, 2, 0];
    final pairStarts = [0.154, 0.231, 0.308];
    final pairEnds = [0.492, 0.569, 0.646];

    // Card text fades in a bit after the image starts
    // offset ~400ms after card start
    final textOffset = 0.062; // ~400ms in 6500ms

    _cardFades = [];
    _cardTextFades = [];
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
      _cardTextFades.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
                pairStarts[pair] + textOffset, pairEnds[pair],
                curve: Curves.easeOut),
          ),
        ),
      );
    }

    // --- Screen fade out: 5200 - 6500ms (0.80 - 1.0) ---
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

              // Card grid
              ClipRect(
                child: Column(
                  children: [
                    // Row 1
                    Transform.translate(
                      offset: const Offset(-20, 0),
                      child: SizedBox(
                        width: screenWidth + 40,
                        height: 220,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(flex: 3, child: _animatedCard(0)),
                            const SizedBox(width: 10),
                            Expanded(flex: 2, child: _animatedCard(1)),
                            const SizedBox(width: 10),
                            Expanded(flex: 3, child: _animatedCard(2)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Row 2
                    Transform.translate(
                      offset: const Offset(20, 0),
                      child: SizedBox(
                        width: screenWidth + 40,
                        height: 180,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _animatedCard(3)),
                            const SizedBox(width: 10),
                            Expanded(flex: 2, child: _animatedCard(4)),
                            const SizedBox(width: 10),
                            Expanded(flex: 3, child: _animatedCard(5)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Title
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

              // Quote
              Transform.translate(
                offset: Offset(0, _quoteSlide.value),
                child: Opacity(
                  opacity: _quoteFade.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      '"Her özel gün, hatırlanmayı hak eder."',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.caveat(
                        fontSize: 22,
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

  Widget _animatedCard(int index) {
    final card = _cards[index];
    final image = card.$1;
    final line1 = card.$2;
    final line2 = card.$3;
    final height = _heights[index];
    final imgOpacity = _cardFades[index].value;
    final txtOpacity = _cardTextFades[index].value;

    // Subtle zoom settle
    final scale = 1.0 + (1.0 - imgOpacity) * 0.03;

    return Opacity(
      opacity: imgOpacity,
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                Image.asset(image, fit: BoxFit.cover, cacheWidth: 400),

                // Gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: height * 0.7,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0xBB000000)],
                      ),
                    ),
                  ),
                ),

                // Text on card — fades in after image
                Positioned(
                  bottom: 14,
                  left: 12,
                  right: 12,
                  child: Opacity(
                    opacity: txtOpacity.clamp(0.0, 1.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Countdown / date label
                        Text(
                          line2.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Title
                        Text(
                          line1,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.15,
                            shadows: const [
                              Shadow(
                                blurRadius: 8,
                                color: Color(0x66000000),
                                offset: Offset(0, 2),
                              ),
                            ],
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
        ),
      ),
    );
  }
}
