import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/countdown_card.dart';
import 'add_event_screen.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  String _selectedCategory = 'Tümü';
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  late TabController _tabController;

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
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final dateStr = DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(now);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _isSearching
                        ? TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: GoogleFonts.poppins(fontSize: 16),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Etkinlik ara...',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey[400],
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gün Sayacı',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : Colors.grey[900],
                                ),
                              ),
                              Text(
                                dateStr,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchQuery = '';
                          _searchController.clear();
                        }
                      });
                    },
                    icon: Icon(
                      _isSearching ? Icons.close_rounded : Icons.search_rounded,
                      size: 26,
                    ),
                  ),
                  IconButton(
                    onPressed: () => themeProvider.toggleTheme(),
                    tooltip: themeProvider.themeModeLabel,
                    icon: Icon(
                      themeProvider.themeModeIcon,
                      color: isDark ? Colors.amber : Colors.indigo,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 12),

            // Tabs: Yaklaşan / Geçmiş
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Yaklaşan'),
                Tab(text: 'Geçmiş'),
              ],
              labelStyle: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            // Category filter chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedCategory;
                  final icon = filter == 'Tümü'
                      ? Icons.grid_view_rounded
                      : AppTheme.getFallbackIconForCategory(filter);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF6C63FF),
                                    Color(0xFF4ECDC4),
                                  ],
                                )
                              : null,
                          color: isSelected
                              ? null
                              : (isDark ? Colors.grey[800] : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: isDark
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!,
                                ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF6C63FF)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600]),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              filter,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Events list with tabs
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _storageService.box.listenable(),
                builder: (context, Box<EventModel> box, _) {
                  var allEvents = _storageService.getAllEvents();

                  // Apply category filter
                  if (_selectedCategory != 'Tümü') {
                    allEvents = allEvents
                        .where((e) => e.category == _selectedCategory)
                        .toList();
                  }

                  // Apply search filter
                  if (_searchQuery.isNotEmpty) {
                    allEvents = allEvents
                        .where((e) => e.title
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();
                  }

                  // Split into upcoming and past
                  final upcoming = allEvents
                      .where((e) => !e.isExpired || e.isToday)
                      .toList();
                  final past = allEvents
                      .where((e) => e.isExpired && !e.isToday)
                      .toList()
                    ..sort(
                        (a, b) => b.targetDate.compareTo(a.targetDate));

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEventList(upcoming, false, isDark),
                      _buildEventList(past, true, isDark),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildEventList(
      List<EventModel> events, bool isPast, bool isDark) {
    if (events.isEmpty) {
      return _buildEmptyState(isDark, isPast);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 100),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return CountdownCard(
          event: event,
          onTap: () => _navigateToDetail(event),
          onDelete: () => _deleteEvent(event),
          onEdit: () => _showEditEventSheet(event),
          isPastView: isPast,
        ).animate().fadeIn(
              duration: 400.ms,
              delay: (index * 60).ms,
            );
      },
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _showAddEventSheet,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: Text(
          'Yeni Etkinlik',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.03, 1.03),
          duration: 1500.ms,
          curve: Curves.easeInOut,
        )
        .animate()
        .scale(delay: 300.ms, duration: 300.ms);
  }

  Widget _buildEmptyState(bool isDark, bool isPast) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPast ? Icons.history_rounded : Icons.event_note_rounded,
            size: 72,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isPast
                ? 'Geçmiş etkinlik bulunmuyor'
                : 'Henüz etkinlik eklenmemiş',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          if (!isPast) ...[
            const SizedBox(height: 8),
            Text(
              'Aşağıdaki butona basarak\nilk etkinliğini ekle!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  void _navigateToDetail(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
    );
  }

  void _showAddEventSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddEventSheet(),
    );
  }

  void _showEditEventSheet(EventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEventSheet(event: event),
    );
  }

  void _deleteEvent(EventModel event) {
    _storageService.deleteEvent(event.id);
    NotificationService().cancelEventNotification(event.id);
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
