class AppConstants {
  AppConstants._();

  static const String appName = '音频录制器';
  static const String appVersion = '1.0.0';

  static const String defaultFileNamePrefix = '录音';
  static const String tempFileExtension = '.temp';
  static const String defaultRecordingExtension = '.m4a';

  static const int maxRecentRecordings = 5;

  static const int waveformBufferSize = 100;
  static const int autoSaveIntervalSeconds = 30;

  static const int minStorageSpaceMB = 100;
}