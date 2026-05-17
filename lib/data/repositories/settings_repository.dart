import '../../core/constants/audio_constants.dart';
import '../models/app_settings.dart';
import '../models/recording_settings.dart';
import '../services/storage_service.dart';

class SettingsRepository {
  final StorageService _storageService;

  SettingsRepository(this._storageService);

  RecordingSettings getRecordingSettings() {
    return _storageService.getRecordingSettings();
  }

  Future<void> saveRecordingSettings(RecordingSettings settings) async {
    await _storageService.saveRecordingSettings(settings);
  }

  Future<void> updateLastRecordingMode(RecordingMode mode) async {
    final current = getRecordingSettings();
    await saveRecordingSettings(
      current.copyWith(lastModeIndex: mode.value),
    );
  }

  Future<void> updateAudioFormat(AudioFormat format) async {
    final current = getRecordingSettings();
    await saveRecordingSettings(
      current.copyWith(formatIndex: format.index),
    );
  }

  Future<void> updateSampleRate(int value) async {
    final current = getRecordingSettings();
    await saveRecordingSettings(
      current.copyWith(sampleRateValue: value),
    );
  }

  Future<void> updateBitRate(int value) async {
    final current = getRecordingSettings();
    await saveRecordingSettings(
      current.copyWith(bitRateValue: value),
    );
  }

  Future<void> updateChannel(AudioChannel channel) async {
    final current = getRecordingSettings();
    await saveRecordingSettings(
      current.copyWith(channelIndex: channel.index),
    );
  }

  AppSettings getAppSettings() {
    return _storageService.getAppSettings();
  }

  Future<void> saveAppSettings(AppSettings settings) async {
    await _storageService.saveAppSettings(settings);
  }

  Future<void> updateDarkMode(bool isDark) async {
    final current = getAppSettings();
    await saveAppSettings(
      current.copyWith(isDarkMode: isDark),
    );
  }

  Future<void> updateSavePath(String path) async {
    final current = getAppSettings();
    await saveAppSettings(
      current.copyWith(savePath: path),
    );
  }

  Future<void> updateAutoSave(bool enabled) async {
    final current = getAppSettings();
    await saveAppSettings(
      current.copyWith(autoSaveEnabled: enabled),
    );
  }
}