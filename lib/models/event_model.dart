import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 0)
class EventModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime targetDate;

  @HiveField(3)
  String category;

  @HiveField(4)
  String emoji;

  @HiveField(5)
  int gradientIndex;

  @HiveField(6)
  bool notificationEnabled;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8, defaultValue: true)
  bool reminderEventDay;

  @HiveField(9, defaultValue: false)
  bool reminder1Day;

  @HiveField(10, defaultValue: false)
  bool reminder3Days;

  @HiveField(11, defaultValue: false)
  bool reminder1Week;

  @HiveField(12, defaultValue: false)
  bool reminder1Month;

  EventModel({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.category,
    this.emoji = '🎉',
    this.gradientIndex = 0,
    this.notificationEnabled = true,
    this.reminderEventDay = true,
    this.reminder1Day = false,
    this.reminder3Days = false,
    this.reminder1Week = false,
    this.reminder1Month = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Duration get remaining => targetDate.difference(DateTime.now());

  bool get isExpired {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return targetDate.isBefore(todayEnd) && !isToday;
  }

  bool get isToday =>
      targetDate.year == DateTime.now().year &&
      targetDate.month == DateTime.now().month &&
      targetDate.day == DateTime.now().day;

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(today).inDays;
  }

  String get dDayText {
    final days = daysRemaining;
    if (days > 0) return 'D-$days';
    if (days == 0) return 'D-Day';
    return 'D+${days.abs()}';
  }

  /// Progress from createdAt to targetDate (0.0 to 1.0)
  double get progress {
    final total = targetDate.difference(createdAt).inSeconds;
    if (total <= 0) return 1.0;
    final elapsed = DateTime.now().difference(createdAt).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  static const List<String> categories = [
    'Doğum Günü',
    'Tatil',
    'Düğün/Yıldönümü',
    'Sınav/İş',
    'Seyahat',
    'Diğer',
  ];
}
