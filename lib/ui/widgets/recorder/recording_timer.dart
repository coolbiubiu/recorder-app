import 'package:flutter/material.dart';
import '../../../core/utils/duration_utils.dart';

class RecordingTimer extends StatelessWidget {
  final Duration duration;
  final bool isRecording;

  const RecordingTimer({
    super.key,
    required this.duration,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          DurationUtils.formatDurationWithHours(duration),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            color: isRecording
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).textTheme.headlineMedium?.color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isRecording ? '录制中...' : '已暂停',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isRecording
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
        ),
      ],
    );
  }
}