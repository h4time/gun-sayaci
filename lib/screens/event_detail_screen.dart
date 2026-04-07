import 'dart:io';
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
  bool _confettiPlayed = false;

  @override
  void initState() {
    super.initState();
    // Confetti + haptic on first open if today
    if (widget.event.isToday) {
      _confettiPlayed = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) HapticFeedback.mediumImpact();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = AppTheme.getImageForCategory(widget.event.category);
    final isToday = widget.event.isToday;
    final isPast = widget.event.isExpired && !isToday;
    final daysAbs = widget.event.daysRemaining.abs();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background photo — full screen, no blur
          AppTheme.isFilePath(imagePath)
              ? Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stack) => Image.asset(
                    AppTheme.categoryImages[widget.event.category] ??
                        'assets/images/celebration.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
              : Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  cacheWidth: 900,
                  cacheHeight: 1600,
                ),

          // Top gradient — for button visibility
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom gradient — for text readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 360,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
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
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // X close button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0x0F000000),
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.close,
                              size: 22, color: Color(0xFF1A1A1A)),
                        ),
                      ),
                      const Spacer(),
                      // Share pill button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _shareEvent();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0x0F000000),
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Paylaş',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // More (edit) button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _editEvent();
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0x0F000000),
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.more_horiz,
                              size: 22, color: Color(0xFF1A1A1A)),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Countdown label
                Text(
                  isToday
                      ? 'BUGÜN!'
                      : isPast
                          ? '$daysAbs GÜN ÖNCE'
                          : '$daysAbs GÜN SONRA',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 12),

                // Event title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    widget.event.title,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 12,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 16),

                // Date pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    _formatFullDate(widget.event.targetDate).toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
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
