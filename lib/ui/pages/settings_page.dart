import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/audio_constants.dart';
import '../../data/services/floating_window_service.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import 'log_viewer_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            children: [
              _buildSectionHeader(context, '音频参数'),
              _buildFormatTile(context, settings),
              _buildSampleRateTile(context, settings),
              _buildBitRateTile(context, settings),
              _buildChannelTile(context, settings),
              const Divider(),
              _buildSectionHeader(context, '录制'),
              _buildFloatingWindowTile(context),
              const Divider(),
              _buildSectionHeader(context, '存储'),
              _buildSavePathTile(context, settings),
              const Divider(),
              _buildSectionHeader(context, '外观'),
              _buildThemeTile(context),
              const Divider(),
              _buildSectionHeader(context, '调试'),
              _buildLogViewerTile(context),
              const Divider(),
              _buildSectionHeader(context, '关于'),
              _buildAboutTile(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildFormatTile(BuildContext context, SettingsProvider settings) {
    return ListTile(
      title: const Text('音频格式'),
      subtitle: Text(settings.audioFormat.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showFormatPicker(context, settings),
    );
  }

  Widget _buildSampleRateTile(BuildContext context, SettingsProvider settings) {
    return ListTile(
      title: const Text('采样率'),
      subtitle: Text(settings.sampleRate.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showSampleRatePicker(context, settings),
    );
  }

  Widget _buildBitRateTile(BuildContext context, SettingsProvider settings) {
    return ListTile(
      title: const Text('比特率'),
      subtitle: Text(settings.bitRate.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showBitRatePicker(context, settings),
    );
  }

  Widget _buildChannelTile(BuildContext context, SettingsProvider settings) {
    return ListTile(
      title: const Text('声道'),
      subtitle: Text(settings.channel.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showChannelPicker(context, settings),
    );
  }

  Widget _buildFloatingWindowTile(BuildContext context) {
    return FutureBuilder<bool>(
      future: FloatingWindowService.checkPermission(),
      builder: (context, snapshot) {
        final hasPermission = snapshot.data ?? false;
        return ListTile(
          title: const Text('悬浮窗'),
          subtitle: Text(
            hasPermission ? '录制时显示悬浮控制窗口' : '需要授权才能使用',
          ),
          trailing: hasPermission
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.error_outline, color: Colors.orange),
          onTap: () => _checkOverlayPermission(context, hasPermission),
        );
      },
    );
  }

  Future<void> _checkOverlayPermission(BuildContext context, bool hasPermission) async {
    if (!hasPermission) {
      final granted = await FloatingWindowService.requestPermission();
      if (context.mounted) {
        if (granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('悬浮窗权限已授予'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('请在设置中授予悬浮窗权限'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('悬浮窗功能已启用，录制时将自动显示'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildSavePathTile(BuildContext context, SettingsProvider settings) {
    final savePath = settings.savePath;
    final displayPath = savePath.isEmpty ? '默认位置' : savePath;
    return ListTile(
      title: const Text('保存位置'),
      subtitle: Text(
        displayPath,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _pickSavePath(context, settings),
    );
  }

  Future<void> _pickSavePath(BuildContext context, SettingsProvider settings) async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '选择录音保存位置',
    );
    if (result != null) {
      await settings.setSavePath(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存位置已更新'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildThemeTile(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return SwitchListTile(
          title: const Text('深色模式'),
          subtitle: const Text('切换深色/浅色主题'),
          value: themeProvider.isDarkMode,
          onChanged: (value) => themeProvider.setThemeMode(
            value ? ThemeMode.dark : ThemeMode.light,
          ),
        );
      },
    );
  }

  Widget _buildLogViewerTile(BuildContext context) {
    return ListTile(
      title: const Text('错误日志'),
      subtitle: const Text('查看应用运行日志'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LogViewerPage()),
        );
      },
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return ListTile(
      title: const Text('关于'),
      subtitle: const Text('版本 1.0.0'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: '音频录制器',
          applicationVersion: '1.0.0',
          applicationLegalese: '© 2026 Flutter跨平台音频录制APP',
        );
      },
    );
  }

  void _showFormatPicker(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('选择音频格式'),
        children: AudioFormat.values.map((format) {
          return RadioListTile<AudioFormat>(
            title: Text(format.displayName),
            value: format,
            groupValue: settings.audioFormat,
            onChanged: (value) {
              if (value != null) {
                settings.setAudioFormat(value);
                Navigator.pop(context);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  void _showSampleRatePicker(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('选择采样率'),
        children: AudioSampleRate.values.map((rate) {
          return RadioListTile<AudioSampleRate>(
            title: Text(rate.displayName),
            value: rate,
            groupValue: settings.sampleRate,
            onChanged: (value) {
              if (value != null) {
                settings.setSampleRate(value);
                Navigator.pop(context);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  void _showBitRatePicker(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('选择比特率'),
        children: AudioBitRate.values.map((rate) {
          return RadioListTile<AudioBitRate>(
            title: Text(rate.displayName),
            value: rate,
            groupValue: settings.bitRate,
            onChanged: (value) {
              if (value != null) {
                settings.setBitRate(value);
                Navigator.pop(context);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  void _showChannelPicker(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('选择声道'),
        children: AudioChannel.values.map((channel) {
          return RadioListTile<AudioChannel>(
            title: Text(channel.displayName),
            value: channel,
            groupValue: settings.channel,
            onChanged: (value) {
              if (value != null) {
                settings.setChannel(value);
                Navigator.pop(context);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}