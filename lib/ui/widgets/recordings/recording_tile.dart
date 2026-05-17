import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/utils/duration_utils.dart';
import '../../../core/utils/file_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/recording_model.dart';

class RecordingTile extends StatelessWidget {
  final RecordingModel recording;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onRename;
  final VoidCallback? onLongPress;

  const RecordingTile({
    super.key,
    required this.recording,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onTap,
    this.onPlay,
    this.onDelete,
    this.onShare,
    this.onRename,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      enabled: !isSelectionMode,
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onRename?.call(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: '重命名',
          ),
          SlidableAction(
            onPressed: (_) => onShare?.call(),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: '分享',
          ),
          SlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '删除',
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: isSelectionMode
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => onTap?.call(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            : Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.audiotrack,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
        title: Text(
          recording.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${DateTimeUtils.getRelativeTime(recording.createdAt)} • '
          '${DurationUtils.formatDuration(recording.duration)} • '
          '${FileUtils.formatFileSize(recording.fileSize)}',
        ),
        trailing: isSelectionMode
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      recording.mode.icon,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill),
                    onPressed: onPlay,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
      ),
    );
  }
}