# Flutter跨平台音频录制APP 开发文档

## 一、项目基础说明

本项目基于**Flutter最新稳定版**开发一款轻量化音频录制工具APP，支持Android、iOS、Windows、macOS多端适配，核心差异化功能为**可自由选择录制模式：仅麦克风声音、仅手机/电脑系统内部声音、麦克风+系统声音混合录制**。APP主打简洁、轻量、无广告、低占用，专注音频录制核心能力，适配移动端、桌面端全平台兼容。

### 1.1 开发要求

- 纯Flutter实现，尽量使用成熟稳定的开源音频录制插件
- 规避原生嵌套冗余代码，代码结构分层清晰、注释完整
- 可直接编译打包，支持后续功能迭代

---

## 二、技术方案选型

### 2.1 核心插件选型

| 插件名称 | 版本 | 用途 | 备注 |
|---------|------|------|------|
| `flutter_audio_recorder` | ^0.5.0 | 基础录音功能 | 跨平台，支持暂停/恢复 |
| `record` | ^5.1.0 | 高级录音功能 | 支持系统内录、音频编码配置 |
| `audio_session` | ^0.1.18 | 音频会话管理 | iOS/Android音频焦点管理 |
| `path_provider` | ^2.1.2 | 文件路径获取 | 跨平台存储路径 |
| `permission_handler` | ^11.3.0 | 权限管理 | 统一权限申请 |
| `hive` | ^2.2.3 | 本地存储 | 高性能KV存储 |
| `hive_flutter` | ^1.1.0 | Hive Flutter集成 | |
| `provider` | ^6.1.2 | 状态管理 | 轻量级 |
| `uuid` | ^4.3.3 | 文件名生成 | 唯一ID |
| `intl` | ^0.19.0 | 日期格式化 | |
| `share_plus` | ^7.2.1 | 文件分享 | 跨平台分享 |
| `flutter_slidable` | ^3.1.0 | 滑动操作 | 列表项滑动操作 |
| `audioplayers` | ^6.0.0 | 音频播放 | 录音回放 |

### 2.2 技术栈总览

| 类别 | 技术选型 | 说明 |
|------|---------|------|
| 框架 | Flutter 3.x | 最新稳定版 |
| 状态管理 | Provider | 轻量、无依赖、官方推荐 |
| 本地存储 | Hive | 高性能、跨平台 |
| 权限管理 | permission_handler | 统一API |
| 音频录制 | record + audio_session | 系统内录+麦克风双音源 |
| 音频播放 | audioplayers | 稳定可靠 |

### 2.3 各平台系统音频录制方案

#### Android
- **系统内录**：使用 `AudioPlaybackCapture` API（Android 10+）
- **实现方式**：`record` 插件通过 platform channel 调用原生 `AudioRecord` 或 `AudioPlaybackCapture`
- **权限配置**：需 `RECORD_AUDIO`、`MODIFY_AUDIO_SETTINGS`

#### iOS
- **系统内录**：通过 `AVAudioSession` Category 配置实现
- **实现方式**：设置 `AVAudioSession.Category.playAndRecord` 并配置 `AVAudioSession.CategoryOption.mixWithOthers`
- **权限配置**：需 `NSMicrophoneUsageDescription`、`UIBackgroundModes`（audio）

#### Windows/macOS
- **系统内录**：使用平台原生音频抓取API（Windows Core Audio、macOS Core Audio）
- **实现方式**：`record` 插件已封装好跨平台实现

---

## 三、项目架构设计

### 3.1 目录结构

