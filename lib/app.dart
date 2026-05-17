import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/recording_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/audio_player_service.dart';
import 'data/services/audio_recorder_service.dart';
import 'data/services/storage_service.dart';
import 'providers/recorder_provider.dart';
import 'providers/recordings_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'ui/pages/home_page.dart';

class RecorderApp extends StatelessWidget {
  final StorageService storageService;

  const RecorderApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    final recordingRepository = RecordingRepository(storageService);
    final settingsRepository = SettingsRepository(storageService);
    final recorderService = AudioRecorderService();
    final playerService = AudioPlayerService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(repository: settingsRepository)
            ..loadTheme(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(repository: settingsRepository)
            ..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => RecordingsProvider(repository: recordingRepository)
            ..loadRecordings(),
        ),
        ChangeNotifierProvider(
          create: (_) => RecorderProvider(
            recorderService: recorderService,
            recordingRepository: recordingRepository,
            settingsRepository: settingsRepository,
          )..initialize(),
        ),
        Provider<AudioPlayerService>.value(value: playerService),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: '音频录制器',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}