import 'package:flutter/foundation.dart';
import '../core/constants/audio_constants.dart';
import '../data/models/app_settings.dart';
import '../data/models/recording_settings.dart';
import '../data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;

  SettingsProvider({required SettingsRepository repository})
      : _repository = repository;

  RecordingSettings _recordingSettings = RecordingSettings();
  AppSettings _appSettings = AppSettings();

  RecordingSettings get recordingSettings => _recordingSettings;
  AppSettings get appSettings => _appSettings;

  AudioFormat get audioFormat => _recordingSettings.format;
  AudioSampleRate get sampleRate => _recordingSettings.sampleRate;
  AudioBitRate get bitRate => _recordingSettings.bitRate;
  AudioChannel get channel => _recordingSettings.channel;
  RecordingMode get lastRecordingMode => _recordingSettings.lastMode;

  bool get isDarkMode => _appSettings.isDarkMode;
  String get savePath => _appSettings.savePath;
  bool get autoSaveEnabled => _appSettings.autoSaveEnabled;

  void loadSettings() {
    _recordingSettings = _repository.getRecordingSettings();
    _appSettings = _repository.getAppSettings();
    notifyListeners();
  }

  Future<void> setAudioFormat(AudioFormat format) async {
    await _repository.updateAudioFormat(format);
    _recordingSettings = _repository.getRecordingSettings();
    notifyListeners();
  }

  Future<void> setSampleRate(AudioSampleRate rate) async {
    await _repository.updateSampleRate(rate.value);
    _recordingSettings = _repository.getRecordingSettings();
    notifyListeners();
  }

  Future<void> setBitRate(AudioBitRate rate) async {
    await _repository.updateBitRate(rate.value);
    _recordingSettings = _repository.getRecordingSettings();
    notifyListeners();
  }

  Future<void> setChannel(AudioChannel channel) async {
    await _repository.updateChannel(channel);
    _recordingSettings = _repository.getRecordingSettings();
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    await _repository.updateDarkMode(isDark);
    _appSettings = _repository.getAppSettings();
    notifyListeners();
  }

  Future<void> setSavePath(String path) async {
    await _repository.updateSavePath(path);
    _appSettings = _repository.getAppSettings();
    notifyListeners();
  }

  Future<void> setAutoSave(bool enabled) async {
    await _repository.updateAutoSave(enabled);
    _appSettings = _repository.getAppSettings();
    notifyListeners();
  }
}