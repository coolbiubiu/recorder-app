import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/audio_constants.dart';
import '../../core/utils/file_utils.dart';
import '../models/recording_model.dart';
import '../models/recording_settings.dart';
import 'log_service.dart';
import 'system_audio_service.dart';

enum RecorderState {
  idle,
  recording,
  paused,
}

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  final _uuid = const Uuid();

  RecorderState _state = RecorderState.idle;
  RecordingMode _currentMode = RecordingMode.microphoneOnly;
  RecordingSettings? _settings;
  String _savePath = '';

  String? _currentFilePath;
  String? _systemAudioFilePath;
  RecordingModel? _mixedSystemRecording;
  DateTime? _recordingStartTime;
  Duration _pausedDuration = Duration.zero;
  DateTime? _pauseStartTime;

  final _stateController = StreamController<RecorderState>.broadcast();
  final _amplitudeController = StreamController<double>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();

  Timer? _durationTimer;
  Timer? _amplitudeTimer;

  Stream<RecorderState> get stateStream => _stateController.stream;
  Stream<double> get amplitudeStream => _amplitudeController.stream;
  Stream<Duration> get durationStream => _durationController.stream;

  RecorderState get state => _state;
  RecordingMode get currentMode => _currentMode;
  String? get currentFilePath => _currentFilePath;
  String? get systemAudioFilePath => _systemAudioFilePath;
  RecordingModel? get mixedSystemRecording => _mixedSystemRecording;

  Duration get currentDuration {
    if (_recordingStartTime == null) return Duration.zero;
    if (_state == RecorderState.paused && _pauseStartTime != null) {
      return _pauseStartTime!.difference(_recordingStartTime!) - _pausedDuration;
    }
    return DateTime.now().difference(_recordingStartTime!) - _pausedDuration;
  }

  Future<void> initialize(RecordingSettings settings, {String savePath = ''}) async {
    _settings = settings;
    _currentMode = settings.lastMode;
    _savePath = savePath;
    debugPrint('initialize: settings loaded, format=${settings.format}, savePath=$savePath');
  }

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<void> setRecordingMode(RecordingMode mode) async {
    _currentMode = mode;
  }

