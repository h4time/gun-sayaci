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

  // ── Size-dependent dimensions ──
  // Heights chosen so all content (badge, circle, title, date) fits
  // without overflow at any font/padding combination.
  //   Large  = 220  (original, untouched)
  //   Medium = 165  (≈75 %)
  //   Small  = 125  (≈57 %)

  double get _cardHeight {
    switch (widget.cardSize) {
      case 'small':
        return 125.0;
      case 'medium':
        return 165.0;
      default:
        return 220.0;
    }
  }

  double get _titleFont {
    switch (widget.cardSize) {
      case 'small':
        return 13.0;
      case 'medium':
        return 16.0;
      default:
        return 20.0;
    }
  }

  double get _dateFont {
    switch (widget.cardSize) {
      case 'small':
        return 8.0;
      case 'medium':
        return 9.5;
      default:
        return 11.0;
    }
  }

  double get _circleSize {
    switch (widget.cardSize) {
      case 'small':
        return 34.0;
      case 'medium':
        return 42.0;
      default:
        return 50.0;
    }
  }

  double get _circleRadius {
    switch (widget.cardSize) {
      case 'small':
        return 15.0;
      case 'medium':
        return 19.0;
      default:
        return 23.0;
    }
  }

  double get _countFont {
    switch (widget.cardSize) {
      case 'small':
        return 12.0;
      case 'medium':
        return 14.0;
      default:
        return 17.0;
    }
  }

  double get _countLabelFont {
    switch (widget.cardSize) {
      case 'small':
        return 5.5;
      case 'medium':
        return 6.5;
      default:
        return 8.0;
    }
  }

  double get _badgeEmojiFont {
    switch (widget.cardSize) {
      case 'small':
        return 7.0;
      case 'medium':
        return 8.0;
      default:
        return 9.0;
    }
  }

  double get _badgeTextFont => _badgeEmojiFont;

  double get _bottomPad {
    switch (widget.cardSize) {
      case 'small':
        return 8.0;
      case 'medium':
        return 10.0;
      default:
        return 14.0;
    }
  }

  double get _topPad {
    switch (widget.cardSize) {
      case 'small':
        return 6.0;
      case 'medium':
        return 8.0;
      default:
        return 10.0;
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
              child: SizedBox(
                height: _cardHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
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
                        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) return child;
                          if (frame != null) {
                            return AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: child,
                            );
                          }
                          return Container(
                            color: const Color(0xFF2C2C2E),
                          ).animate(onPlay: (c) => c.repeat())
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
                        height: _cardHeight * 0.60,
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

                      // Category badge (translucent)
                      Positioned(
                        top: _topPad,
                        left: _topPad,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: widget.cardSize == 'small' ? 5 : 8,
                              vertical: widget.cardSize == 'small' ? 2 : 4),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(catEmoji,
                                  style: TextStyle(fontSize: _badgeEmojiFont)),
                              SizedBox(width: widget.cardSize == 'small' ? 2 : 3),
                              Text(
                                widget.event.category,
                                style: GoogleFonts.poppins(
                                  fontSize: _badgeTextFont,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Countdown circle
                      Positioned(
                        top: _topPad,
                        right: _topPad,
                        child: _buildCountdownCircle(
                            widget.event, isToday, isPast, catColor),
                      ),

                      // "BUGÜN" badge
                      if (isToday)
                        Positioned(
                          top: _topPad,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: widget.cardSize == 'small' ? 8 : 14,
                                  vertical: widget.cardSize == 'small' ? 2 : 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'BUGÜN',
                                style: GoogleFonts.poppins(
                                  fontSize: widget.cardSize == 'small' ? 7 : (widget.cardSize == 'medium' ? 9 : 11),
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
                        bottom: _bottomPad,
                        left: _bottomPad,
                        right: _bottomPad,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.event.title,
                              textAlign: TextAlign.center,
                              maxLines: widget.cardSize == 'small' ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: _titleFont,
                                fontWeight: FontWeight.w700,
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
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(widget.event.targetDate),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: _dateFont,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xA6FFFFFF),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownCircle(
      EventModel event, bool isToday, bool isPast, Color catColor) {
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
      width: _circleSize,
      height: _circleSize,
      decoration: const BoxDecoration(
        color: Color(0x55000000),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CircularPercentIndicator(
          radius: _circleRadius,
          lineWidth: widget.cardSize == 'small' ? 1.5 : 2.0,
          percent: percent,
          animation: true,
          animationDuration: 800,
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: isToday
              ? const Color(0xFFFFD700)
              : isPast
                  ? const Color(0x99FFFFFF)
                  : progressColor,
          backgroundColor: const Color(0x26FFFFFF),
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                countText,
                style: GoogleFonts.poppins(
                  fontSize: _countFont,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              Text(
                labelText,
                style: GoogleFonts.poppins(
                  fontSize: _countLabelFont,
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
