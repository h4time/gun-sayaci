import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';
import 'event_size_screen.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _storageService = StorageService();
  bool _isLoading = false;
  int _notifHour = 9;
  int _notifMinute = 0;
  String _cardSize = 'large';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final (hour, minute) = await NotificationService().getNotificationTime();
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getString('eventCardSize') ?? 'large';
    if (mounted) {
      setState(() {
        _notifHour = hour;
        _notifMinute = minute;
        _cardSize = size;
      });
    }
  }

  String get _timeLabel =>
      '${_notifHour.toString().padLeft(2, '0')}:${_notifMinute.toString().padLeft(2, '0')}';

  String get _sizeLabelTr {
    switch (_cardSize) {
      case 'small':
        return 'Küçük';
      case 'medium':
        return 'Orta';
      default:
        return 'Büyük';
    }
  }

  // === NOTIFICATION TIME PICKER ===
  void _showTimePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    int tempHour = _notifHour;
    int tempMinute = _notifMinute;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
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
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bildirim Zamanı',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: DateTime(2024, 1, 1, _notifHour, _notifMinute),
                  onDateTimeChanged: (dt) {
                    HapticFeedback.selectionClick();
                    tempHour = dt.hour;
                    tempMinute = dt.minute;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    Navigator.pop(ctx);
                    setState(() {
                      _notifHour = tempHour;
                      _notifMinute = tempMinute;
                    });
                    final ns = NotificationService();
                    await ns.setNotificationTime(tempHour, tempMinute);
                    // Reschedule all notifications with new time
                    final events = _storageService.getAllEvents();
                    await ns.rescheduleAll(events);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryText,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'Kaydet',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
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
        );
      },
    );
  }

  // === BACKUP ===
  Future<void> _backupData() async {
    final events = _storageService.getAllEvents();
    if (events.isEmpty) {
      if (!mounted) return;
      _showSnackBar('Yedeklenecek etkinlik yok');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final eventList = events.map((e) => {
        'id': e.id,
        'title': e.title,
        'date': e.targetDate.toIso8601String(),
        'category': e.category,
        'emoji': e.emoji,
        'gradientIndex': e.gradientIndex,
        'notificationEnabled': e.notificationEnabled,
        'reminderEventDay': e.reminderEventDay,
        'reminder1Day': e.reminder1Day,
        'reminder3Days': e.reminder3Days,
        'reminder1Week': e.reminder1Week,
        'reminder1Month': e.reminder1Month,
        'createdAt': e.createdAt.toIso8601String(),
      }).toList();

      final backup = {
        'version': '1.1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'events': eventList,
      };

      final jsonStr = const JsonEncoder.withIndent('  ').convert(backup);
      final now = DateTime.now();
      final fileName =
          'gun_sayaci_yedek_${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.json';

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonStr);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Gün Sayacı Yedek',
      );

      if (!mounted) return;
      _showSnackBar('${events.length} etkinlik yedeklendi');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Yedekleme başarısız');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // === RESTORE ===
  Future<void> _restoreData() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await _showConfirmDialog(
      title: 'Geri Yükle',
      message:
          'Mevcut verileriniz silinecek ve yedekten geri yüklenecek.\nDevam etmek istiyor musunuz?',
      confirmLabel: 'Geri Yükle',
      confirmColor: AppTheme.accent,
      isDark: isDark,
    );

    if (confirmed != true) return;

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() => _isLoading = true);

    try {
      final file = File(result.files.single.path!);
      final jsonStr = await file.readAsString();
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      if (!data.containsKey('events') || data['events'] is! List) {
        if (!mounted) return;
        _showSnackBar('Bu dosya geçerli bir yedek dosyası değil');
        return;
      }

      final eventList = data['events'] as List;
      if (eventList.isEmpty) {
        if (!mounted) return;
        _showSnackBar('Yedek dosyası boş');
        return;
      }

      // Clear existing data
      await _storageService.clearAll();
      await NotificationService().cancelAll();

      // Restore events
      int restored = 0;
      for (final item in eventList) {
        try {
          final m = item as Map<String, dynamic>;
          final event = EventModel(
            id: m['id'] as String,
            title: m['title'] as String,
            targetDate: DateTime.parse(m['date'] as String),
            category: m['category'] as String,
            emoji: (m['emoji'] as String?) ?? '🎉',
            gradientIndex: (m['gradientIndex'] as int?) ?? 0,
            notificationEnabled:
                (m['notificationEnabled'] as bool?) ?? true,
            reminderEventDay:
                (m['reminderEventDay'] as bool?) ?? true,
            reminder1Day: (m['reminder1Day'] as bool?) ?? false,
            reminder3Days: (m['reminder3Days'] as bool?) ?? false,
            reminder1Week: (m['reminder1Week'] as bool?) ?? false,
            reminder1Month: (m['reminder1Month'] as bool?) ?? false,
            createdAt: m['createdAt'] != null
                ? DateTime.parse(m['createdAt'] as String)
                : null,
          );
          await _storageService.addEvent(event);
          if (event.notificationEnabled) {
            await NotificationService()
                .scheduleEventNotification(event);
          }
          restored++;
        } catch (_) {
          // Skip invalid entries
        }
      }

      if (!mounted) return;

      _showSnackBar('$restored etkinlik başarıyla geri yüklendi');

      // Pop back to home
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Geri yükleme başarısız: Geçersiz dosya formatı');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // === DELETE ALL ===
  Future<void> _deleteAllData() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await _showConfirmDialog(
      title: 'Tüm Verileri Sil',
      message:
          'Bu işlem geri alınamaz.\nTüm etkinlikleriniz kalıcı olarak silinecektir.',
      confirmLabel: 'Tüm Verileri Sil',
      confirmColor: const Color(0xFFFF3B30),
      isDark: isDark,
      isDestructive: true,
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    HapticFeedback.heavyImpact();

    await _storageService.clearAll();
    await NotificationService().cancelAll();

    if (!mounted) return;
    setState(() => _isLoading = false);

    _showSnackBar('Tüm veriler silindi');

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
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
      ),
    );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required bool isDark,
    bool isDestructive = false,
  }) {
    HapticFeedback.mediumImpact();
    return showGeneralDialog<bool>(
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
              CurvedAnimation(
                  parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim, secondAnim) {
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
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: (isDestructive
                                ? const Color(0xFFFF3B30)
                                : AppTheme.accent)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDestructive
                            ? Icons.warning_amber_rounded
                            : Icons.cloud_download_outlined,
                        color: isDestructive
                            ? const Color(0xFFFF3B30)
                            : AppTheme.accent,
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
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: subColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
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
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              Navigator.pop(context, true);
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: confirmColor,
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  confirmLabel,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF5F5F0);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final secondaryColor =
        isDark ? Colors.grey[400]! : AppTheme.secondaryText;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: textColor),
                      ),
                      const Spacer(),
                      Text(
                        'Tercihler',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    children: [
                      _sectionTitle('GÖRÜNÜM', secondaryColor),
                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.dark_mode_outlined,
                                size: 22, color: secondaryColor),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Gece Modu',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ),
                            CupertinoSwitch(
                              value: themeProvider.isDarkMode,
                              onChanged: (v) {
                                HapticFeedback.selectionClick();
                                themeProvider.toggleTheme();
                              },
                              activeTrackColor: AppTheme.accent,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      _settingsCard(
                        icon: Icons.aspect_ratio_rounded,
                        label: 'Etkinlik Boyutu',
                        trailing: Text(
                          _sizeLabelTr,
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: secondaryColor),
                        ),
                        cardBg: cardBg,
                        textColor: textColor,
                        secondaryColor: secondaryColor,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EventSizeScreen()),
                          );
                          _loadPrefs();
                        },
                      ),

                      const SizedBox(height: 24),

                      _sectionTitle('BİLDİRİMLER', secondaryColor),
                      const SizedBox(height: 8),

                      _settingsCard(
                        icon: Icons.access_time_rounded,
                        label: 'Bildirim Zamanı',
                        trailing: Text(
                          _timeLabel,
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: secondaryColor),
                        ),
                        cardBg: cardBg,
                        textColor: textColor,
                        secondaryColor: secondaryColor,
                        onTap: _showTimePicker,
                      ),

                      const SizedBox(height: 24),

                      _sectionTitle('VERİ', secondaryColor),
                      const SizedBox(height: 8),

                      _settingsCard(
                        icon: Icons.cloud_upload_outlined,
                        label: 'Verileri Yedekle',
                        cardBg: cardBg,
                        textColor: textColor,
                        secondaryColor: secondaryColor,
                        onTap: _backupData,
                      ),
                      const SizedBox(height: 8),
                      _settingsCard(
                        icon: Icons.cloud_download_outlined,
                        label: 'Verileri Geri Yükle',
                        cardBg: cardBg,
                        textColor: textColor,
                        secondaryColor: secondaryColor,
                        onTap: _restoreData,
                      ),
                      const SizedBox(height: 8),

                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _deleteAllData();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.delete_forever_rounded,
                                  size: 22, color: Color(0xFFFF3B30)),
                              const SizedBox(width: 14),
                              Text(
                                'Tüm Verileri Sil',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFFF3B30),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Loading overlay
        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accent,
              ),
            ),
          ),
      ],
    );
  }

  Widget _sectionTitle(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _settingsCard({
    required IconData icon,
    required String label,
    Widget? trailing,
    required Color cardBg,
    required Color textColor,
    required Color secondaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
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
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    size: 22, color: secondaryColor),
          ],
        ),
      ),
    );
  }
}
