import 'package:flutter/foundation.dart';
import '../data/models/recording_model.dart';
import '../data/repositories/recording_repository.dart';

enum SortType {
  date,
  size,
  duration,
}

enum SortOrder {
  ascending,
  descending,
}

class RecordingsProvider extends ChangeNotifier {
  final RecordingRepository _repository;

  RecordingsProvider({required RecordingRepository repository})
      : _repository = repository;

  List<RecordingModel> _recordings = [];
  List<RecordingModel> _filteredRecordings = [];
  String _searchKeyword = '';
  SortType _sortType = SortType.date;
  SortOrder _sortOrder = SortOrder.descending;

  List<RecordingModel> get recordings =>
      _searchKeyword.isEmpty ? _recordings : _filteredRecordings;

  List<RecordingModel> get allRecordings => _recordings;
  String get searchKeyword => _searchKeyword;
  SortType get sortType => _sortType;
  SortOrder get sortOrder => _sortOrder;

  int get totalCount => _recordings.length;

  void loadRecordings() {
    _recordings = _repository.getAllRecordings();
    _applySearchAndSort();
    notifyListeners();
  }

  void refreshRecordings() {
    loadRecordings();
  }

  void addRecording(RecordingModel recording) {
    _recordings.insert(0, recording);
    _applySearchAndSort();
    notifyListeners();
  }

  Future<void> deleteRecording(String id) async {
    await _repository.deleteRecording(id);
    _recordings.removeWhere((r) => r.id == id);
    _applySearchAndSort();
    notifyListeners();
  }

  Future<void> updateRecording(RecordingModel recording) async {
    await _repository.updateRecording(recording);
    final index = _recordings.indexWhere((r) => r.id == recording.id);
    if (index != -1) {
      _recordings[index] = recording;
      _applySearchAndSort();
    }
    notifyListeners();
  }

  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    _applySearchAndSort();
    notifyListeners();
  }

  void clearSearch() {
    _searchKeyword = '';
    _filteredRecordings = List.from(_recordings);
    notifyListeners();
  }

  void setSortType(SortType type) {
    _sortType = type;
    _applySearchAndSort();
    notifyListeners();
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    _applySearchAndSort();
    notifyListeners();
  }

  void toggleSortOrder() {
    _sortOrder = _sortOrder == SortOrder.ascending
        ? SortOrder.descending
        : SortOrder.ascending;
    _applySearchAndSort();
    notifyListeners();
  }

  void _applySearchAndSort() {
    List<RecordingModel> result = List.from(_recordings);

    if (_searchKeyword.isNotEmpty) {
      final lowerKeyword = _searchKeyword.toLowerCase();
      result = result.where((r) {
        return r.name.toLowerCase().contains(lowerKeyword);
      }).toList();
    }

    switch (_sortType) {
      case SortType.date:
        result = _repository.sortByDate(result,
            ascending: _sortOrder == SortOrder.ascending);
        break;
      case SortType.size:
        result = _repository.sortBySize(result,
            ascending: _sortOrder == SortOrder.ascending);
        break;
      case SortType.duration:
        result = _repository.sortByDuration(result,
            ascending: _sortOrder == SortOrder.ascending);
        break;
    }

    _filteredRecordings = result;
  }

  RecordingModel? getRecording(String id) {
    try {
      return _recordings.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
}