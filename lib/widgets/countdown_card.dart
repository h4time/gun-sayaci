import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';

class CountdownCard extends StatefulWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final bool isPastView;
  final String cardSize; // 'large', 'medium', 'small'

  const CountdownCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onDelete,
    this.onEdit,
    this.isPastView = false,
    this.cardSize = 'large',
  });

  @override
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard> {
  bool _pressed = false;

  static const Map<String, Color> _categoryColors = {
    'Doğum Günü': Color(0xFFFF4B77),
    'Tatil': Color(0xFF2EC4B6),
    'Düğün/Yıldönümü': Color(0xFFFF6B9D),
    'Sınav/İş': Color(0xFFF5A623),
    'Seyahat': Color(0xFF8B5CF6),
    'Konser/Etkinlik': Color(0xFF6C5CE7),
    'Spor/Hedef': Color(0xFF4CAF50),
  };

  static const Map<String, String> _categoryEmojis = {
    'Doğum Günü': '🎂',
    'Tatil': '✈️',
    'Düğün/Yıldönümü': '💍',
    'Sınav/İş': '💼',
    'Seyahat': '🧳',
    'Konser/Etkinlik': '🎵',
    'Spor/Hedef': '🏆',
  };

  static const Color _customCategoryColor = Color(0xFF8E8E93);
  static const String _customCategoryEmoji = '✏️';

  static const _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];
  static const _dayNames = [
    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma',
    'Cumartesi', 'Pazar',
  ];

  // AspectRatio per size – drives the card height from available width.
  //   Large  16/9  ≈ 1.78  (original ~220px on 375-wide screen)
  //   Medium 16/7  ≈ 2.29
  //   Small  16/5  =  3.20
  double get _aspectRatio {
    switch (widget.cardSize) {
      case 'small':
        return 16 / 5;
      case 'medium':
        return 16 / 7;
      default:
        return 16 / 9;
    }
  }

  double _calc365Progress() {
    final days = widget.event.daysRemaining;
    if (widget.event.isToday) return 1.0;
    if (widget.isPastView || widget.event.isExpired) return 1.0;
    if (days >= 365) return 0.03;
    return ((365 - days) / 365).clamp(0.03, 1.0);
  }

  void _onTapDown(TapDownDetails _) => setState(() => _pressed = true);
  void _onTapUp(TapUpDetails _) => setState(() => _pressed = false);
  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final imagePath = AppTheme.getImageForCategory(widget.event.category);
    final isToday = widget.event.isToday;
    final isPast = widget.isPastView || (widget.event.isExpired && !isToday);
    final catColor =
        _categoryColors[widget.event.category] ?? _customCategoryColor;
    final catEmoji =
        _categoryEmojis[widget.event.category] ?? _customCategoryEmoji;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: Duration(milliseconds: _pressed ? 150 : 250),
        curve: _pressed ? Curves.easeOut : Curves.elasticOut,
        child: AnimatedContainer(
          duration: Duration(milliseconds: _pressed ? 150 : 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _pressed
                  ? catColor.withValues(alpha: 0.2)
                  : const Color(0x0F000000),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, _pressed ? 0.12 : 0.06),
                blurRadius: _pressed ? 18 : 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            onLongPress: () {
              HapticFeedback.mediumImpact();
              widget.onEdit?.call();
            },
            child: Opacity(
              opacity: isPast ? 0.7 : 1.0,
              child: AspectRatio(
                aspectRatio: _aspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final h = constraints.maxHeight;
                      final w = constraints.maxWidth;
                      // All sizes derived from actual card height
                      final topPad = h * 0.045;
                      final bottomPad = h * 0.065;
                      final circleSize = (h * 0.23).clamp(28.0, 50.0);
                      final circleRadius = circleSize * 0.46;
                      final circleLineW = circleSize < 36 ? 1.5 : 2.0;
                      final countFontSz = (circleSize * 0.34).clamp(9.0, 17.0);
                      final countLabelSz = (circleSize * 0.16).clamp(4.5, 8.0);
                      final badgeFontSz = (h * 0.042).clamp(6.0, 9.0);
                      final badgeHPad = badgeFontSz < 7.5 ? 5.0 : 8.0;
                      final badgeVPad = badgeFontSz < 7.5 ? 2.0 : 4.0;
                      final titleFontSz = (h * 0.1058).clamp(12.65, 23.0);
                      final dateFontSz = (h * 0.05).clamp(7.0, 11.0);
                      final titleMaxLines = h < 140 ? 1 : 2;
                      final bugunFontSz = (h * 0.05).clamp(7.0, 11.0);
                      final bugunHPad = bugunFontSz < 9 ? 8.0 : 14.0;
                      final bugunVPad = bugunFontSz < 9 ? 2.0 : 4.0;

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          // Photo
                          Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            cacheWidth: 800,
                            cacheHeight: 400,
                            colorBlendMode:
                                isPast ? BlendMode.saturation : null,
                            color: isPast ? Colors.grey : null,
                            frameBuilder: (context, child, frame,
                                wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded) return child;
                              if (frame != null) {
                                return AnimatedOpacity(
                                  opacity: 1.0,
                                  duration:
                                      const Duration(milliseconds: 300),
                                  child: child,
                                );
                              }
                              return Container(
                                color: const Color(0xFF2C2C2E),
                              )
                                  .animate(onPlay: (c) => c.repeat())
                                  .shimmer(
                                    duration: 1200.ms,
                                    color: const Color(0x33FFFFFF),
                                  );
                            },
                          ),

                          // Gradient
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: h * 0.65,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x00000000),
                                    Color(0xB3000000),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Category badge
                          Positioned(
                            top: topPad,
                            left: topPad,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: badgeHPad,
                                  vertical: badgeVPad),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(catEmoji,
                                      style: TextStyle(
                                          fontSize: badgeFontSz)),
                                  SizedBox(
                                      width:
                                          badgeFontSz < 7.5 ? 2 : 3),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth: w * 0.45),
                                    child: Text(
                                      widget.event.category,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: badgeFontSz,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Countdown circle
                          Positioned(
                            top: topPad,
                            right: topPad,
                            child: _buildCountdownCircle(
                              event: widget.event,
                              isToday: isToday,
                              isPast: isPast,
                              size: circleSize,
                              radius: circleRadius,
                              lineWidth: circleLineW,
                              countFontSize: countFontSz,
                              labelFontSize: countLabelSz,
                            ),
                          ),

                          // "BUGÜN" badge
                          if (isToday)
                            Positioned(
                              top: topPad,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: bugunHPad,
                                      vertical: bugunVPad),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'BUGÜN',
                                    style: GoogleFonts.poppins(
                                      fontSize: bugunFontSz,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Title + Date
                          Positioned(
                            bottom: bottomPad,
                            left: bottomPad,
                            right: bottomPad,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.event.title,
                                  textAlign: TextAlign.center,
                                  maxLines: titleMaxLines,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: titleFontSz,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                    color: Colors.white,
                                    height: 1.15,
                                    shadows: const [
                                      Shadow(
                                        blurRadius: 8,
                                        color: Color(0x80000000),
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: h * 0.01),
                                Text(
                                  _formatDate(widget.event.targetDate),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: dateFontSz,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xA6FFFFFF),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownCircle({
    required EventModel event,
    required bool isToday,
    required bool isPast,
    required double size,
    required double radius,
    required double lineWidth,
    required double countFontSize,
    required double labelFontSize,
  }) {
    final days = event.daysRemaining;
    final absDays = days.abs();

    String countText;
    String labelText;

    if (isToday) {
      countText = '!';
      labelText = 'BUGÜN';
    } else if (isPast) {
      countText = '$absDays';
      labelText = 'ÖNCE';
    } else if (absDays == 0) {
      countText = '${event.remaining.inHours}';
      labelText = 'SAAT';
    } else {
      countText = '$absDays';
      labelText = 'GÜN';
    }

    final percent = _calc365Progress();
    const progressColor = AppTheme.accent;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0x55000000),
        shape: BoxShape.circle,
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: CircularPercentIndicator(
          radius: radius,
          lineWidth: lineWidth,
          percent: percent,
          animation: true,
          animationDuration: 800,
          circularStrokeCap: CircularStrokeCap.round,
          fillColor: Colors.transparent,
          progressColor: isToday
              ? const Color(0xFFFFD700)
              : isPast
                  ? const Color(0x99FFFFFF)
                  : progressColor,
          backgroundColor: const Color(0x26FFFFFF),
          center: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                countText,
                style: GoogleFonts.poppins(
                  fontSize: countFontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              Text(
                labelText,
                style: GoogleFonts.poppins(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xB3FFFFFF),
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year} ${_dayNames[date.weekday - 1]}';
  }
}
