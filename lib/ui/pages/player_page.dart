import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart' as share_plus;
import '../../core/constants/audio_constants.dart';
import '../../core/utils/duration_utils.dart';
import '../../core/utils/file_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/recording_model.dart';
import '../../data/services/audio_player_service.dart';

class PlayerPage extends StatefulWidget {
  final RecordingModel recording;

  const PlayerPage({
    super.key,
    required this.recording,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late AudioPlayerService _playerService;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _playerService = AudioPlayerService();
    _initListeners();
    _play();
  }

  void _initListeners() {
    _playerService.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _playerService.durationStream.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });
  }

  void _play() {
    _playerService.play(widget.recording.filePath);
  }

  @override
  void dispose() {
    _playerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('播放录音'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _share,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAlbumArt(context),
            const SizedBox(height: 32),
            _buildTrackInfo(context),
            const SizedBox(height: 32),
            _buildProgressBar(),
            const SizedBox(height: 8),
            _buildTimeLabels(),
            const SizedBox(height: 24),
            _buildControls(context),
            const Spacer(),
            _buildInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumArt(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.audiotrack,
        size: 80,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildTrackInfo(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.recording.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.recording.mode.icon} ${widget.recording.mode.displayName}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final maxDuration =
        _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1.0;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      child: Slider(
        value: _position.inMilliseconds.toDouble().clamp(0, maxDuration),
        max: maxDuration,
        onChanged: (value) {
          _playerService.seek(Duration(milliseconds: value.toInt()));
        },
      ),
    );
  }

  Widget _buildTimeLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DurationUtils.formatDurationWithHours(_position),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            DurationUtils.formatDurationWithHours(
                _duration.inMilliseconds > 0 ? _duration : widget.recording.duration),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10),
          iconSize: 36,
          onPressed: () {
            final newPosition = _position - const Duration(seconds: 10);
            _playerService.seek(newPosition.isNegative ? Duration.zero : newPosition);
          },
        ),
        const SizedBox(width: 24),
        StreamBuilder<PlaybackState>(
          stream: _playerService.stateStream,
          builder: (context, snapshot) {
            final state = snapshot.data ?? PlaybackState.idle;
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              child: IconButton(
                icon: Icon(
                  state == PlaybackState.playing ? Icons.pause : Icons.play_arrow,
                ),
                iconSize: 48,
                color: Colors.white,
                onPressed: () {
                  if (state == PlaybackState.playing) {
                    _playerService.pause();
                  } else if (state == PlaybackState.paused) {
                    _playerService.resume();
                  } else {
                    _play();
                  }
                },
              ),
            );
          },
        ),
        const SizedBox(width: 24),
        IconButton(
          icon: const Icon(Icons.forward_10),
          iconSize: 36,
          onPressed: () {
            final newPosition = _position + const Duration(seconds: 10);
            final maxDuration = _duration.inMilliseconds > 0
                ? _duration
                : widget.recording.duration;
            _playerService.seek(
                newPosition > maxDuration ? maxDuration : newPosition);
          },
        ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            context,
            '创建时间',
            DateTimeUtils.formatForDisplay(widget.recording.createdAt),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            '文件大小',
            FileUtils.formatFileSize(widget.recording.fileSize),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            '音频格式',
            widget.recording.format.displayName,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            '采样率',
            '${widget.recording.sampleRate} Hz',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            '比特率',
            '${widget.recording.bitRate} kbps',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _share() async {
    await share_plus.Share.shareXFiles(
      [share_plus.XFile(widget.recording.filePath)],
      text: '分享录音: ${widget.recording.name}',
    );
  }
}