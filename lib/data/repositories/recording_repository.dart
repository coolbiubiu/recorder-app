import 'dart:io';
import '../models/recording_model.dart';
import '../services/storage_service.dart';

class RecordingRepository {
  final StorageService _storageService;

  RecordingRepository(this._storageService);

  List<RecordingModel> getAllRecordings() {
    return _storageService.getAllRecordings();
  }

  Future<void> saveRecording(RecordingModel recording) async {
    await _storageService.saveRecording(recording);
  }

  Future<void> deleteRecording(String id) async {
    final recording = _storageService.getRecording(id);
    if (recording != null) {
      final file = File(recording.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _storageService.deleteRecording(id);
  }

  Future<void> updateRecording(RecordingModel recording) async {
    await _storageService.updateRecording(recording);
  }

  RecordingModel? getRecording(String id) {
    return _storageService.getRecording(id);
  }

  List<RecordingModel> searchRecordings(String keyword) {
    final all = getAllRecordings();
    if (keyword.isEmpty) return all;

    final lowerKeyword = keyword.toLowerCase();
    return all.where((recording) {
      return recording.name.toLowerCase().contains(lowerKeyword);
    }).toList();
  }

  List<RecordingModel> sortByDate(List<RecordingModel> recordings,
      {bool ascending = false}) {
    final sorted = List<RecordingModel>.from(recordings);
    sorted.sort((a, b) {
      return ascending
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }

  List<RecordingModel> sortBySize(List<RecordingModel> recordings,
      {bool ascending = false}) {
    final sorted = List<RecordingModel>.from(recordings);
    sorted.sort((a, b) {
      return ascending
          ? a.fileSize.compareTo(b.fileSize)
          : b.fileSize.compareTo(a.fileSize);
    });
    return sorted;
  }

  List<RecordingModel> sortByDuration(List<RecordingModel> recordings,
      {bool ascending = false}) {
    final sorted = List<RecordingModel>.from(recordings);
    sorted.sort((a, b) {
      return ascending
          ? a.durationMs.compareTo(b.durationMs)
          : b.durationMs.compareTo(a.durationMs);
    });
    return sorted;
  }

  Future<void> deleteAllRecordings() async {
    final recordings = getAllRecordings();
    for (final recording in recordings) {
      await deleteRecording(recording.id);
    }
  }
}