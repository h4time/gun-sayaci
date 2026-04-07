import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _cardSize = 'large';

  @override
  void initState() {
    super.initState();
    _loadCardSize();
  }

  Future<void> _loadCardSize() async {
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getString('eventCardSize') ?? 'large';
    if (mounted && size != _cardSize) setState(() => _cardSize = size);
  }

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
    'Konser/Etkinlik',
    'Spor/Hedef',
    'Diğer',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: _storageService.box.listenable(),
              builder: (context, Box<EventModel> box, _) {
                var allEvents = _storageService.getAllEvents();

                if (_selectedCategory == 'Diğer') {
                  allEvents = allEvents
                      .where((e) => EventModel.isCustomCategory(e.category))
                      .toList();
                } else if (_selectedCategory != 'Tümü') {
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

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header — part of scroll content
                    SliverToBoxAdapter(
                      child: _buildHeader(isDark),
                    ),

                    if (events.isEmpty && isPast)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(isDark, isPast),
                      )
                    else if (events.isEmpty && !isPast)
                      SliverToBoxAdapter(
                        child: _buildEmptyState(isDark, isPast),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 64),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final event = events[index];
                              return Dismissible(
                                key: Key(event.id),
                                direction: DismissDirection.horizontal,
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.endToStart) {
                                    HapticFeedback.mediumImpact();
                                    return await _showDeleteConfirm(
                                        event);
                                  } else {
                                    HapticFeedback.mediumImpact();
                                    _showEditEventSheet(event);
                                    return false;
                                  }
                                },
                                onDismissed: (_) => _deleteEvent(event),
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  padding:
                                      const EdgeInsets.only(left: 32),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF007AFF),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.edit_rounded,
                                      color: Colors.white, size: 24),
                                ),
                                secondaryBackground: Container(
                                  alignment: Alignment.centerRight,
                                  padding:
                                      const EdgeInsets.only(right: 32),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF3B30),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                      Icons.delete_rounded,
                                      color: Colors.white,
                                      size: 24),
                                ),
                                child: CountdownCard(
                                  event: event,
                                  onTap: () =>
                                      _navigateToDetail(event),
                                  onDelete: () =>
                                      _deleteEvent(event),
                                  onEdit: () =>
                                      _showEditEventSheet(event),
                                  isPastView: isPast,
                                  cardSize: _cardSize,
                                ),
                              ).animate().fadeIn(
                                    duration: 400.ms,
                                    delay: (index * 60).ms,
                                  );
                            },
                            childCount: events.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            // Floating bottom toggle
            Positioned(
              bottom: 16,
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          // Hamburger button
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

          // Center pill
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
                    ? 'Tüm Etkinlikler'
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

          // Plus button
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

  // === FLOATING TOGGLE (Days style — semi-transparent pill) ===
  Widget _buildFloatingToggle(bool isDark) {
    final selectedBg =
        isDark ? Colors.white.withValues(alpha: 0.18) : AppTheme.primaryText;
    final selectedText = Colors.white;
    final unselectedText =
        isDark ? Colors.grey[500]! : AppTheme.secondaryText;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.65)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(28),
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

  // === CATEGORY FULL PAGE (Days style) ===
  void _showCategorySheet(bool isDark) {
    HapticFeedback.selectionClick();

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          final pageBg =
              isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F0);
          final cardBg = isDark ? AppTheme.surfaceDark : Colors.white;
          final textColor = isDark ? Colors.white : AppTheme.primaryText;
          final secondaryColor =
              isDark ? Colors.grey[400]! : AppTheme.secondaryText;
          final pillBg = isDark
              ? Colors.white.withValues(alpha: 0.12)
              : AppTheme.primaryText;

          return Scaffold(
            backgroundColor: pageBg,
            body: SafeArea(
              child: Column(
                children: [
                  // Header: X + "Kategori Seçin" pill + "+"
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                              color: pillBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 22, color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        // "Kategori Seçin" dark pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: pillBg,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'Kategori Seçin',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // + button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                            _showAddEventSheet();
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: pillBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add,
                                size: 22, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final isSelected = filter == _selectedCategory;
                        final label = filter == 'Tümü'
                            ? 'Tüm Etkinlikler'
                            : filter;

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(
                                () => _selectedCategory = filter);
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? cardBg
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            child: Text(
                              label,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? textColor
                                    : secondaryColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      ),
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
                            launchUrl(
                              Uri.parse('https://apps.apple.com/app/6761291978?action=write-review'),
                              mode: LaunchMode.externalApplication,
                            );
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
    ).then((_) {
      _resetCategory();
      _loadCardSize();
    });
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
            Icon(icon, size: 22, color: textColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
    HapticFeedback.mediumImpact();
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, anim, secondAnim, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim, secondAnim) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
        final textColor = isDark ? Colors.white : AppTheme.primaryText;
        final subColor =
            isDark ? Colors.grey[400]! : AppTheme.secondaryText;

        return Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: MediaQuery.of(context).size.width - 64,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFFF3B30),
                        size: 26,
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.0, 0.0),
                          end: const Offset(1.0, 1.0),
                          duration: 350.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 200.ms),

                    const SizedBox(height: 16),

                    Text(
                      'Etkinliği Sil',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: subColor,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: '"'),
                          TextSpan(
                            text: event.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const TextSpan(
                              text:
                                  '" etkinliğini silmek istediğine emin misin?'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        // Vazgeç — outlined
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context, false);
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.grey[700]!
                                      : const Color(0xFFE5E5EA),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Vazgeç',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: subColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Sil — red filled
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              Navigator.pop(context, true);
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF3B30),
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  'Sil',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  // === EMPTY STATE ===
  Widget _buildEmptyState(bool isDark, bool isPast) {
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final secondaryColor =
        isDark ? Colors.grey[500]! : AppTheme.secondaryText;

    if (isPast) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_empty_rounded,
                size: 64,
                color: isDark ? Colors.grey[700] : const Color(0xFFD1D1D6),
              ),
              const SizedBox(height: 16),
              Text(
                'Geçmiş etkinlik yok',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: secondaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tamamlanan etkinlikler burada görünecek',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.grey[600] : const Color(0xFFAEAEB2),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    return Column(
      children: [
        const SizedBox(height: 24),

        // Staggered sample cards
        ClipRect(
          child: Column(
            children: [
              // Row 1 — shifted left
              Transform.translate(
                offset: const Offset(-20, 0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width + 40,
                  height: 220,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _sampleCard('assets/images/birthday.jpg',
                            '28 GÜN SONRA', 'Doğum Günü', 200,
                            showText: false),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _sampleCard('assets/images/travel.jpg',
                            '3 GÜN SONRA', 'Tatil', 160),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: _sampleCard('assets/images/seyahat.jpg',
                            '16 HAFTA SONRA', 'Seyahat', 220),
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
                  width: MediaQuery.of(context).size.width + 40,
                  height: 180,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _sampleCard(
                            'assets/images/celebration.jpg',
                            'YARIN',
                            'Yıldönümü',
                            180),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _sampleCard('assets/images/spor.jpg',
                            '3 SAAT SONRA', 'Antrenman', 160,
                            showText: false),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: _sampleCard('assets/images/concert.jpg',
                            '1 AY SONRA', 'Konser', 180),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),

        Text(
          'Özel günlerini ekle',
          style: TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          'Önemli anlarını takip etmeye başla',
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            _showAddEventSheet();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 36, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Text(
              'Özel Gün Ekle',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _sampleCard(
      String image, String countdown, String title, double height,
      {bool showText = true}) {
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
            if (showText) Positioned(
              bottom: 12,
              left: 10,
              right: 10,
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
          ],
        ),
      ),
    );
  }

  // === NAVIGATION ===
  void _resetCategory() {
    if (mounted) setState(() => _selectedCategory = 'Tümü');
  }

  void _navigateToDetail(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
    ).then((_) => _resetCategory());
  }

  void _showAddEventSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEventSheet()),
    ).then((_) => _resetCategory());
  }

  void _showEditEventSheet(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEventSheet(event: event)),
    ).then((_) => _resetCategory());
  }

  void _deleteEvent(EventModel event) {
    _storageService.deleteEvent(event.id);
    NotificationService().cancelEventNotification(event.id);
    HapticFeedback.mediumImpact();
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '"${event.title}" silindi',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xE61C1C1E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        dismissDirection: DismissDirection.horizontal,
        action: SnackBarAction(
          label: 'Geri Al',
          textColor: AppTheme.accent,
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
