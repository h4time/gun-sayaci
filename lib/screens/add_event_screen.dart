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
  'Diğer': Color(0xFF8E8E93),
};

const Map<String, String> kCategoryEmojis = {
  'Doğum Günü': '🎂',
  'Tatil': '✈️',
  'Düğün/Yıldönümü': '💍',
  'Sınav/İş': '💼',
  'Seyahat': '🧳',
  'Diğer': '•••',
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
  bool _inputFocused = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _controller.text.trim().isNotEmpty && _selectedCat != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final fieldBg =
        isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderDefault =
        isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0x14000000);

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
                    Focus(
                      onFocusChange: (f) =>
                          setState(() => _inputFocused = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 4),
                        decoration: BoxDecoration(
                          color: fieldBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _inputFocused
                                ? AppTheme.accent
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: TextField(
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
                            border: InputBorder.none,
                            counterText: '',
                            suffixText:
                                '${_controller.text.length}/$_maxLen',
                            suffixStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFFAEAEB2),
                            ),
                          ),
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

                    // Category grid — 2 columns
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.0,
                      children: EventModel.categories.map((cat) {
                        final isSelected = cat == _selectedCat;
                        final color = kCategoryColors[cat] ??
                            const Color(0xFF8E8E93);
                        final emoji = kCategoryEmojis[cat] ?? '📌';

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedCat = cat);
                          },
                          child: AnimatedScale(
                            scale: isSelected ? 1.02 : 1.0,
                            duration:
                                const Duration(milliseconds: 200),
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color.withValues(alpha: 0.08)
                                    : cardBg,
                                borderRadius:
                                    BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? color
                                      : borderDefault,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        Text(emoji,
                                            style:
                                                const TextStyle(
                                                    fontSize: 28)),
                                        const SizedBox(height: 4),
                                        Text(
                                          cat,
                                          style:
                                              GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight:
                                                FontWeight.w500,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_rounded,
                                          size: 14,
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
  late int _day, _month, _year;
  bool _allDay = true;
  String _repeatLabel = 'Asla';
  final _storageService = StorageService();

  late FixedExtentScrollController _dayCtrl;
  late FixedExtentScrollController _monthCtrl;
  late FixedExtentScrollController _yearCtrl;

  static const _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];
  static const _dayNames = [
    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma',
    'Cumartesi', 'Pazar',
  ];

  @override
  void initState() {
    super.initState();
    final d = DateTime.now().add(const Duration(days: 7));
    _day = d.day;
    _month = d.month;
    _year = d.year;
    _dayCtrl = FixedExtentScrollController(initialItem: _day - 1);
    _monthCtrl = FixedExtentScrollController(initialItem: _month - 1);
    _yearCtrl = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    _dayCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  int _daysInMonth(int m, int y) => DateTime(y, m + 1, 0).day;

  DateTime get _date {
    final maxD = _daysInMonth(_month, _year);
    return DateTime(_year, _month, _day.clamp(1, maxD));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.primaryText;
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final secondaryColor =
        isDark ? Colors.grey[400]! : AppTheme.secondaryText;
    final highlightBg =
        isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF2F2F7);
    final unselectedText =
        isDark ? Colors.grey[600]! : const Color(0xFFAEAEB2);
    final dividerColor =
        isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF2F2F7);
    final d = _date;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Big title
                    Text(
                      'Tarihi belirle',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // === CARD 1: Date picker ===
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Selected date
                          Text(
                            '${d.day} ${_months[d.month - 1]} ${d.year}',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            _dayNames[d.weekday - 1],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: secondaryColor,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Picker wheels
                          SizedBox(
                            height: 180,
                            child: Stack(
                              children: [
                                // Highlight bar
                                Center(
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: highlightBg,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    _wheel(
                                      ctrl: _dayCtrl,
                                      count: _daysInMonth(
                                          _month, _year),
                                      label: (i) => '${i + 1}',
                                      onChanged: (i) {
                                        HapticFeedback
                                            .selectionClick();
                                        setState(
                                            () => _day = i + 1);
                                      },
                                      selected: _day - 1,
                                      textColor: textColor,
                                      dimColor: unselectedText,
                                    ),
                                    _wheel(
                                      ctrl: _monthCtrl,
                                      count: 12,
                                      label: (i) => _months[i],
                                      onChanged: (i) {
                                        HapticFeedback
                                            .selectionClick();
                                        setState(
                                            () => _month = i + 1);
                                      },
                                      selected: _month - 1,
                                      textColor: textColor,
                                      dimColor: unselectedText,
                                    ),
                                    _wheel(
                                      ctrl: _yearCtrl,
                                      count: 11,
                                      label: (i) =>
                                          '${DateTime.now().year + i}',
                                      onChanged: (i) {
                                        HapticFeedback
                                            .selectionClick();
                                        setState(() => _year =
                                            DateTime.now().year +
                                                i);
                                      },
                                      selected: _year -
                                          DateTime.now().year,
                                      textColor: textColor,
                                      dimColor: unselectedText,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // === CARD 2: Options ===
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // All Day
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24),
                            child: SizedBox(
                              height: 52,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Tüm Gün',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: _allDay,
                                    onChanged: (v) {
                                      HapticFeedback
                                          .selectionClick();
                                      setState(
                                          () => _allDay = v);
                                    },
                                    activeTrackColor:
                                        AppTheme.accent,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24),
                            child: Divider(
                                height: 1,
                                color: dividerColor),
                          ),

                          // Repeats
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

  Expanded _wheel({
    required FixedExtentScrollController ctrl,
    required int count,
    required String Function(int) label,
    required ValueChanged<int> onChanged,
    required int selected,
    required Color textColor,
    required Color dimColor,
  }) {
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        controller: ctrl,
        itemExtent: 40,
        perspective: 0.003,
        diameterRatio: 1.4,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: count,
          builder: (context, index) {
            final isSel = index == selected;
            return Center(
              child: Text(
                label(index),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight:
                      isSel ? FontWeight.w600 : FontWeight.w400,
                  color: isSel ? textColor : dimColor,
                ),
              ),
            );
          },
        ),
      ),
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
  late bool _r1d, _r3d, _r1w, _r1m;
  final _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.event.title);
    _date = widget.event.targetDate;
    _category = widget.event.category;
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
                        itemCount: EventModel.categories.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = EventModel.categories[i];
                          final sel = cat == _category;
                          final emoji =
                              kCategoryEmojis[cat] ?? '📌';
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _category = cat);
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
                                    cat,
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
