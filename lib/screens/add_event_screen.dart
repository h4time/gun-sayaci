import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class AddEventSheet extends StatefulWidget {
  final EventModel? event;

  const AddEventSheet({super.key, this.event});

  @override
  State<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<AddEventSheet> {
  final _titleController = TextEditingController();
  final _storageService = StorageService();

  late DateTime _selectedDate;
  String _selectedCategory = 'Doğum Günü';
  bool _notificationEnabled = true;
  bool _reminder1Day = false;
  bool _reminder3Days = false;
  bool _reminder1Week = false;
  bool _reminder1Month = false;

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.event!;
      _titleController.text = e.title;
      _selectedDate = e.targetDate;
      _selectedCategory = e.category;
      _notificationEnabled = e.notificationEnabled;
      _reminder1Day = e.reminder1Day;
      _reminder3Days = e.reminder3Days;
      _reminder1Week = e.reminder1Week;
      _reminder1Month = e.reminder1Month;
    } else {
      _selectedDate = DateTime.now().add(const Duration(days: 7));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
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

                // Title
                Text(
                  _isEditing ? 'Etkinliği Düzenle' : 'Yeni Etkinlik',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.grey[900],
                  ),
                ),

                const SizedBox(height: 24),

                // Event name field - Turkish character support
                _buildLabel('Etkinlik Adı'),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  style: GoogleFonts.poppins(fontSize: 16),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  enableIMEPersonalizedLearning: true,
                  autocorrect: false,
                  enableSuggestions: true,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Örn: Annemin Doğum Günü',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Category grid
                _buildLabel('Kategori'),
                const SizedBox(height: 12),
                _buildCategoryGrid(isDark),

                const SizedBox(height: 24),

                // Date picker
                _buildLabel('Tarih'),
                const SizedBox(height: 8),
                _buildDateSelector(isDark),

                const SizedBox(height: 24),

                // Reminder settings
                _buildLabel('Hatırlatmalar'),
                const SizedBox(height: 12),
                _buildReminderSettings(isDark),

                const SizedBox(height: 24),

                // Preview card
                _buildPreview(isDark),

                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saveEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isEditing ? 'Güncelle' : 'Etkinlik Ekle',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildCategoryGrid(bool isDark) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: EventModel.categories.map((cat) {
        final isSelected = cat == _selectedCategory;
        final iconData = AppTheme.getFallbackIconForCategory(cat);

        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                    )
                  : null,
              color: isSelected
                  ? null
                  : (isDark ? Colors.grey[800] : Colors.grey[100]),
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? null
                  : Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      width: 1,
                    ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconData,
                  size: 16,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey[300] : Colors.grey[700]),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    cat,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[300] : Colors.grey[700]),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateSelector(bool isDark) {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: Color(0xFF6C63FF),
            ),
            const SizedBox(width: 12),
            Text(
              _formatDate(_selectedDate),
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSettings(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Event day - always enabled
          _buildReminderRow(
            icon: Icons.celebration_rounded,
            label: 'Etkinlik günü',
            subtitle: 'Her zaman aktif',
            value: true,
            enabled: false,
            isDark: isDark,
          ),
          _divider(isDark),
          _buildReminderRow(
            icon: Icons.notifications_rounded,
            label: '1 Gün önce',
            value: _reminder1Day,
            onChanged: (v) => setState(() => _reminder1Day = v),
            isDark: isDark,
          ),
          _divider(isDark),
          _buildReminderRow(
            icon: Icons.notifications_rounded,
            label: '3 Gün önce',
            value: _reminder3Days,
            onChanged: (v) => setState(() => _reminder3Days = v),
            isDark: isDark,
          ),
          _divider(isDark),
          _buildReminderRow(
            icon: Icons.notifications_rounded,
            label: '1 Hafta önce',
            value: _reminder1Week,
            onChanged: (v) => setState(() => _reminder1Week = v),
            isDark: isDark,
          ),
          _divider(isDark),
          _buildReminderRow(
            icon: Icons.notifications_rounded,
            label: '1 Ay önce',
            value: _reminder1Month,
            onChanged: (v) => setState(() => _reminder1Month = v),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderRow({
    required IconData icon,
    required String label,
    String? subtitle,
    required bool value,
    bool enabled = true,
    ValueChanged<bool>? onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: value ? const Color(0xFF6C63FF) : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: enabled
                        ? null
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
          Checkbox(
            value: value,
            onChanged: enabled ? (v) => onChanged?.call(v ?? false) : null,
            activeColor: const Color(0xFF6C63FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      indent: 48,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }

  Widget _buildPreview(bool isDark) {
    final imagePath = AppTheme.getImageForCategory(_selectedCategory);
    final title =
        _titleController.text.isEmpty ? 'Etkinlik Adı' : _titleController.text;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final days = target.difference(today).inDays;
    final dDay =
        days > 0 ? 'D-$days' : (days == 0 ? 'D-Day' : 'D+${days.abs()}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Önizleme'),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  dDay,
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        _formatDate(_selectedDate),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveEvent() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lütfen bir etkinlik adı girin',
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final event = EventModel(
      id: _isEditing ? widget.event!.id : const Uuid().v4(),
      title: title,
      targetDate: _selectedDate,
      category: _selectedCategory,
      emoji: '',
      gradientIndex: 0,
      notificationEnabled: _notificationEnabled,
      reminderEventDay: true,
      reminder1Day: _reminder1Day,
      reminder3Days: _reminder3Days,
      reminder1Week: _reminder1Week,
      reminder1Month: _reminder1Month,
      createdAt: _isEditing ? widget.event!.createdAt : DateTime.now(),
    );

    if (_isEditing) {
      _storageService.updateEvent(event);
    } else {
      _storageService.addEvent(event);
    }

    NotificationService().scheduleEventNotification(event);

    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
