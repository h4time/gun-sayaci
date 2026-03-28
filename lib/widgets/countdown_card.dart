import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';

class CountdownCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final imagePath = AppTheme.getImageForCategory(event.category);
    final iconPath = AppTheme.getIconForCategory(event.category);
    final isToday = event.isToday;
    final isPast = isPastView || (event.isExpired && !isToday);
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Opacity(
        opacity: isPastView ? 0.7 : 1.0,
        child: Dismissible(
          key: Key(event.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDelete(),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
          ),
          child: GestureDetector(
            onTap: onTap,
            onLongPress: onEdit,
            child: Container(
              height: 180,
              width: screenWidth - 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image with blur
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        colorBlendMode: isPast ? BlendMode.saturation : null,
                        color: isPast ? Colors.grey : null,
                      ),
                    ),

                    // Dark overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withValues(alpha: isPast ? 0.7 : 0.6),
                            Colors.black.withValues(alpha: isPast ? 0.5 : 0.35),
                          ],
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Row(
                        children: [
                          // Left side - Premium countdown (fixed 100px)
                          SizedBox(
                            width: 100,
                            child: _buildCountdownWidget(event, isToday, isPast),
                          ),

                          const SizedBox(width: 8),

                          // Middle - Event info (flexible, right padding for icon)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 50),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    event.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _formatDate(event.targetDate),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF2D1B69), Color(0xFF1A1A2E)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      event.category,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
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

                    // Category icon in top-right corner (fixed 40px area)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: _buildCategoryIcon(iconPath, event.category),
                      ),
                    ),

                    // D-Day celebration badge
                    if (isToday)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.celebration_rounded,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Kutlu Olsun!',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Progress bar at bottom
                    if (!isPastView)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: event.progress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isToday
                                      ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                                      : [const Color(0xFF6C63FF), const Color(0xFF4ECDC4)],
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownWidget(EventModel event, bool isToday, bool isPast) {
    final days = event.daysRemaining;
    const shadowList = [
      Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
    ];

    // D-Day: "Bugün!" + kutlama emojisi
    if (isToday) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bugün!',
            style: GoogleFonts.poppins(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFFFD700),
              height: 1.0,
              shadows: shadowList,
            ),
          ),
          const SizedBox(height: 4),
          const Text('🎉🥳', style: TextStyle(fontSize: 24)),
        ],
      );
    }

    // 1 günden az kaldıysa saat:dakika göster
    if (days == 0 && !event.isExpired) {
      final remaining = event.remaining;
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.0,
              shadows: shadowList,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'saat',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      );
    }

    // Geçmiş veya gelecek: sayı + "gün" / "gün önce"
    final absDay = days.abs();
    final label = isPastView ? 'gün önce' : 'gün';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$absDay',
          style: GoogleFonts.poppins(
            fontSize: 56,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.0,
            shadows: shadowList,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryIcon(String? iconPath, String category) {
    return Container(
      width: 36,
      height: 36,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: iconPath != null
          ? Image.asset(
              iconPath,
              width: 24,
              height: 24,
              color: Colors.white,
              errorBuilder: (_, _, _) => Icon(
                AppTheme.getFallbackIconForCategory(category),
                color: Colors.white,
                size: 20,
              ),
            )
          : Icon(
              AppTheme.getFallbackIconForCategory(category),
              color: Colors.white,
              size: 20,
            ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
