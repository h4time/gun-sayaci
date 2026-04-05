import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';

class CountdownCard extends StatefulWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final bool isPastView;

  const CountdownCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onDelete,
    this.onEdit,
    this.isPastView = false,
  });

  @override
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  static const Map<String, Color> _categoryColors = {
    'Doğum Günü': Color(0xFFFF4B77),
    'Tatil': Color(0xFF2EC4B6),
    'Düğün/Yıldönümü': Color(0xFFFF6B9D),
    'Sınav/İş': Color(0xFFF5A623),
    'Seyahat': Color(0xFF8B5CF6),
    'Diğer': Color(0xFF8E8E93),
  };

  static const Map<String, String> _categoryEmojis = {
    'Doğum Günü': '🎂',
    'Tatil': '✈️',
    'Düğün/Yıldönümü': '💍',
    'Sınav/İş': '💼',
    'Seyahat': '🧳',
    'Diğer': '•••',
  };

  static const _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];
  static const _dayNames = [
    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma',
    'Cumartesi', 'Pazar',
  ];

  double _calc365Progress() {
    final days = widget.event.daysRemaining;
    if (widget.event.isToday) return 1.0;
    if (widget.isPastView || widget.event.isExpired) return 1.0;
    if (days >= 365) return 0.03; // minimum so ring isn't empty
    return ((365 - days) / 365).clamp(0.03, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    final target = _calc365Progress();
    _progressAnim = Tween<double>(begin: 0, end: target).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic),
    );
    _progressCtrl.forward();
  }

  @override
  void didUpdateWidget(covariant CountdownCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.daysRemaining != widget.event.daysRemaining) {
      final target = _calc365Progress();
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: target,
      ).animate(
        CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic),
      );
      _progressCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
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
        _categoryColors[widget.event.category] ?? const Color(0xFF8E8E93);
    final catEmoji = _categoryEmojis[widget.event.category] ?? '📌';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
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
                height: 190,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Photo
                      Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        colorBlendMode:
                            isPast ? BlendMode.saturation : null,
                        color: isPast ? Colors.grey : null,
                      ),

                      // Gradient
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 190 * 0.55,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x00000000),
                                Color(0x8C000000),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Category badge (translucent)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(catEmoji,
                                  style: const TextStyle(fontSize: 10)),
                              const SizedBox(width: 3),
                              Text(
                                widget.event.category,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
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
                        top: 12,
                        right: 12,
                        child: _buildCountdownCircle(
                            widget.event, isToday, isPast, catColor),
                      ),

                      // "BUGÜN" badge
                      if (isToday)
                        Positioned(
                          top: 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'BUGÜN',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
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
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.event.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 22,
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
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xA6FFFFFF), // 65%
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

    final ringColor = isToday
        ? const Color(0xFFFFD700)
        : isPast
            ? const Color(0x99FFFFFF)
            : catColor;

    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (context, child) {
        return SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow (stronger on today)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ringColor.withValues(
                          alpha: isToday ? 0.6 : 0.35),
                      blurRadius: isToday ? 12 : 8,
                    ),
                  ],
                ),
              ),
              // Progress ring
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: _progressAnim.value,
                  strokeWidth: 3,
                  backgroundColor: const Color(0x33FFFFFF),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ringColor),
                ),
              ),
              // Inner circle
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0x4DFFFFFF),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          countText,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          labelText,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xB3FFFFFF),
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year} ${_dayNames[date.weekday - 1]}';
  }
}
