import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 2)
class AppSettings extends HiveObject {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final String savePath;

  @HiveField(2)
  final bool autoSaveEnabled;

  AppSettings({
    this.isDarkMode = false,
    this.savePath = '',
    this.autoSaveEnabled = true,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    String? savePath,
    bool? autoSaveEnabled,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      savePath: savePath ?? this.savePath,
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
    );
  }
}