```
lib/
├── main.dart                      # 入口文件
├── app.dart                       # App根组件
├── core/                          # 核心层
│   ├── constants/                 # 常量定义
│   │   ├── app_constants.dart     # 应用常量
│   │   ├── audio_constants.dart   # 音频参数常量
│   │   └── storage_keys.dart      # 存储键名常量
│   ├── theme/                     # 主题配置
│   │   ├── app_theme.dart         # 应用主题
│   │   └── app_colors.dart        # 颜色配置
│   ├── utils/                     # 工具类
│   │   ├── date_utils.dart        # 日期工具
│   │   ├── file_utils.dart        # 文件工具
│   │   └── duration_utils.dart    # 时长工具
│   └── extensions/                # 扩展方法
│       └── context_extensions.dart
├── data/                          # 数据层
│   ├── models/                    # 数据模型
│   │   ├── recording_model.dart   # 录音文件模型
│   │   ├── recording_settings.dart# 录音设置模型
│   │   └── app_settings.dart      # 应用设置模型
│   ├── repositories/              # 数据仓库
│   │   ├── recording_repository.dart
│   │   └── settings_repository.dart
│   └── services/                  # 服务层
│       ├── audio_recorder_service.dart  # 录音服务
│       ├── audio_player_service.dart    # 播放服务
│       ├── storage_service.dart         # 存储服务
│       └── permission_service.dart      # 权限服务
├── providers/                     # 状态管理层
│   ├── recorder_provider.dart     # 录音状态
│   ├── recordings_provider.dart    # 录音列表
│   ├── settings_provider.dart      # 设置状态
│   └── theme_provider.dart         # 主题状态
├── ui/                            # UI层
│   ├── pages/                     # 页面
│   │   ├── home_page.dart         # 主页
│   │   ├── recordings_page.dart   # 录音列表页
│   │   ├── settings_page.dart     # 设置页
│   │   └── player_page.dart       # 播放页面
│   └── widgets/                   # 组件
│       ├── recorder/              # 录音相关组件
│       │   ├── record_button.dart
│       │   ├── mode_selector.dart
│       │   ├── recording_timer.dart
│       │   └── audio_waveform.dart
│       ├── recordings/            # 录音列表组件
│       │   ├── recording_tile.dart
│       │   ├── recordings_list.dart
│       │   └── recording_search_bar.dart
│       └── common/                # 通用组件
│           ├── app_slider.dart
│           ├── app_switch.dart
│           └── confirm_dialog.dart
└── platform/                      # 平台特定代码
    └── channel/                   # Platform Channel
        └── audio_channel.dart
```

### 3.2 分层架构说明

```
┌─────────────────────────────────────────┐
│              UI层 (ui/)                  │
│  - Pages: 页面组件                        │
│  - Widgets: 可复用UI组件                  │
├─────────────────────────────────────────┤
│           状态管理层 (providers/)         │
│  - Provider: 状态管理                    │
│  - 依赖 services 层提供的能力              │
├─────────────────────────────────────────┤
│            服务层 (data/services/)        │
│  - 核心业务逻辑封装                        │
│  - 录音服务、播放服务、存储服务、权限服务    │
├─────────────────────────────────────────┤
│            数据层 (data/)                │
│  - Models: 数据模型                       │
│  - Repositories: 数据仓库                 │
├─────────────────────────────────────────┤
│            核心层 (core/)                │
│  - Constants: 常量定义                    │
│  - Theme: 主题配置                        │
│  - Utils: 工具类                          │
│  - Extensions: 扩展方法                   │
└─────────────────────────────────────────┘
```

### 3.3 数据流设计

```
用户操作 → Provider(状态) → Service(业务) → Repository(数据) → Storage/Hive

状态订阅: Provider.notifyListeners() → UI自动更新
```

---

## 四、数据模型设计

### 4.1 RecordingModel（录音文件模型）

```dart
class RecordingModel {
  final String id;              // 唯一标识
  final String name;             // 文件名
  final String filePath;         // 文件路径
  final DateTime createdAt;      // 创建时间
  final Duration duration;       // 时长
  final int fileSize;            // 文件大小(字节)
  final AudioFormat format;      // 音频格式
  final RecordingMode mode;      // 录制模式
  final int sampleRate;          // 采样率
  final int bitRate;             // 比特率
  final AudioChannel channel;    // 声道
}
```

### 4.2 RecordingSettings（录音设置模型）

```dart
class RecordingSettings {
  final AudioFormat format;     // MP3/WAV
  final int sampleRate;         // 8000/16000/44100/48000
  final int bitRate;            // 128/256/320 kbps
  final AudioChannel channel;    // mono/stereo
  final RecordingMode lastMode;  // 上次使用的录制模式
}
```

### 4.3 AppSettings（应用设置模型）

