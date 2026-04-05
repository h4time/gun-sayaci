import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

// Category colors shared across wizard
const Map<String, Color> kCategoryColors = {
  'Doğum Günü': Color(0xFFFF4B77),
  'Tatil': Color(0xFF2EC4B6),
  'Düğün/Yıldönümü': Color(0xFFFF6B9D),
  'Sınav/İş': Color(0xFFF5A623),
  'Seyahat': Color(0xFF8B5CF6),
  'Konser/Etkinlik': Color(0xFF6C5CE7),
  'Spor/Hedef': Color(0xFF4CAF50),
  '+ Özel': Color(0xFF8E8E93),
};

const Map<String, String> kCategoryEmojis = {
  'Doğum Günü': '🎂',
  'Tatil': '✈️',
  'Düğün/Yıldönümü': '💍',
  'Sınav/İş': '💼',
  'Seyahat': '🧳',
  'Konser/Etkinlik': '🎵',
  'Spor/Hedef': '🏆',
  '+ Özel': '✏️',
};

// Pastel backgrounds & text colors for wizard category cards
const Map<String, Color> kCatBgLight = {
  'Doğum Günü': Color(0xFFFCEBEB),
  'Tatil': Color(0xFFE6F1FB),
  'Düğün/Yıldönümü': Color(0xFFFBEAF0),
  'Sınav/İş': Color(0xFFFAEEDA),
  'Seyahat': Color(0xFFE1F5EE),
  'Konser/Etkinlik': Color(0xFFEEEDFE),
  'Spor/Hedef': Color(0xFFEAF3DE),
  '+ Özel': Color(0xFFF1EFE8),
};
const Map<String, Color> kCatTextLight = {
  'Doğum Günü': Color(0xFF791F1F),
  'Tatil': Color(0xFF0C447C),
  'Düğün/Yıldönümü': Color(0xFF72243E),
  'Sınav/İş': Color(0xFF633806),
  'Seyahat': Color(0xFF085041),
  'Konser/Etkinlik': Color(0xFF3C3489),
  'Spor/Hedef': Color(0xFF27500A),
  '+ Özel': Color(0xFF444441),
};
const Map<String, Color> kCatBgDark = {
  'Doğum Günü': Color(0xFF501313),
  'Tatil': Color(0xFF042C53),
  'Düğün/Yıldönümü': Color(0xFF4B1528),
  'Sınav/İş': Color(0xFF412402),
  'Seyahat': Color(0xFF04342C),
  'Konser/Etkinlik': Color(0xFF26215C),
  'Spor/Hedef': Color(0xFF173404),
  '+ Özel': Color(0xFF2C2C2A),
};
const Map<String, Color> kCatTextDark = {
  'Doğum Günü': Color(0xFFF7C1C1),
  'Tatil': Color(0xFFB5D4F4),
  'Düğün/Yıldönümü': Color(0xFFF4C0D1),
  'Sınav/İş': Color(0xFFFAC775),
  'Seyahat': Color(0xFF9FE1CB),
  'Konser/Etkinlik': Color(0xFFCECBF6),
  'Spor/Hedef': Color(0xFFC0DD97),
  '+ Özel': Color(0xFFD3D1C7),
};

/// Entry point
class AddEventSheet extends StatelessWidget {
  final EventModel? event;
  const AddEventSheet({super.key, this.event});

  @override
  Widget build(BuildContext context) {
    if (event != null) return _EditEventPage(event: event!);
    return const _WizardStep1();
  }
}

// ============================================================
// STEP 1 — Name + Category Grid
// ============================================================
class _WizardStep1 extends StatefulWidget {
  const _WizardStep1();
  @override
  State<_WizardStep1> createState() => _WizardStep1State();
}

class _WizardStep1State extends State<_WizardStep1> {
  final _controller = TextEditingController();
  static const int _maxLen = 25;
  String? _selectedCat;
  String? _customCatName;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isCustomSelected =>
      _selectedCat != null &&
      !EventModel.categories.contains(_selectedCat) &&
      _selectedCat != EventModel.customCategoryKey;

  bool get _canContinue =>
      _controller.text.trim().isNotEmpty &&
      _selectedCat != null &&
      _selectedCat != EventModel.customCategoryKey;

  /// The list shown in the grid: 7 predefined + '+ Özel'
  List<String> get _gridCategories =>
      [...EventModel.categories, EventModel.customCategoryKey];

