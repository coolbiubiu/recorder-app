# Flutter 跨平台音频录制器

一款轻量级、无广告的跨平台音频录制应用，支持 Android、iOS、Windows 和 macOS。

## 功能特点

### 🎙️ 三种录制模式
- **仅麦克风**：录制人声、环境音（适合访谈、笔记）
- **仅系统声音**：录制系统内部音频（适合网课、游戏、影视）
- **混合录制**：同时录制麦克风和系统声音（适合解说、配音）

### ⏯️ 基础功能
- 开始/暂停/继续/停止录制
- 实时录制时长显示
- 实时音频波形可视化
- 后台录制支持
- 无时长限制（仅受存储空间限制）

### ⚙️ 音频参数配置
- 音频格式：MP3、WAV、AAC、M4A
- 采样率：8000Hz / 16000Hz / 44100Hz / 48000Hz
- 比特率：128kbps / 256kbps / 320kbps
- 声道：单声道 / 双声道

### 📁 文件管理
- 录音文件列表
- 文件搜索和排序（按时间/大小/时长）
- 在线播放
- 重命名和删除
- 文件分享

### 🎨 界面特色
- 极简轻量化设计
- 深色/浅色模式
- 适配多屏幕尺寸

## 支持平台

| 平台 | 最低版本 | 状态 |
|------|---------|------|
| Android | Android 8.0+ | ✅ |
| iOS | iOS 14.0+ | ✅ |
| Windows | Windows 10+ | 开发中 |
| macOS | macOS 11.0+ | 开发中 |

## 技术栈

- **框架**：Flutter 3.x
- **状态管理**：Provider
- **本地存储**：Hive
- **音频录制**：record
- **音频播放**：audioplayers
- **权限管理**：permission_handler

## 开始使用

### 环境要求
- Flutter SDK 3.0+
- Android SDK（用于Android构建）
- Xcode（用于iOS构建）

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
# 运行调试版本
flutter run

# 构建Android APK
flutter build apk --debug

# 构建Android release版本
flutter build apk --release

# 构建iOS
flutter build ios --release
```

### 项目结构

```
lib/
├── main.dart                 # 应用入口
├── app.dart                  # 应用根组件
├── core/                     # 核心层
│   ├── constants/           # 常量定义
│   ├── theme/               # 主题配置
│   ├── utils/               # 工具类
│   └── extensions/          # 扩展方法
├── data/                    # 数据层
│   ├── models/              # 数据模型
│   ├── repositories/        # 数据仓库
│   └── services/            # 服务层
├── providers/               # 状态管理层
└── ui/                      # UI层
    ├── pages/              # 页面
    └── widgets/            # 组件
```

## 权限说明

### Android
- `RECORD_AUDIO` - 录音权限
- `WRITE_EXTERNAL_STORAGE` - 存储权限
- `READ_MEDIA_AUDIO` - 读取音频权限
- `FOREGROUND_SERVICE` - 后台服务权限

### iOS
- `NSMicrophoneUsageDescription` - 麦克风权限
- `UIBackgroundModes: audio` - 后台音频

## 开发说明

```bash
# 代码分析
flutter analyze

# 运行测试
flutter test

# 代码格式化
flutter format .
```

## 许可证

本项目仅供学习交流使用。

---

**语言版本**：
- [English](./README.md)
- [한국어](./README_KO.md)
- [日本語](./README_JA.md)
- [Français](./README_FR.md)
- [Tiếng Việt](./README_VI.md)
- [中文](./README_ZH.md)