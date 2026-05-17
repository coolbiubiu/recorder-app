import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/audio_constants.dart';
import '../data/models/recording_model.dart';
import '../data/models/recording_settings.dart';
import '../data/repositories/recording_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/services/audio_recorder_service.dart';
import '../data/services/floating_window_service.dart';
import '../data/services/log_service.dart';

class RecorderProvider extends ChangeNotifier {
  final AudioRecorderService _recorderService;
  final RecordingRepository _recordingRepository;
  final SettingsRepository _settingsRepository;

  RecorderProvider({
    required AudioRecorderService recorderService,
    required RecordingRepository recordingRepository,
    required SettingsRepository settingsRepository,
  })  : _recorderService = recorderService,
        _recordingRepository = recordingRepository,
        _settingsRepository = settingsRepository;

  RecorderState _state = RecorderState.idle;
  RecordingMode _currentMode = RecordingMode.microphoneOnly;
  Duration _currentDuration = Duration.zero;
  double _amplitude = 0.0;
  RecordingModel? _currentRecording;
  String? _lastError;

  StreamSubscription? _stateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _amplitudeSubscription;

  RecorderState get state => _state;
  RecordingMode get currentMode => _currentMode;
  Duration get currentDuration => _currentDuration;
  double get amplitude => _amplitude;
  RecordingModel? get currentRecording => _currentRecording;
  RecordingModel? get mixedSystemRecording => _recorderService.mixedSystemRecording;

  bool get isRecording => _state == RecorderState.recording;
  bool get isPaused => _state == RecorderState.paused;
  bool get isIdle => _state == RecorderState.idle;
  bool get canPause => isRecording && _currentMode == RecordingMode.microphoneOnly;
  String? get lastError => _lastError;

  Future<void> initialize() async {
    final settings = _settingsRepository.getRecordingSettings();
    final appSettings = _settingsRepository.getAppSettings();
    await _recorderService.initialize(settings, savePath: appSettings.savePath);
    _currentMode = settings.lastMode;

    _setupFloatingWindowCallbacks();
    _startFloatingWindowListener();

    _stateSubscription = _recorderService.stateStream.listen((state) {
      _state = state;
      _updateFloatingWindow();
      notifyListeners();
    });

    _durationSubscription = _recorderService.durationStream.listen((duration) {
      _currentDuration = duration;
      _updateFloatingWindow();
      notifyListeners();
    });

    _amplitudeSubscription =
        _recorderService.amplitudeStream.listen((amplitude) {
      _amplitude = amplitude;
      notifyListeners();
    });
  }

  void _startFloatingWindowListener() {
    FloatingWindowService.startListening((event) {
      debugPrint('Floating window event received: $event');
      switch (event) {
        case 'stop':
          debugPrint('Stop recording from floating window');
          stopRecording();
          break;
        case 'pause':
          pauseRecording();
          break;
        case 'resume':
          resumeRecording();
          break;
        case 'close':
          cancelRecording();
          break;
      }
    });
  }

  void _setupFloatingWindowCallbacks() {
    FloatingWindowService.onPausePressed = (_) {
      debugPrint('Floating window pause pressed');
      pauseRecording();
    };
    FloatingWindowService.onResumePressed = (_) {
      debugPrint('Floating window resume pressed');
      resumeRecording();
    };
    FloatingWindowService.onStopPressed = (_) {
      debugPrint('Floating window stop pressed');
      stopRecording();
    };
    FloatingWindowService.onClosePressed = (_) {
      debugPrint('Floating window close pressed');
      cancelRecording();
    };
  }

  Future<void> _handleStopFromFloating() async {
    await stopRecording();
  }

  Future<void> _handleCloseFromFloating() async {
    await cancelRecording();
    await FloatingWindowService.hideFloatingWindow();
  }

  Future<void> _showFloatingWindow() async {
    final hasPermission = await FloatingWindowService.checkPermission();
    if (hasPermission) {
      await FloatingWindowService.showFloatingWindow(
        duration: _currentDuration,
        isRecording: isRecording,
        isPaused: isPaused,
      );
    }
  }

  Future<void> _updateFloatingWindow() async {
    await FloatingWindowService.updateFloatingWindow(
      duration: _currentDuration,
      isRecording: isRecording,
      isPaused: isPaused,
    );
  }

  Future<void> _hideFloatingWindow() async {
    await FloatingWindowService.hideFloatingWindow();
  }

  Future<void> refreshSettings() async {
    final settings = _settingsRepository.getRecordingSettings();
    final appSettings = _settingsRepository.getAppSettings();
    await _recorderService.initialize(settings, savePath: appSettings.savePath);
    notifyListeners();
  }

  Future<bool> hasPermission() async {
    return await _recorderService.hasPermission();
  }

  void setRecordingMode(RecordingMode mode) {
    if (_state != RecorderState.idle) return;
    _currentMode = mode;
    _recorderService.setRecordingMode(mode);
    _settingsRepository.updateLastRecordingMode(mode);
    notifyListeners();
  }

  Future<bool> startRecording() async {
    try {
      _lastError = null;
      await refreshSettings();
      await _recorderService.startRecording();
      await _showFloatingWindow();
      return true;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('Error starting recording: $_lastError');
      LogService().error('启动录音失败: $_lastError');
      return false;
    }
  }

  Future<void> pauseRecording() async {
    await _recorderService.pauseRecording();
  }

  Future<void> resumeRecording() async {
    await _recorderService.resumeRecording();
  }

  Future<RecordingModel?> stopRecording() async {
    try {
      debugPrint('stopRecording: called, current state: $_state');
      final recording = await _recorderService.stopRecording();
      debugPrint('stopRecording: result = ${recording != null ? "success" : "null"}');

      if (recording != null) {
        debugPrint('stopRecording: saving to repository: ${recording.name}');
        await _recordingRepository.saveRecording(recording);
        _currentRecording = recording;
        debugPrint('stopRecording: saved successfully');

        // For mixed mode, also save the system audio recording
        final sysRecording = _recorderService.mixedSystemRecording;
        if (sysRecording != null) {
          await _recordingRepository.saveRecording(sysRecording);
          debugPrint('stopRecording: saved system audio recording: ${sysRecording.name}');
        }
      } else {
        debugPrint('stopRecording: FAILED - recording is null');
      }

      try {
        await _hideFloatingWindow();
      } catch (e) {
        debugPrint('stopRecording: hideFloatingWindow error (ignored): $e');
      }

      _state = RecorderState.idle;
      _currentDuration = Duration.zero;
      _amplitude = 0.0;
      notifyListeners();
      return recording;
    } catch (e, stack) {
      debugPrint('stopRecording: EXCEPTION - $e\n$stack');
      _state = RecorderState.idle;
      _currentDuration = Duration.zero;
      _amplitude = 0.0;
      notifyListeners();
      return null;
    }
  }

  Future<void> cancelRecording() async {
    await _recorderService.cancelRecording();
    await _hideFloatingWindow();
    notifyListeners();
  }

  RecordingSettings get currentSettings =>
      _settingsRepository.getRecordingSettings();

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _durationSubscription?.cancel();
    _amplitudeSubscription?.cancel();
    FloatingWindowService.stopListening();
    _hideFloatingWindow();
    super.dispose();
  }
}