```dart
class AppSettings {
  final bool isDarkMode;
  final String savePath;
  final bool autoSaveEnabled;
  final RecordingSettings recordingSettings;
}
```

### 4.4 RecordingMode（录制模式枚举）

```dart
enum RecordingMode {
  microphoneOnly,  // 仅麦克风
  systemOnly,      // 仅系统声音
  mixed,           // 混合录制
}
```

---

## 五、核心功能详细设计

### 5.1 三大录制模式（核心功能）

#### 模式1：仅麦克风录制
- **技术实现**：使用 `record` 插件的 `RecordConfig` 配置 `device: InputDevice.microphone`
- **应用场景**：人声录音、访谈、笔记记录

#### 模式2：仅系统声音录制
- **技术实现**：
  - Android：使用 `AudioPlaybackCapture` API，需要用户授权「内容捕获」权限
  - iOS：配置 `AVAudioSession` 为仅播放模式 + 系统音频路由
  - Desktop：通过平台API抓取系统音频输出
- **应用场景**：网课、直播、影视剧、游戏音效

#### 模式3：混合录制
- **技术实现**：同时启用麦克风输入和系统音频抓取，双轨道独立录制后混音
- **关键配置**：确保两个音频源时间戳同步，使用同一时钟源
- **应用场景**：解说录屏、网课配音、游戏解说

### 5.2 基础录制操作

| 操作 | 状态转换 | UI反馈 |
|------|---------|--------|
| 开始录制 | idle → recording | 按钮变化+波形动画启动 |
| 暂停录制 | recording → paused | 波形暂停+计时暂停 |
| 继续录制 | paused → recording | 恢复动画+继续计时 |
| 停止录制 | recording/paused → idle | 保存文件+刷新列表 |

### 5.3 录制参数配置项

| 参数 | 可选值 | 默认值 | 说明 |
|------|-------|-------|------|
| 音频格式 | MP3, WAV | MP3 | WAV为无损但文件大 |
| 采样率 | 8000, 16000, 44100, 48000 Hz | 44100 | 语音8000-16000即可 |
| 比特率 | 128, 256, 320 kbps | 128 | 越高音质越好 |
| 声道 | mono, stereo | mono | 语音用单声道即可 |

---

## 六、UI/UX详细设计

### 6.1 页面流程图

```
启动APP
    ↓
┌─────────────────┐
│   首页(录制页)   │ ←────────────────┐
│                 │                   │
│ ┌─────────────┐ │                   │
│ │ 模式选择栏   │ │                   │
│ └─────────────┘ │                   │
│                 │                   │
│ ┌─────────────┐ │                   │
│ │  录制按钮   │ │                   │
│ └─────────────┘ │                   │
│                 │                   │
│ ┌─────────────┐ │   ┌───────────┐  │
│ │ 录音文件列表 │─┼──→│ 播放页面  │  │
│ └─────────────┘ │   └───────────┘  │
│                 │                   │
│ [设置] [文件列表]│                   │
└─────────────────┘
         │
         ├────────────→┌─────────────┐
         │             │  录音列表页  │
         │             │             │
         │             │ 搜索/排序   │
         │             │ 文件管理    │
         │             └─────────────┘
         │
         └────────────→┌─────────────┐
                       │   设置页    │
                       │             │
                       │ 音频参数    │
                       │ 保存路径    │
                       │ 主题设置    │
                       └─────────────┘
```

### 6.2 首页布局（主录制页面）

```
┌────────────────────────────────────┐
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  ← 状态栏
├────────────────────────────────────┤
│                                    │
│     ┌──────────────────────┐      │
│     │    当前模式: 混合录制   │      │  ← 模式选择器
│     │  🎤 麦克风 │🔊系统│🔊+🎤混合│      │
│     └──────────────────────┘      │
│                                    │
│                                    │
│           ┌──────────┐             │
│           │          │             │
│           │    ⏺️     │             │  ← 录制按钮(大)
│           │          │             │
│           └──────────┘             │
│                                    │
│         ⏱️ 00:15:32                │  ← 录制计时器
│         📊 44100Hz | 128kbps       │  ← 音频参数
│         💾 2.3MB                   │  ← 文件大小
│                                    │
│  ～～～～～～～～～～～～～～～～～～  │  ← 音频波形(可选)
│                                    │
├────────────────────────────────────┤
│  最近录音                          │
│  ┌──────────────────────────────┐  │
│  │ 📄 录音_20260112_143052.mp3  │  │
│  │    01:23:45 │ 2.3MB │ 混合   │  │
│  └──────────────────────────────┘  │
│         [查看全部]                  │
├────────────────────────────────────┤
│  🏠首页  │  📁文件  │  ⚙️设置      │  ← 底部导航
└────────────────────────────────────┘
```

