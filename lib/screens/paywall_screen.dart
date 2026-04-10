import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _features = [
    (
      icon: Icons.aspect_ratio_rounded,
      title: 'Tüm Etkinlik Boyutları',
      description:
          'Büyük, orta ve küçük kart boyutlarıyla\netkinliklerini istediğin gibi görüntüle.',
    ),
    (
      icon: Icons.palette_outlined,
      title: 'Kategori Temaları',
      description:
          'Her kategoriye özel arka plan fotoğrafı seç,\netkinliklerini kişiselleştir.',
    ),
    (
      icon: Icons.cloud_outlined,
      title: 'Yedekleme & Geri Yükleme',
      description:
          'Etkinliklerini yedekle ve istediğin zaman\ngeri yükle. Verilerini asla kaybetme.',
    ),
    (
      icon: Icons.block_rounded,
      title: 'Reklamsız Deneyim',
      description:
          'Hiçbir reklam olmadan, kesintisiz\nbir deneyimin keyfini çıkar.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Content
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 16),

              // X button — top right
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 20, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Logo + title
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/icons/icon_dark.png',
                  width: 72,
                  height: 72,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Gün Sayacı Pro',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tüm özelliklerin kilidini aç',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white54,
                ),
              ),

              const SizedBox(height: 40),

              // Feature carousel
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _features.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final f = _features[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          // Icon circle
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              f.icon,
                              size: 36,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            f.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            f.description,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.white54,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Dot indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_features.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Purchase card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Ömür Boyu Pro',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bir kere öde, sonsuza kadar kullan',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '₺149,99',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Buy button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        debugPrint('Satın alma başlatılacak');
                      },
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Satın Al',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16 + bottomPadding),
            ],
          ),
        ],
      ),
    );
  }
}
