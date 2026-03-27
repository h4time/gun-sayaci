import 'package:hive_flutter/hive_flutter.dart';
import '../models/event_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _boxName = 'events';
  late Box<EventModel> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(EventModelAdapter());
    _box = await Hive.openBox<EventModel>(_boxName);
  }

  Box<EventModel> get box => _box;

  List<EventModel> getAllEvents() {
    return _box.values.toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
  }

  Future<void> addEvent(EventModel event) async {
    await _box.put(event.id, event);
  }

  Future<void> updateEvent(EventModel event) async {
    await _box.put(event.id, event);
  }

  Future<void> deleteEvent(String id) async {
    await _box.delete(id);
  }

  EventModel? getEvent(String id) {
    return _box.get(id);
  }
}