### 6.3 状态UI设计

| 状态 | 主按钮 | 计时器 | 波形 | 提示文字 |
|------|-------|-------|------|---------|
| 空闲 | 🔴 红色圆点 | --:--:-- | 静止 | 点击开始录制 |
| 录制中 | ⏸️ 暂停图标 | 实时跳动 | 动态波形 | 录制中... |
| 暂停 | ▶️ 继续图标 | 暂停 | 静止 | 已暂停 |

### 6.4 配色方案

| 用途 | 浅色模式 | 深色模式 |
|------|---------|---------|
| 主色 | #4CAF50 (绿色) | #66BB6A |
| 录制中 | #F44336 (红色) | #EF5350 |
| 暂停 | #FF9800 (橙色) | #FFA726 |
| 背景 | #FAFAFA | #121212 |
| 卡片 | #FFFFFF | #1E1E1E |
| 文字主 | #212121 | #FFFFFF |
| 文字次 | #757575 | #B0B0B0 |

---

## 七、权限配置详细方案

### 7.1 Android权限清单

**AndroidManifest.xml**
```xml
<!-- 基础录音权限 -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- 存储权限 -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- Android 13+ 照片/视频/音频权限 -->
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

<!-- 后台录制权限 -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />

<!-- 系统内录权限(Android 10+) -->
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />

<!-- 录音期间屏幕保持 -->
<uses-permission android:name="android.permission.keep_screen_on" />
```

### 7.2 iOS权限配置

**Info.plist**
```xml
<!-- 麦克风权限 -->
<key>NSMicrophoneUsageDescription</key>
<string>需要麦克风权限来录制音频</string>

<!-- 后台音频模式 -->
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

### 7.3 Windows权限配置

- 使用WASAPI抓取系统音频
- 无特殊权限要求，应用安装后自动获取音频设备访问权限

### 7.4 macOS权限配置

**Entitlements**
```xml
<key>com.apple.security.device.audio-input</key>
<true/>
```

### 7.5 权限申请流程

```
启动APP
    ↓
检测权限状态
    ↓
┌─────────────────┐
│ 权限已授予?      │
└─────────────────┘
    ↓Yes           ↓No
   继续启动    显示权限申请弹窗
                    ↓
            用户授权/拒绝
                    ↓
            ┌───────────────┐
            │  拒绝? 显示   │
            │  手动开启引导  │
            └───────────────┘
                    ↓
                继续启动
```

---

## 八、异常处理与边界场景

### 8.1 异常场景处理

| 异常场景 | 检测方式 | 处理策略 |
|---------|---------|---------|
| 麦克风被占用 | `RecorderPlatform.start()` 异常 | 弹窗提示，等待释放 |
| 存储空间不足 | 写入前检查 `/data` 分区可用空间 | 提前检查，低于100MB警告 |
| 录制被系统中断 | `onStateChanged` 监听 | 自动暂停+缓存，提示用户 |
| 后台进程被杀 | ActivityLifecycle | 紧急保存到临时文件 |
| 权限被撤销 | `PermissionStatus` 变更监听 | 停止录制+弹窗提示 |
| 文件损坏 | 打开文件失败 | 删除损坏文件+提示 |

### 8.2 录音中断恢复机制

```
录音过程中断
    │
    ├─ 收到系统中断（如电话）
    │       │
    │       ├─ 保存当前录制到临时文件
    │       ├─ 状态改为 paused
    │       └─ 中断结束后提示恢复
    │
    ├─ APP被强杀
    │       │
    │       ├─ 定期保存缓存（如每30秒）
    │       └─ 重启后检查临时文件，恢复录制
    │
    └─ 手动取消
            │
            └─ 删除临时文件
