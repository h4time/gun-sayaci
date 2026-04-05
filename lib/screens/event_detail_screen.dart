import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';
import '../widgets/confetti_widget.dart';
import 'add_event_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  bool _confettiPlayed = false;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
    // Confetti + haptic on first open if today
    if (widget.event.isToday) {
      _confettiPlayed = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) HapticFeedback.mediumImpact();
      });
    }
  }

  void _updateRemaining() {
    setState(() {
      _remaining = widget.event.targetDate.difference(DateTime.now());
      if (_remaining.isNegative) _remaining = Duration.zero;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = AppTheme.getImageForCategory(widget.event.category);
    final isToday = widget.event.isToday;
    final isPast = widget.event.isExpired && !isToday;

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              cacheWidth: 900,
              cacheHeight: 1600,
              colorBlendMode: isPast ? BlendMode.saturation : null,
              color: isPast ? Colors.grey : null,
            ),
          ),

          // Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),

          // Confetti — only once on today
          if (isToday && _confettiPlayed)
            const ConfettiWidget(isPlaying: true),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      _circleBtn(Icons.arrow_back_ios_new_rounded, () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      }),
                      const Spacer(),
                      _circleBtn(Icons.edit_rounded, () {
                        HapticFeedback.lightImpact();
                        _editEvent();
                      }),
                      const SizedBox(width: 8),
                      _circleBtn(Icons.share_rounded, () {
                        HapticFeedback.lightImpact();
                        _shareEvent();
                      }),
                    ],
                  ),
                ),

                const Spacer(),

                // Big countdown
                if (isToday) ...[
                  Text(
                    'Bugün!',
                    style: GoogleFonts.poppins(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFFD700),
                      height: 1.0,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Kutlu Olsun!',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    '${widget.event.daysRemaining.abs()}',
                    style: GoogleFonts.poppins(
                      fontSize: 72,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.0,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPast ? 'gün önce' : 'gün',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    widget.event.title,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 8),

                // Category + Date
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.event.category,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _formatFullDate(widget.event.targetDate),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 40),

                // Countdown boxes
                if (!isPast)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        _box(days.toString(), 'Gün'),
                        const SizedBox(width: 10),
                        _box(hours.toString().padLeft(2, '0'), 'Saat'),
                        const SizedBox(width: 10),
                        _box(minutes.toString().padLeft(2, '0'), 'Dakika'),
                        const SizedBox(width: 10),
                        _box(seconds.toString().padLeft(2, '0'), 'Saniye'),
                      ],
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.event.daysRemaining.abs()} gün önce tamamlandı',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }

  Widget _box(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareEvent() {
    final daysLeft = widget.event.daysRemaining;
    String shareText;
    if (daysLeft > 0) {
      shareText =
          '${widget.event.title} etkinliğine $daysLeft gün kaldı!';
    } else if (daysLeft == 0) {
      shareText = '${widget.event.title} bugün!';
    } else {
      shareText =
          '${widget.event.title} ${daysLeft.abs()} gün önce gerçekleşti.';
    }
    shareText += ' #ozelgunleriunutma';
    Share.share(shareText);
  }

  void _editEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEventSheet(event: widget.event)),
    );
  }

  String _formatFullDate(DateTime date) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    const days = [
      'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi',
      'Pazar',
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
