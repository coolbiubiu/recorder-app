import 'package:hive/hive.dart';
import '../../core/constants/audio_constants.dart';

part 'recording_model.g.dart';

@HiveType(typeId: 0)
class RecordingModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String filePath;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final int durationMs;

  @HiveField(5)
  final int fileSize;

  @HiveField(6)
  final int formatIndex;

  @HiveField(7)
  final int modeIndex;

  @HiveField(8)
  final int sampleRate;

  @HiveField(9)
  final int bitRate;

  @HiveField(10)
  final int channelIndex;

  RecordingModel({
    required this.id,
    required this.name,
    required this.filePath,
    required this.createdAt,
    required this.durationMs,
    required this.fileSize,
    required this.formatIndex,
    required this.modeIndex,
    required this.sampleRate,
    required this.bitRate,
    required this.channelIndex,
  });

  AudioFormat get format => AudioFormat.values[formatIndex];
  RecordingMode get mode => RecordingMode.values[modeIndex];
  AudioChannel get channel => AudioChannel.values[channelIndex];
  Duration get duration => Duration(milliseconds: durationMs);

  RecordingModel copyWith({
    String? id,
    String? name,
    String? filePath,
    DateTime? createdAt,
    int? durationMs,
    int? fileSize,
    int? formatIndex,
    int? modeIndex,
    int? sampleRate,
    int? bitRate,
    int? channelIndex,
  }) {
    return RecordingModel(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      durationMs: durationMs ?? this.durationMs,
      fileSize: fileSize ?? this.fileSize,
      formatIndex: formatIndex ?? this.formatIndex,
      modeIndex: modeIndex ?? this.modeIndex,
      sampleRate: sampleRate ?? this.sampleRate,
      bitRate: bitRate ?? this.bitRate,
      channelIndex: channelIndex ?? this.channelIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'durationMs': durationMs,
      'fileSize': fileSize,
      'formatIndex': formatIndex,
      'modeIndex': modeIndex,
      'sampleRate': sampleRate,
      'bitRate': bitRate,
      'channelIndex': channelIndex,
    };
  }

  factory RecordingModel.fromJson(Map<String, dynamic> json) {
    return RecordingModel(
      id: json['id'] as String,
      name: json['name'] as String,
      filePath: json['filePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      durationMs: json['durationMs'] as int,
      fileSize: json['fileSize'] as int,
      formatIndex: json['formatIndex'] as int,
      modeIndex: json['modeIndex'] as int,
      sampleRate: json['sampleRate'] as int,
      bitRate: json['bitRate'] as int,
      channelIndex: json['channelIndex'] as int,
    );
  }
}