  void _showCustomCategoryDialog(bool isDark) {
    final dialogController = TextEditingController(text: _customCatName);
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final hintColor = isDark ? Colors.grey[500]! : const Color(0xFFAEAEB2);
    final fieldBg =
        isDark ? const Color(0xFF2C2C2A) : const Color(0xFFF2F2F7);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
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
        return Center(
          child: Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                final text = dialogController.text.trim();
                final canConfirm = text.isNotEmpty;
                return Container(
                  width: MediaQuery.of(context).size.width - 64,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '✏️',
                        style: const TextStyle(fontSize: 36),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Özel Kategori',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: dialogController,
                        maxLength: 20,
                        autofocus: true,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: textColor,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) => setDialogState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Kategori adı girin',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            color: hintColor,
                          ),
                          counterText:
                              '${dialogController.text.length}/20',
                          counterStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            color: hintColor,
                          ),
                          filled: true,
                          fillColor: fieldBg,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppTheme.accent, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: canConfirm
                            ? () {
                                HapticFeedback.lightImpact();
                                final name = dialogController.text.trim();
                                setState(() {
                                  _customCatName = name;
                                  _selectedCat = name;
                                });
                                Navigator.pop(context);
                              }
                            : null,
                        child: AnimatedOpacity(
                          opacity: canConfirm ? 1.0 : 0.4,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryText,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                'Tamam',
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
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final fieldBg =
        isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header — only X
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  _BlackCircle(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),

                    // Big title
                    Text(
                      'Geri sayım\nbaşlasın!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: -0.5,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Input
                    TextField(
                      controller: _controller,
                      maxLength: _maxLen,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: textColor,
                      ),
                      textCapitalization:
                          TextCapitalization.sentences,
                      autocorrect: false,
                      enableSuggestions: true,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Etkinlik adı',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFFAEAEB2),
                        ),
                        prefixIcon: Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: isDark
                              ? Colors.grey[500]
                              : AppTheme.secondaryText,
                        ),
                        counterText: '',
                        suffixText:
                            '${_controller.text.length}/$_maxLen',
                        suffixStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFFAEAEB2),
                        ),
                        filled: true,
                        fillColor: fieldBg,
                        contentPadding:
                            const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                              color: AppTheme.accent, width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Kategori',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? Colors.grey[300]
                              : AppTheme.primaryText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category grid — 2 columns (pastel cards)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.0,
                      children: _gridCategories.map((cat) {
                        final isCustomKey =
                            cat == EventModel.customCategoryKey;
                        final isSelected = isCustomKey
                            ? _isCustomSelected
                            : cat == _selectedCat;
                        final emoji = kCategoryEmojis[cat] ?? '📌';
                        final bg = isDark
                            ? (kCatBgDark[cat] ??
                                const Color(0xFF2C2C2A))
                            : (kCatBgLight[cat] ??
                                const Color(0xFFF1EFE8));
                        final catTextColor = isDark
                            ? (kCatTextDark[cat] ??
                                const Color(0xFFD3D1C7))
                            : (kCatTextLight[cat] ??
                                const Color(0xFF444441));

                        final displayName = isCustomKey && _isCustomSelected
                            ? _customCatName!
                            : cat;

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            if (isCustomKey) {
                              _showCustomCategoryDialog(isDark);
                            } else {
                              setState(() {
                                _selectedCat = cat;
                                _customCatName = null;
                              });
                            }
                          },
                          child: AnimatedScale(
                            scale: isSelected ? 0.97 : 1.0,
                            duration:
                                const Duration(milliseconds: 150),
                            curve: Curves.easeOut,
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius:
                                    BorderRadius.circular(18),
                                border: isSelected
                                    ? Border.all(
                                        color: catTextColor,
                                        width: 2.5)
                                    : null,
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        Text(emoji,
                                            style:
                                                const TextStyle(
                                                    fontSize: 32)),
                                        const SizedBox(height: 4),
                                        Text(
                                          displayName,
                                          style:
                                              GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight:
                                                FontWeight.w500,
                                            color: catTextColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: catTextColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Continue
            _BottomButton(
              label: 'Devam Et',
              enabled: _canContinue,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => _WizardStep2(
                      title: _controller.text.trim(),
                      category: _selectedCat!,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// STEP 2 — Date + Options + Save
// ============================================================
class _WizardStep2 extends StatefulWidget {
  final String title;
  final String category;
  const _WizardStep2({required this.title, required this.category});
  @override
  State<_WizardStep2> createState() => _WizardStep2State();
}

class _WizardStep2State extends State<_WizardStep2> {
  late DateTime _selectedDate;
  late int _viewMonth;
  late int _viewYear;
  String _repeatLabel = 'Asla';
  final _storageService = StorageService();
  bool _slideForward = true;
  int _slideKey = 0;

  static const _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];
  static const _dayNames = [
    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma',
    'Cumartesi', 'Pazar',
  ];
  static const _dayHeaders = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];

  @override
  void initState() {
    super.initState();
    final d = DateTime.now().add(const Duration(days: 7));
    _selectedDate = DateTime(d.year, d.month, d.day);
    _viewMonth = d.month;
    _viewYear = d.year;
  }

  DateTime get _date => _selectedDate;

  int _daysInMonth(int m, int y) => DateTime(y, m + 1, 0).day;

  void _prevMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _slideForward = false;
      _slideKey++;
      if (_viewMonth == 1) {
        _viewMonth = 12;
        _viewYear--;
      } else {
        _viewMonth--;
      }
    });
  }

  void _nextMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _slideForward = true;
      _slideKey++;
      if (_viewMonth == 12) {
        _viewMonth = 1;
        _viewYear++;
      } else {
        _viewMonth++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final secondaryColor =
        isDark ? Colors.grey[400]! : AppTheme.secondaryText;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey.shade200;
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header — back only
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  _BlackCircle(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),

                    // Big title — matches Step 1
                    Text(
                      'Büyük günü\nseç!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: -0.5,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // === Calendar Card ===
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Column(
                        children: [
                          // Month navigation
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _prevMonth,
                                child: Tooltip(
                                  message: 'Önceki ay',
                                  child: Icon(
                                      Icons.chevron_left_rounded,
                                      size: 28,
                                      color: textColor),
                                ),
                              ),
                              const Spacer(),
                              AnimatedSwitcher(
                                duration:
                                    const Duration(milliseconds: 200),
                                transitionBuilder:
                                    (child, animation) {
                                  final offset = _slideForward
                                      ? const Offset(0.3, 0)
                                      : const Offset(-0.3, 0);
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: offset,
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  '${_months[_viewMonth - 1]} $_viewYear',
                                  key: ValueKey(
                                      '$_viewMonth-$_viewYear'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: _nextMonth,
                                child: Tooltip(
                                  message: 'Sonraki ay',
                                  child: Icon(
                                      Icons.chevron_right_rounded,
                                      size: 28,
                                      color: textColor),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Day headers
                          Row(
                            children: _dayHeaders
                                .map((h) => Expanded(
                                      child: Center(
                                        child: Text(
                                          h,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight.w500,
                                            color: secondaryColor,
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),

                          const SizedBox(height: 8),

                          // Day grid with slide animation
                          AnimatedSwitcher(
                            duration:
                                const Duration(milliseconds: 200),
                            transitionBuilder:
                                (child, animation) {
                              final offset = _slideForward
                                  ? const Offset(0.15, 0)
                                  : const Offset(-0.15, 0);
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: offset,
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOut,
                                )),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: _buildDayGrid(
                              key: ValueKey(_slideKey),
                              textColor: textColor,
                              secondaryColor: secondaryColor,
                              today: today,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Selected date summary
                    Text(
                      '${_selectedDate.day} ${_months[_selectedDate.month - 1]} ${_selectedDate.year}, ${_dayNames[_selectedDate.weekday - 1]}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: secondaryColor,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // === Repeat Card ===
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _showRepeatSheet(isDark,
                                textColor, secondaryColor),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 24),
                              child: SizedBox(
                                height: 52,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Tekrarla',
                                        style:
                                            GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _repeatLabel,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: secondaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons
                                          .chevron_right_rounded,
                                      size: 20,
                                      color: secondaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Save
            _BottomButton(
              label: 'Kaydet',
              enabled: true,
              onTap: () {
                HapticFeedback.mediumImpact();
                _save();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayGrid({
    required Key key,
    required Color textColor,
    required Color secondaryColor,
    required DateTime today,
    required bool isDark,
  }) {
    final daysInMonth = _daysInMonth(_viewMonth, _viewYear);
    // weekday: 1=Mon ... 7=Sun
    final firstWeekday = DateTime(_viewYear, _viewMonth, 1).weekday;
    final offset = firstWeekday - 1; // blanks before day 1
    final totalCells = offset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      key: key,
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final cellIndex = row * 7 + col;
            final dayNum = cellIndex - offset + 1;

            if (cellIndex < offset || dayNum > daysInMonth) {
              return const Expanded(child: SizedBox(height: 40));
            }

            final cellDate =
                DateTime(_viewYear, _viewMonth, dayNum);
            final isToday = cellDate.year == today.year &&
                cellDate.month == today.month &&
                cellDate.day == today.day;
            final isSelected =
                cellDate.year == _selectedDate.year &&
                    cellDate.month == _selectedDate.month &&
                    cellDate.day == _selectedDate.day;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedDate = cellDate);
                },
                child: Semantics(
                  label:
                      '$dayNum ${_months[_viewMonth - 1]} $_viewYear, ${_dayNames[cellDate.weekday - 1]}',
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? Colors.white
                              : AppTheme.primaryText)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(
                              color: AppTheme.accent, width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? (isDark
                                  ? Colors.black
                                  : Colors.white)
                              : textColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  void _showRepeatSheet(
      bool isDark, Color textColor, Color secondaryColor) {
    HapticFeedback.selectionClick();
    final options = ['Asla', 'Her Hafta', 'Her Ay', 'Her Yıl'];
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

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
                    'Tekrarlama',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              ...options.map((opt) {
                final isSelected = opt == _repeatLabel;
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24),
                  title: Text(
                    opt,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? textColor : secondaryColor,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded,
                          color: AppTheme.accent, size: 22)
                      : null,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _repeatLabel = opt);
                    Navigator.pop(ctx);
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

  void _save() {
    final event = EventModel(
      id: const Uuid().v4(),
      title: widget.title,
      targetDate: _date,
      category: widget.category,
      notificationEnabled: true,
      reminderEventDay: true,
    );
    _storageService.addEvent(event);
    NotificationService().scheduleEventNotification(event);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

// ============================================================
// EDIT MODE
// ============================================================
class _EditEventPage extends StatefulWidget {
  final EventModel event;
  const _EditEventPage({required this.event});
  @override
  State<_EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<_EditEventPage> {
  late final TextEditingController _titleCtrl;
  late DateTime _date;
  late String _category;
  String? _customCatName;
  late bool _r1d, _r3d, _r1w, _r1m;
  final _storage = StorageService();

  bool get _isCustomCategory => EventModel.isCustomCategory(_category);

  List<String> get _editCategories =>
      [...EventModel.categories, EventModel.customCategoryKey];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.event.title);
    _date = widget.event.targetDate;
    _category = widget.event.category;
    if (EventModel.isCustomCategory(_category)) {
      _customCatName = _category;
    }
    _r1d = widget.event.reminder1Day;
    _r3d = widget.event.reminder3Days;
    _r1w = widget.event.reminder1Week;
    _r1m = widget.event.reminder1Month;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  static const _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];
  static const _dayNames = [
    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma',
    'Cumartesi', 'Pazar',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final secondaryColor =
        isDark ? Colors.grey[400]! : AppTheme.secondaryText;
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final fieldBg =
        isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final dividerColor =
        isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  _BlackCircle(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'Etkinliği Düzenle',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _lbl('Etkinlik Adı', textColor),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleCtrl,
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: textColor),
                      textCapitalization:
                          TextCapitalization.sentences,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: fieldBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _lbl('Tarih', textColor),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final p = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 3650)),
                          locale: const Locale('tr', 'TR'),
                        );
                        if (p != null) setState(() => _date = p);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: fieldBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${_date.day} ${_months[_date.month - 1]} ${_date.year} ${_dayNames[_date.weekday - 1]}',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.chevron_right_rounded,
                                size: 22, color: secondaryColor),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _lbl('Kategori', textColor),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _editCategories.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = _editCategories[i];
                          final isCustomKey =
                              cat == EventModel.customCategoryKey;
                          final sel = isCustomKey
                              ? _isCustomCategory
                              : cat == _category;
                          final emoji =
                              kCategoryEmojis[cat] ?? '📌';
                          final displayName =
                              isCustomKey && _isCustomCategory
                                  ? _customCatName!
                                  : cat;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              if (isCustomKey) {
                                _showEditCustomCategoryDialog(isDark);
                              } else {
                                setState(() {
                                  _category = cat;
                                  _customCatName = null;
                                });
                              }
                            },
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppTheme.primaryText
                                    : cardBg,
                                borderRadius:
                                    BorderRadius.circular(24),
                                border: sel
                                    ? null
                                    : Border.all(
                                        color: isDark
                                            ? Colors.grey[700]!
                                            : AppTheme.cardBorder,
                                        width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(emoji,
                                      style: const TextStyle(
                                          fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(
                                    displayName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: sel
                                          ? Colors.white
                                          : secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    _lbl('Hatırlatmalar', textColor),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: dividerColor),
                      ),
                      child: Column(
                        children: [
                          _switchRow('Etkinlik Günü', true, false,
                              textColor, isDark, (_) {}),
                          _div(dividerColor),
                          _switchRow('1 Gün Önce', _r1d, true,
                              textColor, isDark,
                              (v) => setState(() => _r1d = v)),
                          _div(dividerColor),
                          _switchRow('3 Gün Önce', _r3d, true,
                              textColor, isDark,
                              (v) => setState(() => _r3d = v)),
                          _div(dividerColor),
                          _switchRow('1 Hafta Önce', _r1w, true,
                              textColor, isDark,
                              (v) => setState(() => _r1w = v)),
                          _div(dividerColor),
                          _switchRow('1 Ay Önce', _r1m, true,
                              textColor, isDark,
                              (v) => setState(() => _r1m = v)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            _BottomButton(
              label: 'Güncelle',
              enabled: true,
              onTap: () {
                HapticFeedback.lightImpact();
                _update();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _lbl(String t, Color c) => Text(
        t,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: c,
          letterSpacing: -0.3,
        ),
      );

  Widget _div(Color c) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(height: 1, color: c),
      );

  Widget _switchRow(String label, bool val, bool enabled, Color txtC,
      bool isDark, ValueChanged<bool> cb) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: GoogleFonts.poppins(fontSize: 15, color: txtC)),
          ),
          CupertinoSwitch(
            value: val,
            onChanged: enabled
                ? (v) {
                    HapticFeedback.selectionClick();
                    cb(v);
                  }
                : null,
            activeTrackColor: AppTheme.accent,
          ),
        ],
      ),
    );
  }

  void _showEditCustomCategoryDialog(bool isDark) {
    final dialogController = TextEditingController(text: _customCatName);
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final dlgTextColor = isDark ? Colors.white : AppTheme.primaryText;
    final hintColor = isDark ? Colors.grey[500]! : const Color(0xFFAEAEB2);
    final dlgFieldBg =
        isDark ? const Color(0xFF2C2C2A) : const Color(0xFFF2F2F7);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
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
        return Center(
          child: Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                final text = dialogController.text.trim();
                final canConfirm = text.isNotEmpty;
                return Container(
                  width: MediaQuery.of(context).size.width - 64,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('✏️',
                          style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 12),
                      Text(
                        'Özel Kategori',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: dlgTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: dialogController,
                        maxLength: 20,
                        autofocus: true,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: dlgTextColor,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) => setDialogState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Kategori adı girin',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            color: hintColor,
                          ),
                          counterText:
                              '${dialogController.text.length}/20',
                          counterStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            color: hintColor,
                          ),
                          filled: true,
                          fillColor: dlgFieldBg,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppTheme.accent, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: canConfirm
                            ? () {
                                HapticFeedback.lightImpact();
                                final name =
                                    dialogController.text.trim();
                                setState(() {
                                  _customCatName = name;
                                  _category = name;
                                });
                                Navigator.pop(context);
                              }
                            : null,
                        child: AnimatedOpacity(
                          opacity: canConfirm ? 1.0 : 0.4,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryText,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                'Tamam',
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
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _update() {
    final t = _titleCtrl.text.trim();
    if (t.isEmpty) return;
    final ev = EventModel(
      id: widget.event.id,
      title: t,
      targetDate: _date,
      category: _category,
      notificationEnabled: widget.event.notificationEnabled,
      reminderEventDay: true,
      reminder1Day: _r1d,
      reminder3Days: _r3d,
      reminder1Week: _r1w,
      reminder1Month: _r1m,
      createdAt: widget.event.createdAt,
    );
    _storage.updateEvent(ev);
    NotificationService().scheduleEventNotification(ev);
    Navigator.pop(context);
  }
}

// ============================================================
// SHARED
// ============================================================

class _BlackCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _BlackCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
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
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  const _BottomButton(
      {required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryText,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
