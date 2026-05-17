import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum LogLevel { info, warning, error }

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
  });

  String get formatted {
    final time = '${timestamp.year}-${_pad(timestamp.month)}-${_pad(timestamp.day)} '
        '${_pad(timestamp.hour)}:${_pad(timestamp.minute)}:${_pad(timestamp.second)}';
    final levelStr = level.name.toUpperCase();
    return '[$time] $levelStr: $message';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}

class LogService {
  static final LogService _instance = LogService._();
  factory LogService() => _instance;
  LogService._();

  final List<LogEntry> _entries = [];
  String? _logFilePath;

  List<LogEntry> get entries => List.unmodifiable(_entries);
  bool get isInitialized => _logFilePath != null;

  Future<void> initialize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/Recordings/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      _logFilePath = '${logDir.path}/app_log.txt';

      // Clear log file on startup
      final file = File(_logFilePath!);
      if (await file.exists()) {
        await file.delete();
      }
      await file.create();
      _entries.clear();

      info('日志系统初始化完成');
    } catch (e) {
      debugPrint('LogService initialize error: $e');
    }
  }

  void info(String message) => _log(LogLevel.info, message);
  void warning(String message) => _log(LogLevel.warning, message);
  void error(String message) => _log(LogLevel.error, message);

  void _log(LogLevel level, String message) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
    );

    _entries.add(entry);
    debugPrint(entry.formatted);

    if (_logFilePath != null) {
      try {
        final file = File(_logFilePath!);
        file.writeAsStringSync('${entry.formatted}\n', mode: FileMode.append);
      } catch (_) {}
    }
  }

  Future<String> readLogFile() async {
    if (_logFilePath == null) return '';
    try {
      final file = File(_logFilePath!);
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (_) {}
    return '';
  }

  void clear() {
    _entries.clear();
    if (_logFilePath != null) {
      try {
        final file = File(_logFilePath!);
        file.writeAsStringSync('');
      } catch (_) {}
    }
  }
}
