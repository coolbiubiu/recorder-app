import 'dart:async';
import 'package:audioplayers/audioplayers.dart' as audioplayers;

enum PlaybackState {
  idle,
  playing,
  paused,
  stopped,
}

class AudioPlayerService {
  final audioplayers.AudioPlayer _player = audioplayers.AudioPlayer();

  PlaybackState _state = PlaybackState.idle;
  String? _currentPath;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  final _stateController = StreamController<PlaybackState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  Stream<PlaybackState> get stateStream => _stateController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;

  PlaybackState get state => _state;
  String? get currentPath => _currentPath;
  Duration get duration => _duration;
  Duration get position => _position;

  AudioPlayerService() {
    _initListeners();
  }

  void _initListeners() {
    _playerStateSubscription = _player.onPlayerStateChanged.listen((state) {
      switch (state) {
        case audioplayers.PlayerState.playing:
          _state = PlaybackState.playing;
          break;
        case audioplayers.PlayerState.paused:
          _state = PlaybackState.paused;
          break;
        case audioplayers.PlayerState.stopped:
          _state = PlaybackState.stopped;
          break;
        case audioplayers.PlayerState.completed:
          _state = PlaybackState.idle;
          _position = Duration.zero;
          break;
        case audioplayers.PlayerState.disposed:
          _state = PlaybackState.idle;
          break;
      }
      _stateController.add(_state);
    });

    _positionSubscription = _player.onPositionChanged.listen((position) {
      _position = position;
      _positionController.add(position);
    });

    _durationSubscription = _player.onDurationChanged.listen((duration) {
      _duration = duration;
      _durationController.add(duration);
    });
  }

  Future<void> play(String path) async {
    if (_state == PlaybackState.playing && _currentPath == path) {
      return;
    }

    _currentPath = path;
    await _player.play(audioplayers.DeviceFileSource(path));
    _state = PlaybackState.playing;
    _stateController.add(_state);
  }

  Future<void> pause() async {
    if (_state != PlaybackState.playing) return;
    await _player.pause();
    _state = PlaybackState.paused;
    _stateController.add(_state);
  }

  Future<void> resume() async {
    if (_state != PlaybackState.paused) return;
    await _player.resume();
    _state = PlaybackState.playing;
    _stateController.add(_state);
  }

  Future<void> stop() async {
    await _player.stop();
    _state = PlaybackState.stopped;
    _position = Duration.zero;
    _currentPath = null;
    _stateController.add(_state);
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> dispose() async {
    await _playerStateSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _stateController.close();
    await _positionController.close();
    await _durationController.close();
    await _player.dispose();
  }
}