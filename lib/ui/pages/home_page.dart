import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/audio_constants.dart';
import '../../data/models/recording_model.dart';
import '../../data/services/log_service.dart';
import '../../data/services/system_audio_service.dart';
import '../../providers/recorder_provider.dart';
import '../../providers/recordings_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/recorder/record_button.dart';
import '../widgets/recorder/mode_selector.dart';
import '../widgets/recorder/recording_timer.dart';
import '../widgets/recorder/audio_waveform.dart';
import 'settings_page.dart';
import 'recordings_page.dart';
import 'player_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecorderProvider>().initialize();
      context.read<RecordingsProvider>().loadRecordings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _RecorderView(),
          RecordingsPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            context.read<RecordingsProvider>().refreshRecordings();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mic_none),
            selectedIcon: Icon(Icons.mic),
            label: '录制',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: '文件',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}

class _RecorderView extends StatelessWidget {
  const _RecorderView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildModeSelector(context),
          const Spacer(),
          _buildRecorderControls(context),
          const Spacer(),
          _buildRecentRecordings(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            '音频录制器',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              final format = settings.audioFormat;
              final sampleRate = settings.sampleRate;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    format.displayName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    sampleRate.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(BuildContext context) {
    return Consumer<RecorderProvider>(
      builder: (context, recorder, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ModeSelector(
                selectedMode: recorder.currentMode,
                enabled: recorder.isIdle,
                onModeChanged: (mode) {
                  if (mode == RecordingMode.systemOnly) {
                    _handleSystemAudioModeSelection(context, recorder, mode);
                  } else {
                    recorder.setRecordingMode(mode);
                  }
                },
              ),
              if (recorder.currentMode == RecordingMode.systemOnly)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '注意：系统声音录制需要额外权限',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                        ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleSystemAudioModeSelection(
      BuildContext context, RecorderProvider recorder, RecordingMode mode) async {
    final hasPermission = await SystemAudioService.requestPermission();
    if (hasPermission) {
      recorder.setRecordingMode(mode);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('系统声音录制权限已获取'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      if (context.mounted) {
        _showPermissionDeniedDialog(context, recorder);
      }
    }
  }

  void _showPermissionDeniedDialog(BuildContext context, RecorderProvider recorder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('权限申请被拒绝'),
        content: const Text(
          '系统声音录制需要屏幕捕获权限。\n\n'
          '请在设置中授予权限：\n'
          '设置 → 应用 → 音频录制器 → 权限 → 屏幕录制 → 允许\n\n'
          '如果您的设备不支持此功能，系统声音录制将不可用。',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              recorder.setRecordingMode(RecordingMode.microphoneOnly);
            },
            child: const Text('使用麦克风模式'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('打开设置'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecorderControls(BuildContext context) {
    return Consumer<RecorderProvider>(
      builder: (context, recorder, _) {
        return Column(
          children: [
            RecordingTimer(
              duration: recorder.currentDuration,
              isRecording: recorder.isRecording,
            ),
            const SizedBox(height: 20),
            AudioWaveform(
              amplitude: recorder.amplitude,
              isActive: recorder.isRecording,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (recorder.isRecording || recorder.isPaused) ...[
                  IconButton(
                    onPressed: () => _showCancelDialog(context, recorder),
                    icon: const Icon(Icons.close),
                    iconSize: 32,
                  ),
                  const SizedBox(width: 40),
                ],
                RecordButton(
                  state: recorder.state,
                  onTap: () => _handleRecordTap(context, recorder),
                ),
                if (recorder.isRecording || recorder.isPaused) ...[
                  const SizedBox(width: 40),
                  IconButton(
                    onPressed: () => _stopRecording(context, recorder),
                    icon: const Icon(Icons.stop),
                    iconSize: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Text(
              recorder.isIdle
                  ? '点击开始录制'
                  : recorder.isRecording
                      ? recorder.canPause
                          ? '点击暂停'
                          : '录制中...'
                      : '点击继续',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentRecordings(BuildContext context) {
    return Consumer<RecordingsProvider>(
      builder: (context, recordingsProvider, _) {
        final recentRecordings = recordingsProvider.allRecordings.take(3).toList();

        if (recentRecordings.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '最近录音',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      DefaultTabController.of(context).animateTo(1);
                    },
                    child: const Text('查看全部'),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: recentRecordings.map((recording) {
                  return _RecentRecordingItem(
                    recording: recording,
                    onTap: () => _openPlayer(context, recording),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleRecordTap(BuildContext context, RecorderProvider recorder) async {
    if (recorder.isIdle) {
      try {
        final started = await recorder.startRecording();
        if (!started && context.mounted) {
          final errorMsg = recorder.lastError ?? '录音启动失败，请检查权限';
          LogService().error('录制按钮触发失败: $errorMsg');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        LogService().error('录音启动异常: $e');
        if (context.mounted) {
          _showSystemAudioNotSupportedDialog(context, recorder);
        }
      }
    } else if (recorder.isRecording) {
      await recorder.pauseRecording();
    } else if (recorder.isPaused) {
      await recorder.resumeRecording();
    }
  }

  void _showSystemAudioNotSupportedDialog(BuildContext context, RecorderProvider recorder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('系统声音录制暂不可用'),
        content: const Text(
          '当前版本暂不支持系统声音录制，仅支持麦克风录制。\n\n'
          '系统声音录制需要深层系统集成，功能开发中。\n\n'
          '请选择"仅麦克风"或"混合录制"模式。',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              recorder.setRecordingMode(RecordingMode.microphoneOnly);
            },
            child: const Text('使用麦克风模式'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Future<void> _stopRecording(
      BuildContext context, RecorderProvider recorder) async {
    final recording = await recorder.stopRecording();
    if (recording != null) {
      final recordingsProvider = context.read<RecordingsProvider>();
      recordingsProvider.addRecording(recording);

      // Also add the system audio recording for mixed mode
      final sysRecording = recorder.mixedSystemRecording;
      if (sysRecording != null) {
        recordingsProvider.addRecording(sysRecording);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('录音已保存: ${recording.name}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      debugPrint('_stopRecording: recording is null');
      LogService().warning('停止录音失败: recording 为 null');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存失败，请检查存储权限和空间'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showCancelDialog(BuildContext context, RecorderProvider recorder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消录制'),
        content: const Text('确定要取消当前录制吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('继续录制'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              recorder.cancelRecording();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('取消'),
          ),
        ],
      ),
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
}

class _RecentRecordingItem extends StatelessWidget {
  final RecordingModel recording;
  final VoidCallback? onTap;

  const _RecentRecordingItem({
    required this.recording,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.audiotrack),
      title: Text(
        recording.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${recording.mode.icon} ${recording.mode.displayName}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.play_circle_outline),
        onPressed: onTap,
      ),
    );
  }
}