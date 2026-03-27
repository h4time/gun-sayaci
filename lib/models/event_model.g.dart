// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventModelAdapter extends TypeAdapter<EventModel> {
  @override
  final int typeId = 0;

  @override
  EventModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventModel(
      id: fields[0] as String,
      title: fields[1] as String,
      targetDate: fields[2] as DateTime,
      category: fields[3] as String,
      emoji: fields[4] as String,
      gradientIndex: fields[5] as int,
      notificationEnabled: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      reminderEventDay: fields[8] as bool? ?? true,
      reminder1Day: fields[9] as bool? ?? false,
      reminder3Days: fields[10] as bool? ?? false,
      reminder1Week: fields[11] as bool? ?? false,
      reminder1Month: fields[12] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, EventModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.targetDate)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.emoji)
      ..writeByte(5)
      ..write(obj.gradientIndex)
      ..writeByte(6)
      ..write(obj.notificationEnabled)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.reminderEventDay)
      ..writeByte(9)
      ..write(obj.reminder1Day)
      ..writeByte(10)
      ..write(obj.reminder3Days)
      ..writeByte(11)
      ..write(obj.reminder1Week)
      ..writeByte(12)
      ..write(obj.reminder1Month);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
