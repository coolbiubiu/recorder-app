import 'package:flutter/material.dart';
import '../../../data/models/recording_model.dart';
import 'recording_tile.dart';

class RecordingsList extends StatelessWidget {
  final List<RecordingModel> recordings;
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final Function(RecordingModel)? onTap;
  final Function(RecordingModel)? onPlay;
  final Function(RecordingModel)? onDelete;
  final Function(RecordingModel)? onShare;
  final Function(RecordingModel)? onRename;
  final Function(RecordingModel)? onLongPress;

  const RecordingsList({
    super.key,
    required this.recordings,
    this.isSelectionMode = false,
    this.selectedIds = const {},
    this.onTap,
    this.onPlay,
    this.onDelete,
    this.onShare,
    this.onRename,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (recordings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.audiotrack_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无录音',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击上方按钮开始录制',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: recordings.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final recording = recordings[index];
        final isSelected = selectedIds.contains(recording.id);
        return RecordingTile(
          recording: recording,
          isSelected: isSelected,
          isSelectionMode: isSelectionMode,
          onTap: () => onTap?.call(recording),
          onPlay: isSelectionMode ? null : () => onPlay?.call(recording),
          onDelete: isSelectionMode ? null : () => onDelete?.call(recording),
          onShare: isSelectionMode ? null : () => onShare?.call(recording),
          onRename: isSelectionMode ? null : () => onRename?.call(recording),
          onLongPress: () => onLongPress?.call(recording),
        );
      },
    );
  }
}