import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/storage_keys.dart';
import '../models/recording_model.dart';
import '../models/recording_settings.dart';
import '../models/app_settings.dart';

class StorageService {
  static const String _recordingsBoxName = 'recordings';
  static const String _settingsBoxName = 'settings';

  late Box<RecordingModel> _recordingsBox;
  late Box<dynamic> _settingsBox;

  Future<void> initialize() async {
    await Hive.initFlutter();

    Hive.registerAdapter(RecordingModelAdapter());
    Hive.registerAdapter(RecordingSettingsAdapter());
    Hive.registerAdapter(AppSettingsAdapter());

    _recordingsBox = await Hive.openBox<RecordingModel>(_recordingsBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  List<RecordingModel> getAllRecordings() {
    return _recordingsBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveRecording(RecordingModel recording) async {
    await _recordingsBox.put(recording.id, recording);
  }

  Future<void> deleteRecording(String id) async {
    await _recordingsBox.delete(id);
  }

  Future<void> updateRecording(RecordingModel recording) async {
    await _recordingsBox.put(recording.id, recording);
  }

  RecordingModel? getRecording(String id) {
    return _recordingsBox.get(id);
  }

  RecordingSettings getRecordingSettings() {
    final data = _settingsBox.get(StorageKeys.settings);
    if (data is RecordingSettings) {
      return data;
    }
    return RecordingSettings();
  }

  Future<void> saveRecordingSettings(RecordingSettings settings) async {
    await _settingsBox.put(StorageKeys.settings, settings);
  }

  AppSettings getAppSettings() {
    final data = _settingsBox.get('app_settings');
    if (data is AppSettings) {
      return data;
    }
    return AppSettings();
  }

  Future<void> saveAppSettings(AppSettings settings) async {
    await _settingsBox.put('app_settings', settings);
  }

  Future<void> clearAllData() async {
    await _recordingsBox.clear();
    await _settingsBox.clear();
  }
}