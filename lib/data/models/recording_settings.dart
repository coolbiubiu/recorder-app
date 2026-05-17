import 'package:hive/hive.dart';
import '../../core/constants/audio_constants.dart';

part 'recording_settings.g.dart';

@HiveType(typeId: 1)
class RecordingSettings extends HiveObject {
  @HiveField(0)
  final int formatIndex;

  @HiveField(1)
  final int sampleRateValue;

  @HiveField(2)
  final int bitRateValue;

  @HiveField(3)
  final int channelIndex;

  @HiveField(4)
  final int lastModeIndex;

  RecordingSettings({
    this.formatIndex = 4,
    this.sampleRateValue = 44100,
    this.bitRateValue = 128,
    this.channelIndex = 0,
    this.lastModeIndex = 0,
  });

  AudioFormat get format => AudioFormat.values[formatIndex];
  RecordingMode get lastMode => RecordingMode.values[lastModeIndex];
  AudioChannel get channel => AudioChannel.values[channelIndex];

  AudioSampleRate get sampleRate {
    return AudioSampleRate.values.firstWhere(
      (e) => e.value == sampleRateValue,
      orElse: () => AudioSampleRate.hz44100,
    );
  }

  AudioBitRate get bitRate {
    return AudioBitRate.values.firstWhere(
      (e) => e.value == bitRateValue,
      orElse: () => AudioBitRate.kbps128,
    );
  }

  RecordingSettings copyWith({
    int? formatIndex,
    int? sampleRateValue,
    int? bitRateValue,
    int? channelIndex,
    int? lastModeIndex,
  }) {
    return RecordingSettings(
      formatIndex: formatIndex ?? this.formatIndex,
      sampleRateValue: sampleRateValue ?? this.sampleRateValue,
      bitRateValue: bitRateValue ?? this.bitRateValue,
      channelIndex: channelIndex ?? this.channelIndex,
      lastModeIndex: lastModeIndex ?? this.lastModeIndex,
    );
  }
}