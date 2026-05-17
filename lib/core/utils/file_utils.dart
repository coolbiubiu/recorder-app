import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileUtils {
  FileUtils._();

  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  static Future<String> getDefaultRecordingsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory(p.join(directory.path, 'Recordings'));
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    return recordingsDir.path;
  }

  static Future<String> getRecordingsPath(String? customPath) async {
    String basePath;
    if (customPath != null && customPath.isNotEmpty) {
      basePath = customPath;
    } else {
      basePath = (await getApplicationDocumentsDirectory()).path;
    }
    final recordingsDir = Directory(p.join(basePath, 'Recordings'));
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    return recordingsDir.path;
  }

  static Future<String> getTempPath() async {
    final directory = await getTemporaryDirectory();
    final tempDir = Directory(p.join(directory.path, 'recordings_temp'));
    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
    }
    return tempDir.path;
  }

  static Future<bool> hasEnoughSpace(int requiredBytes) async {
    try {
      final available = await getAvailableSpace();
      return available > requiredBytes;
    } catch (e) {
      return true;
    }
  }

  static Future<int> getAvailableSpace() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(directory.path);
      final parent = file.parent;
      final stat = await parent.stat();
      return stat.size;
    } catch (e) {
      return 0;
    }
  }

  static String getFileExtension(String path) {
    return p.extension(path);
  }

  static String getFileName(String path) {
    return p.basename(path);
  }

  static String getFileNameWithoutExtension(String path) {
    return p.basenameWithoutExtension(path);
  }

  static Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<int> getFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  static Future<bool> directoryExists(String path) async {
    return Directory(path).exists();
  }

  static Future<void> createDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }
}