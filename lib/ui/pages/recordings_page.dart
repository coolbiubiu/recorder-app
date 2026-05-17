import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/recording_model.dart';
import '../../providers/recordings_provider.dart';
import '../widgets/recordings/recordings_list.dart';
import '../widgets/recordings/recording_search_bar.dart';
import 'player_page.dart';

class RecordingsPage extends StatefulWidget {
  const RecordingsPage({super.key});

  @override
  State<RecordingsPage> createState() => _RecordingsPageState();
}

class _RecordingsPageState extends State<RecordingsPage> {
  final _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelectionMode() {
    setState(() {
      if (_isSelectionMode) {
        _selectedIds.clear();
      }
      _isSelectionMode = !_isSelectionMode;
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll(List<RecordingModel> recordings) {
    setState(() {
      _selectedIds.addAll(recordings.map((r) => r.id));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除录音'),
        content: Text('确定要删除选中的 $count 个录音吗？\n此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<RecordingsProvider>();
      for (final id in _selectedIds.toList()) {
        await provider.deleteRecording(id);
      }
      _clearSelection();
      _toggleSelectionMode();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已删除 $count 个录音'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('已选择 ${_selectedIds.length} 项')
            : const Text('录音文件'),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleSelectionMode,
              )
            : null,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              tooltip: '全选',
              onPressed: () {
                final provider = context.read<RecordingsProvider>();
                _selectAll(provider.recordings);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: '删除',
              onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
            ),
          ] else ...[
            Consumer<RecordingsProvider>(
              builder: (context, provider, _) => IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '刷新',
                onPressed: () => provider.refreshRecordings(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.checklist),
              tooltip: '选择',
              onPressed: _toggleSelectionMode,
            ),
            _buildSortMenu(context),
          ],
        ],
      ),
      body: Column(
        children: [
          RecordingSearchBar(
            controller: _searchController,
            onChanged: (value) {
              context.read<RecordingsProvider>().setSearchKeyword(value);
            },
            onClear: () {
              context.read<RecordingsProvider>().clearSearch();
            },
          ),
          Expanded(
            child: Consumer<RecordingsProvider>(
              builder: (context, provider, _) {
                return RecordingsList(
                  recordings: provider.recordings,
                  isSelectionMode: _isSelectionMode,
                  selectedIds: _selectedIds,
                  onTap: (recording) {
                    if (_isSelectionMode) {
                      _toggleSelection(recording.id);
                    } else {
                      _openPlayer(context, recording);
                    }
                  },
                  onPlay: (recording) => _openPlayer(context, recording),
                  onDelete: (recording) => _showDeleteDialog(context, recording),
                  onShare: (recording) => _shareRecording(recording),
                  onRename: (recording) => _showRenameDialog(context, recording),
                  onLongPress: (recording) {
                    if (!_isSelectionMode) {
                      _toggleSelectionMode();
                    }
                    _toggleSelection(recording.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortMenu(BuildContext context) {
    return Consumer<RecordingsProvider>(
      builder: (context, provider, _) {
        return PopupMenuButton<SortType>(
          icon: const Icon(Icons.sort),
          tooltip: '排序',
          onSelected: (type) => provider.setSortType(type),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: SortType.date,
              child: Row(
                children: [
                  if (provider.sortType == SortType.date)
                    const Icon(Icons.check, size: 18),
                  const SizedBox(width: 8),
                  const Text('按时间排序'),
                ],
              ),
            ),
            PopupMenuItem(
              value: SortType.size,
              child: Row(
                children: [
                  if (provider.sortType == SortType.size)
                    const Icon(Icons.check, size: 18),
                  const SizedBox(width: 8),
                  const Text('按大小排序'),
                ],
              ),
            ),
            PopupMenuItem(
              value: SortType.duration,
              child: Row(
                children: [
                  if (provider.sortType == SortType.duration)
                    const Icon(Icons.check, size: 18),
                  const SizedBox(width: 8),
                  const Text('按时长排序'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _openPlayer(BuildContext context, RecordingModel recording) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerPage(recording: recording),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, RecordingModel recording) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除录音'),
        content: Text('确定要删除 "${recording.name}" 吗？\n此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<RecordingsProvider>().deleteRecording(recording.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('录音已删除'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _shareRecording(RecordingModel recording) async {
    await Share.shareXFiles(
      [XFile(recording.filePath)],
      text: '分享录音: ${recording.name}',
    );
  }

  void _showRenameDialog(BuildContext context, RecordingModel recording) {
    final controller = TextEditingController(text: recording.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '文件名',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.isNotEmpty) {
                final updated = recording.copyWith(name: controller.text);
                context.read<RecordingsProvider>().updateRecording(updated);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}