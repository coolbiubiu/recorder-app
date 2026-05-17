import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/audio_recorder_service.dart';

class RecordButton extends StatelessWidget {
  final RecorderState state;
  final VoidCallback? onTap;

  const RecordButton({
    super.key,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getBackgroundColor(),
          boxShadow: [
            BoxShadow(
              color: _getBackgroundColor().withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: _buildIcon(),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (state) {
      case RecorderState.idle:
        return AppColors.recording;
      case RecorderState.recording:
        return AppColors.recording;
      case RecorderState.paused:
        return AppColors.paused;
    }
  }

  Widget _buildIcon() {
    switch (state) {
      case RecorderState.idle:
        return const Icon(
          Icons.mic,
          color: Colors.white,
          size: 36,
        );
      case RecorderState.recording:
        return const Icon(
          Icons.pause,
          color: Colors.white,
          size: 36,
        );
      case RecorderState.paused:
        return const Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 36,
        );
    }
  }
}