Future<void> startRecording() async {
    debugPrint('startRecording: starting... mode=$_currentMode');

    if (_state != RecorderState.idle) {
      debugPrint('startRecording: WARNING - state is $_state, forcing reset');
      _reset();
    }

    if (_settings == null) {
      debugPrint('startRecording: ERROR - settings is null!');
      LogService().error('录音设置未初始化，请重启应用');
      throw RecordingException('录音设置未初始化，请重启应用');
    }

    String savePath;
    try {
      final directory = await getApplicationDocumentsDirectory();
      savePath = directory.path;

      final recordingsDir = Directory('$savePath/Recordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }
      savePath = recordingsDir.path;
    } catch (e) {
      debugPrint('startRecording: ERROR getting savePath: $e');
      LogService().error('无法访问存储位置: $e');
      throw RecordingException('无法访问存储位置: $e');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    switch (_currentMode) {
      case RecordingMode.systemOnly:
        final fileName = 'recording_${timestamp}.wav';
        _currentFilePath = '$savePath/$fileName';
        debugPrint('startRecording: _currentFilePath=$_currentFilePath, mode=$_currentMode');
        await _startSystemAudioCapture();
        break;
      case RecordingMode.microphoneOnly:
        final extension = _settings!.format.extension;
        final fileName = 'recording_$timestamp$extension';
        _currentFilePath = '$savePath/$fileName';
        debugPrint('startRecording: format=${_settings!.format.displayName}, ext=$extension, path=$_currentFilePath, mode=$_currentMode');
        await _startMicrophoneRecording();
        break;
      case RecordingMode.mixed:
        final extension = _settings!.format.extension;
        final micFileName = 'recording_${timestamp}_mic$extension';
        final sysFileName = 'recording_${timestamp}_sys.wav';
        _currentFilePath = '$savePath/$micFileName';
        _systemAudioFilePath = '$savePath/$sysFileName';
        debugPrint('startRecording: format=${_settings!.format.displayName}, mic=$_currentFilePath, sys=$_systemAudioFilePath, mode=$_currentMode');
        await _startMixedRecording();
        break;
    }
  }

  Future<void> _startMicAudioRecord() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      LogService().warning('麦克风权限未授予');
      throw RecordingException('没有录音权限');
    }

    try {
      final isRec = await _recorder.isRecording();
      if (isRec) {
        await _recorder.stop();
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      debugPrint('startRecording: error checking/stopping previous recording: $e');
    }

    final config = RecordConfig(
      encoder: _getEncoder(_settings!.format),
      sampleRate: _settings!.sampleRate.value,
      bitRate: _settings!.bitRate.value,
      numChannels: _settings!.channel.value,
      autoGain: true,
      echoCancel: true,
      noiseSuppress: true,
    );
    debugPrint('startRecording: encoder=${config.encoder}');

    try {
      await _recorder.start(config, path: _currentFilePath!);
      debugPrint('startRecording: recorder.start() succeeded');
    } catch (e) {
      debugPrint('startRecording: ERROR - recorder.start() failed: $e');
      _currentFilePath = null;
      rethrow;
    }
  }

  void _onRecordingStarted() {
    _state = RecorderState.recording;
    _recordingStartTime = DateTime.now();
    _pausedDuration = Duration.zero;
    _pauseStartTime = null;
    _stateController.add(_state);
  }

  Future<void> _startMicrophoneRecording() async {
    await _startMicAudioRecord();
    _onRecordingStarted();
    _startDurationTimer();
    _startAmplitudeTimer();
    debugPrint('startRecording: SUCCESS (mic), state=$_state');
  }

  Future<void> _startMixedRecording() async {
    await _startMicAudioRecord();

    bool success;
    try {
      success = await SystemAudioService.startCapture(_systemAudioFilePath!);
    } catch (e) {
      await _recorder.stop();
      _currentFilePath = null;
      _systemAudioFilePath = null;
      LogService().error('混合录制-系统声音启动失败: $e');
      throw RecordingException('系统声音录制启动失败: $e');
    }
    if (!success) {
      await _recorder.stop();
      _currentFilePath = null;
      _systemAudioFilePath = null;
      throw RecordingException('系统声音录制启动失败，请检查权限');
    }

    _onRecordingStarted();
    _startDurationTimer();
    _startAmplitudeTimer();
    debugPrint('startRecording: SUCCESS (mixed), state=$_state');
  }

  Future<void> _startSystemAudioCapture() async {
    bool success;
    try {
      success = await SystemAudioService.startCapture(_currentFilePath!);
    } catch (e) {
      _currentFilePath = null;
      LogService().error('系统声音录制启动失败: $e');
      throw RecordingException('系统声音录制启动失败: $e');
    }
    if (!success) {
      _currentFilePath = null;
      throw RecordingException('系统声音录制启动失败，请检查权限');
    }

    _onRecordingStarted();
    _startDurationTimer();
    debugPrint('startRecording: SUCCESS (sys), state=$_state');
  }

  Future<void> pauseRecording() async {
    if (_state != RecorderState.recording) return;
    if (_currentMode != RecordingMode.microphoneOnly) return;

    await _recorder.pause();
    _pauseStartTime = DateTime.now();
    _state = RecorderState.paused;
    _stateController.add(_state);
    _stopTimers();
  }

  Future<void> resumeRecording() async {
    if (_state != RecorderState.paused) return;
    if (_currentMode != RecordingMode.microphoneOnly) return;

    if (_pauseStartTime != null) {
      _pausedDuration += DateTime.now().difference(_pauseStartTime!);
      _pauseStartTime = null;
    }

    await _recorder.resume();
    _state = RecorderState.recording;
    _stateController.add(_state);
    _startDurationTimer();
    _startAmplitudeTimer();
  }

  Future<RecordingModel?> stopRecording() async {
    debugPrint('stopRecording: called, state=$_state, file=$_currentFilePath, mode=$_currentMode');

    if (_state == RecorderState.idle) {
      debugPrint('stopRecording: state is idle, returning null');
      return null;
    }

    if (_currentFilePath == null) {
      debugPrint('stopRecording: _currentFilePath is null, returning null');
      _reset();
      return null;
    }

    _stopTimers();

    int? durationMs;

    switch (_currentMode) {
      case RecordingMode.systemOnly:
        final result = await SystemAudioService.stopCapture();
        debugPrint('stopRecording: system audio stopped, result=$result');
        durationMs = result?['duration'] as int?;

      case RecordingMode.microphoneOnly:
        try {
          await _recorder.stop();
          debugPrint('stopRecording: recorder.stop() completed');
        } catch (e) {
          debugPrint('stopRecording: recorder.stop() exception (continuing): $e');
        }

      case RecordingMode.mixed:
        try {
          await _recorder.stop();
          debugPrint('stopRecording: mic stopped for mixed mode');
        } catch (e) {
          debugPrint('stopRecording: mic stop exception in mixed: $e');
        }

        final sysResult = await SystemAudioService.stopCapture();
        debugPrint('stopRecording: sys audio stopped for mixed, result=$sysResult');
        durationMs = sysResult?['duration'] as int?;
    }

    // Give a small delay for the file to be fully written
    await Future.delayed(const Duration(milliseconds: 50));

    final recording = await _buildRecordingModel(durationMs);
    if (recording == null) {
      _reset();
      return null;
    }

    // For mixed mode, build system audio recording so provider can save it
    if (_currentMode == RecordingMode.mixed && _systemAudioFilePath != null) {
      _mixedSystemRecording = await _buildMixedSystemRecording(durationMs);
    } else {
      _mixedSystemRecording = null;
    }

    debugPrint('stopRecording: SUCCESS, recording=$recording\n  sysAudioPath=$_systemAudioFilePath');
    _state = RecorderState.idle;
    _recordingStartTime = null;
    _pausedDuration = Duration.zero;
    _pauseStartTime = null;
    _stateController.add(_state);
    return recording;
  }

  Future<RecordingModel?> _buildRecordingModel(int? durationMs) async {
    final file = File(_currentFilePath!);
    bool exists = false;

    for (int i = 0; i < 3; i++) {
      try {
        exists = await file.exists();
        if (exists) {
          debugPrint('stopRecording: file found at $_currentFilePath after $i attempts');
          break;
        }
        debugPrint('stopRecording: attempt $i - file not found, waiting...');
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        debugPrint('stopRecording: file.exists() exception: $e');
        break;
      }
    }

    if (!exists) {
      debugPrint('stopRecording: file not found at $_currentFilePath');
      try {
        final parentDir = file.parent;
        if (await parentDir.exists()) {
          final files = parentDir.listSync();
          debugPrint('stopRecording: files in ${parentDir.path}:');
          for (final f in files) {
            debugPrint('  - ${f.path}');
          }
        }
      } catch (e) {
        debugPrint('stopRecording: listing directory failed: $e');
      }
      return null;
    }

    int fileSize = 0;
    try {
      fileSize = await file.length();
      debugPrint('stopRecording: fileSize=$fileSize');
    } catch (e) {
      debugPrint('stopRecording: file.length() failed: $e');
    }

    final formatIdx = _currentMode == RecordingMode.systemOnly ? 1 : (_settings?.formatIndex ?? 4);
    debugPrint('stopRecording: building model, formatIndex=$formatIdx, mode=$_currentMode, settingsFormatIndex=${_settings?.formatIndex}');

    return RecordingModel(
      id: _uuid.v4(),
      name: p.basename(_currentFilePath!),
      filePath: _currentFilePath!,
      createdAt: _recordingStartTime ?? DateTime.now(),
      durationMs: durationMs ?? currentDuration.inMilliseconds,
      fileSize: fileSize,
      formatIndex: formatIdx,
      modeIndex: _currentMode.value,
      sampleRate: _settings?.sampleRate.value ?? 44100,
      bitRate: _settings?.bitRate.value ?? 128,
      channelIndex: _settings?.channelIndex ?? 0,
    );
  }

  Future<RecordingModel?> _buildMixedSystemRecording(int? durationMs) async {
    if (_systemAudioFilePath == null) return null;
    final file = File(_systemAudioFilePath!);
    if (!await file.exists()) return null;
    final fileSize = await file.length();
    return RecordingModel(
      id: _uuid.v4(),
      name: p.basename(_systemAudioFilePath!),
      filePath: _systemAudioFilePath!,
      createdAt: _recordingStartTime ?? DateTime.now(),
      durationMs: durationMs ?? 0,
      fileSize: fileSize,
      formatIndex: 1, // WAV
      modeIndex: RecordingMode.mixed.value,
      sampleRate: 44100,
      bitRate: 128,
      channelIndex: 1, // stereo
    );
  }

  Future<void> cancelRecording() async {
    if (_state == RecorderState.idle) return;

    _stopTimers();

    switch (_currentMode) {
      case RecordingMode.systemOnly:
        await SystemAudioService.stopCapture();
      case RecordingMode.microphoneOnly:
        try {
          await _recorder.stop();
        } catch (e) {
          debugPrint('cancelRecording: recorder.stop() exception: $e');
        }
      case RecordingMode.mixed:
        try {
          await _recorder.stop();
        } catch (e) {
          debugPrint('cancelRecording: mic stop exception: $e');
        }
        await SystemAudioService.stopCapture();
    }

    await _deleteCurrentFile();
    _reset();
  }

  Future<void> _deleteCurrentFile() async {
    if (_currentFilePath != null) {
      await FileUtils.deleteFile(_currentFilePath!);
    }
    if (_systemAudioFilePath != null) {
      await FileUtils.deleteFile(_systemAudioFilePath!);
    }
  }

  void _reset() {
    _currentFilePath = null;
    _systemAudioFilePath = null;
    _recordingStartTime = null;
    _pausedDuration = Duration.zero;
    _pauseStartTime = null;
    _state = RecorderState.idle;
    _stateController.add(_state);
    _stopTimers();
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _durationController.add(currentDuration);
    });
  }

  void _startAmplitudeTimer() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      if (_state == RecorderState.recording) {
        final amplitude = await _recorder.getAmplitude();
        final normalized = ((amplitude.current + 60) / 60).clamp(0.0, 1.0);
        _amplitudeController.add(normalized);
      }
    });
  }

  void _stopTimers() {
    _durationTimer?.cancel();
    _amplitudeTimer?.cancel();
    _durationTimer = null;
    _amplitudeTimer = null;
  }

  AudioEncoder _getEncoder(AudioFormat format) {
    switch (format) {
      case AudioFormat.mp3:
        return AudioEncoder.aacLc;
      case AudioFormat.wav:
        return AudioEncoder.wav;
      case AudioFormat.aac:
        return AudioEncoder.aacLc;
      case AudioFormat.m4a:
        return AudioEncoder.aacLc;
      case AudioFormat.flac:
        return AudioEncoder.flac;
    }
  }

  Future<void> dispose() async {
    _stopTimers();
    await _stateController.close();
    await _amplitudeController.close();
    await _durationController.close();
    _recorder.dispose();
  }
}

class RecordingException implements Exception {
  final String message;
  RecordingException(this.message);

  @override
  String toString() => message;
}