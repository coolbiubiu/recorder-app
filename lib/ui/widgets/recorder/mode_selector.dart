import 'package:flutter/material.dart';
import '../../../core/constants/audio_constants.dart';

class ModeSelector extends StatelessWidget {
  final RecordingMode selectedMode;
  final ValueChanged<RecordingMode>? onModeChanged;
  final bool enabled;

  const ModeSelector({
    super.key,
    required this.selectedMode,
    this.onModeChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: RecordingMode.values.map((mode) {
          final isSelected = mode == selectedMode;

          return GestureDetector(
            onTap: enabled ? () => onModeChanged?.call(mode) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mode.icon,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    mode.displayName,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}