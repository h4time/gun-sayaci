import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/event_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/countdown_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_event_screen.dart';
import 'event_detail_screen.dart';
import 'about_screen.dart';
import 'support_screen.dart';
import 'suggestions_screen.dart';
import 'preferences_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  String _selectedCategory = 'Tümü';
  int _selectedTab = 1; // 0=Geçmiş, 1=Yaklaşan
  bool _imagesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      for (final path in AppTheme.categoryImages.values) {
        precacheImage(AssetImage(path), context);
      }
    }
  }

  final List<String> _filters = [
    'Tümü',
    'Doğum Günü',
    'Tatil',
    'Düğün/Yıldönümü',
    'Sınav/İş',
    'Seyahat',
    'Diğer',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(isDark),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: _storageService.box.listenable(),
                    builder: (context, Box<EventModel> box, _) {
                      var allEvents = _storageService.getAllEvents();

                      if (_selectedCategory != 'Tümü') {
                        allEvents = allEvents
                            .where((e) => e.category == _selectedCategory)
                            .toList();
                      }

                      final upcoming = allEvents
                          .where((e) => !e.isExpired || e.isToday)
                          .toList();
                      final past = allEvents
                          .where((e) => e.isExpired && !e.isToday)
                          .toList()
                        ..sort(
                            (a, b) => b.targetDate.compareTo(a.targetDate));

                      final events = _selectedTab == 1 ? upcoming : past;
                      final isPast = _selectedTab == 0;

                      if (events.isEmpty) {
                        return _buildEmptyState(isDark, isPast);
                      }

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8, bottom: 120),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Dismissible(
                            key: Key(event.id),
                            direction: DismissDirection.horizontal,
                            confirmDismiss: (direction) async {
                              if (direction ==
                                  DismissDirection.endToStart) {
                                // Left swipe → delete with confirm
                                HapticFeedback.mediumImpact();
                                return await _showDeleteConfirm(event);
                              } else {
                                // Right swipe → edit
                                HapticFeedback.mediumImpact();
                                _showEditEventSheet(event);
                                return false;
                              }
                            },
                            onDismissed: (_) => _deleteEvent(event),
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 32),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007AFF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.edit_rounded,
                                  color: Colors.white, size: 24),
                            ),
                            secondaryBackground: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 32),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF3B30),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.delete_rounded,
                                  color: Colors.white, size: 24),
                            ),
                            child: CountdownCard(
                              event: event,
                              onTap: () => _navigateToDetail(event),
                              onDelete: () => _deleteEvent(event),
                              onEdit: () => _showEditEventSheet(event),
                              isPastView: isPast,
                            ),
                          ).animate().fadeIn(
                                duration: 400.ms,
                                delay: (index * 60).ms,
                              );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            // Floating bottom toggle
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(child: _buildFloatingToggle(isDark)),
            ),
          ],
        ),
      ),
    );
  }

  // === HEADER ===
  Widget _buildHeader(bool isDark) {
    final bgColor = isDark ? AppTheme.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.1) : AppTheme.cardBorder;
    final shadowColor =
        isDark ? Colors.black.withValues(alpha: 0.3) : AppTheme.buttonShadow;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          // Hamburger button — 3 lines
          _buildCircleButton(
            isDark: isDark,
            bgColor: bgColor,
            borderColor: borderColor,
            shadowColor: shadowColor,
            onTap: () {
              HapticFeedback.lightImpact();
              _openSettingsPage();
            },
            child: SizedBox(
              width: 18,
              height: 14,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (_) => Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    color: textColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                )),
              ),
            ),
          ),

          const Spacer(),

          // Center pill — "#ozelgunleriunutma"
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showCategorySheet(isDark);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _selectedCategory == 'Tümü'
                    ? '#ozelgunleriunutma'
                    : _selectedCategory,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: textColor,
                ),
              ),
            ),
          ),

          const Spacer(),

          // Plus button — thin icon
          _buildCircleButton(
            isDark: isDark,
            bgColor: bgColor,
            borderColor: borderColor,
            shadowColor: shadowColor,
            onTap: () {
              HapticFeedback.lightImpact();
              _showAddEventSheet();
            },
            child: Icon(
              Icons.add,
              size: 22,
              color: textColor,
              weight: 100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required bool isDark,
    required Color bgColor,
    required Color borderColor,
    required Color shadowColor,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  // === FLOATING TOGGLE ===
  Widget _buildFloatingToggle(bool isDark) {
    final bgColor = isDark ? AppTheme.surfaceDark : Colors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.1) : AppTheme.cardBorder;
    final shadowColor =
        isDark ? Colors.black.withValues(alpha: 0.3) : AppTheme.buttonShadow;
    final selectedText = isDark ? Colors.white : Colors.white;
    final selectedBg =
        isDark ? Colors.white.withValues(alpha: 0.15) : AppTheme.primaryText;
    final unselectedText =
        isDark ? Colors.grey[500]! : AppTheme.secondaryText;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            label: 'Geçmiş',
            isSelected: _selectedTab == 0,
            selectedBg: selectedBg,
            selectedText: selectedText,
            unselectedText: unselectedText,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedTab = 0);
            },
          ),
          _buildToggleOption(
            label: 'Yaklaşan',
            isSelected: _selectedTab == 1,
            selectedBg: selectedBg,
            selectedText: selectedText,
            unselectedText: unselectedText,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedTab = 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required bool isSelected,
    required Color selectedBg,
    required Color selectedText,
    required Color unselectedText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: isSelected ? selectedText : unselectedText,
          ),
        ),
      ),
    );
  }

  // === CATEGORY BOTTOM SHEET ===
  void _showCategorySheet(bool isDark) {
    HapticFeedback.selectionClick();
    final bgColor = isDark ? AppTheme.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final secondaryColor =
        isDark ? Colors.grey[400]! : AppTheme.secondaryText;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Kategori Seçin',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              ..._filters.map((filter) {
                final isSelected = filter == _selectedCategory;
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24),
                  leading: Icon(
                    filter == 'Tümü'
                        ? Icons.grid_view_rounded
                        : AppTheme.getFallbackIconForCategory(filter),
                    color: isSelected ? AppTheme.accent : secondaryColor,
                    size: 22,
                  ),
                  title: Text(
                    filter == 'Tümü' ? 'Tüm Etkinlikler' : filter,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? textColor : secondaryColor,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded,
                          color: AppTheme.accent, size: 22)
                      : null,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = filter);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // === FULL-PAGE SETTINGS (Days style) ===
  void _openSettingsPage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F0);
    final cardBg = isDark ? AppTheme.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final secondaryColor =
        isDark ? Colors.grey[400]! : AppTheme.secondaryText;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return Scaffold(
            backgroundColor: pageBg,
            body: SafeArea(
              child: Column(
                children: [
                  // Header: X button + "Ayarlar" title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      children: [
                        // Close button (dark circle with X)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : AppTheme.primaryText,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 22,
                              color: isDark ? Colors.white : Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Ayarlar',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 44), // balance
                      ],
                    ),
                  ),

                  // Menu items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildSettingsCard(
                          icon: Icons.tune_rounded,
                          label: 'Tercihler',
                          cardBg: cardBg,
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const PreferencesScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSettingsCard(
                          icon: Icons.star_outline_rounded,
                          label: 'Uygulamayı Değerlendir',
                          cardBg: cardBg,
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          onTap: () {
                            // Placeholder — gerçek store ID eklenecek
                            launchUrl(Uri.parse(
                                'https://apps.apple.com/app/id0000000000'));
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSettingsCard(
                          icon: Icons.help_outline_rounded,
                          label: 'Destek',
                          cardBg: cardBg,
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SupportScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSettingsCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Öneriler',
                          cardBg: cardBg,
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const SuggestionsScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSettingsCard(
                          icon: Icons.info_outline_rounded,
                          label: 'Hakkında',
                          cardBg: cardBg,
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AboutScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: Text(
                            'v1.0.0',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          return SlideTransition(position: slide, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String label,
    required Color cardBg,
    required Color textColor,
    required Color secondaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: secondaryColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: secondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  // === DELETE CONFIRM ===
  Future<bool> _showDeleteConfirm(EventModel event) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Etkinliği Sil',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.primaryText,
            ),
          ),
          content: Text(
            '"${event.title}" etkinliğini silmek istediğine emin misin?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : AppTheme.secondaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Vazgeç',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : AppTheme.secondaryText,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.heavyImpact();
                Navigator.pop(ctx, true);
              },
              child: Text(
                'Sil',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF3B30),
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  // === EMPTY STATE ===
  Widget _buildEmptyState(bool isDark, bool isPast) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPast
                  ? Icons.hourglass_empty_rounded
                  : Icons.calendar_today_outlined,
              size: 64,
              color: isDark ? Colors.grey[700] : const Color(0xFFD1D1D6),
            ),
            const SizedBox(height: 16),
            Text(
              isPast ? 'Geçmiş etkinlik yok' : 'Henüz etkinlik yok',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[500] : AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isPast
                  ? 'Tamamlanan etkinlikler burada görünecek'
                  : 'İlk geri sayımını başlat',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark
                    ? Colors.grey[600]
                    : const Color(0xFFAEAEB2),
              ),
            ),
            if (!isPast) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showAddEventSheet();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppTheme.primaryText,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Ekle',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // === NAVIGATION ===
  void _navigateToDetail(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
    );
  }

  void _showAddEventSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEventSheet()),
    );
  }

  void _showEditEventSheet(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEventSheet(event: event)),
    );
  }

  void _deleteEvent(EventModel event) {
    _storageService.deleteEvent(event.id);
    NotificationService().cancelEventNotification(event.id);
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${event.title}" silindi',
          style: GoogleFonts.poppins(),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () {
            _storageService.addEvent(event);
            if (event.notificationEnabled) {
              NotificationService().scheduleEventNotification(event);
            }
          },
        ),
      ),
    );
  }
}
