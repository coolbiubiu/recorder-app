part of 'recording_model.dart';

class RecordingModelAdapter extends TypeAdapter<RecordingModel> {
  @override
  final int typeId = 0;

  @override
  RecordingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecordingModel(
      id: fields[0] as String,
      name: fields[1] as String,
      filePath: fields[2] as String,
      createdAt: fields[3] as DateTime,
      durationMs: fields[4] as int,
      fileSize: fields[5] as int,
      formatIndex: fields[6] as int,
      modeIndex: fields[7] as int,
      sampleRate: fields[8] as int,
      bitRate: fields[9] as int,
      channelIndex: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RecordingModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.durationMs)
      ..writeByte(5)
      ..write(obj.fileSize)
      ..writeByte(6)
      ..write(obj.formatIndex)
      ..writeByte(7)
      ..write(obj.modeIndex)
      ..writeByte(8)
      ..write(obj.sampleRate)
      ..writeByte(9)
      ..write(obj.bitRate)
      ..writeByte(10)
      ..write(obj.channelIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}