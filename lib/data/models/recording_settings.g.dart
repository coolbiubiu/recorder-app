part of 'recording_settings.dart';

class RecordingSettingsAdapter extends TypeAdapter<RecordingSettings> {
  @override
  final int typeId = 1;

  @override
  RecordingSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecordingSettings(
      formatIndex: fields[0] as int,
      sampleRateValue: fields[1] as int,
      bitRateValue: fields[2] as int,
      channelIndex: fields[3] as int,
      lastModeIndex: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RecordingSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.formatIndex)
      ..writeByte(1)
      ..write(obj.sampleRateValue)
      ..writeByte(2)
      ..write(obj.bitRateValue)
      ..writeByte(3)
      ..write(obj.channelIndex)
      ..writeByte(4)
      ..write(obj.lastModeIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}