```

### 8.3 缓存策略

- 录制过程中每30秒自动保存一次缓存
- 缓存文件格式：`.tempRecording`
- 正常停止后删除缓存文件
- 异常中断后保留缓存，恢复时询问用户

---

## 九、测试方案

### 9.1 单元测试

| 测试对象 | 测试内容 |
|---------|---------|
| RecordingModel | 序列化/反序列化 |
| RecordingSettings | 默认值验证 |
| RecordingRepository | CRUD操作 |
| AudioRecorderService | 开始/暂停/停止/状态转换 |
| FileUtils | 文件大小格式化、路径处理 |

### 9.2 集成测试

| 测试场景 | 预期结果 |
|---------|---------|
| 完整录制流程 | 录音→暂停→继续→停止→文件存在 |
| 模式切换 | 三种模式切换正常 |
| 后台录制 | 切后台不中断 |
| 权限拒绝处理 | 弹窗提示+引导 |
| 多文件管理 | 增删改查正常 |

---

## 十、性能优化建议

### 10.1 内存优化

- 使用 `Stream` 而非轮询获取录音状态
- 波形数据限制缓冲区大小（如保留1000个采样点）
- 列表使用 `ListView.builder` 懒加载

### 10.2 电量优化

- 后台录制使用 `Isolate` 处理音频编码
- 屏幕关闭时减少UI更新频率
- 合理使用 `WakeLock` 而非持续唤醒

### 10.3 后台保活

- Android：使用 Foreground Service + 通知
- iOS：配置 `UIBackgroundModes: audio`
- Desktop：无特殊要求

---

## 十一、安全考虑

### 11.1 隐私保护

- 所有录音文件仅本地存储
- 不上传任何数据到服务器
- 删除操作直接删除文件，无回收站

### 11.2 文件安全

- 录音文件名使用UUID，防止猜测
- 可选：录音文件加密存储（AES）
- 分享时复制到临时目录，分享完成后删除

---

## 十二、多端适配细节

### 12.1 Android适配要点

| 项目 | 要求 |
|------|-----|
| 最低版本 | Android 8.0 (API 26) |
| 目标版本 | Android 14 (API 34) |
| 系统内录 | 仅Android 10+ |
| 后台录制 | 需要 Foreground Service |

### 12.2 iOS适配要点

| 项目 | 要求 |
|------|-----|
| 最低版本 | iOS 14.0 |
| 系统内录 | 需要特殊Entitlements |
| 后台录制 | 需要 UIBackgroundModes |

### 12.3 Windows适配要点

| 项目 | 要求 |
|------|-----|
| 最低版本 | Windows 10 (1809+) |
| 音频API | WASAPI |
| 窗口缩放 | 支持 |

### 12.4 macOS适配要点

| 项目 | 要求 |
|------|-----|
| 最低版本 | macOS 11.0+ |
| 音频API | Core Audio |
| 权限 | 需要 microphone entitlement |

---

## 十三、交付物清单

1. **完整Flutter项目源码** - 符合上述架构设计
2. **可运行测试包** - APK/IPA/exe/dmg
3. **开发说明文档** - 本文档
4. **环境配置指南** - 各平台SDK配置
5. **打包教程** - 各平台打包命令

---

## 十四、开发里程碑

| 阶段 | 任务 | 优先级 |
|------|-----|-------|
| Phase 1 | 项目初始化 + 基础框架搭建 | P0 |
| Phase 2 | 录音核心功能（单模麦克风） | P0 |
| Phase 3 | 三种录制模式实现 | P0 |
| Phase 4 | 录音文件管理 | P1 |
| Phase 5 | 权限处理与异常保护 | P1 |
| Phase 6 | 多端适配与UI优化 | P1 |
| Phase 7 | 高级功能（后台录制、波形显示） | P2 |
| Phase 8 | 性能优化与测试 | P2 |

---

> 文档版本: 1.1
> 最后更新: 2026-05-12
> 注：文档内容可能由AI辅助生成与完善