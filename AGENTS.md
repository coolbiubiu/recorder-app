# Flutter 开发文档参考：
# - 桌面端 CMake 配置：https://docs.flutter.dev/development/platforms/windows/building
# - Linux 桌面开发：https://docs.flutter.dev/development/platforms/linux
# - Windows 桌面开发：https://docs.flutter.dev/development/platforms/windows

# 项目基础信息
project:
  name: recorder-app
  type: flutter_android # 项目类型：Flutter 安卓模块
  root: recorder-app/android/app # 规则生效的根目录

# 目录结构规范
directory_rules:
  # 强制目录结构，与代码库保持一致
  required_dirs:
    - src/main
    - src/debug
    - src/profile
  # 禁止创建的冗余目录
  forbidden_dirs:
    - src/test_unused
    - build_temp
    - .tmp

# 文件命名规则
file_naming_rules:
  # Gradle 配置文件命名
  - pattern: "^build\\.gradle\\.kts$"
    path: recorder-app/android/app/
    description: "安卓模块根目录的 Gradle 构建文件必须命名为 build.gradle.kts"
    severity: error # 违反则报错
  # 源码文件命名（驼峰式）
  - pattern: "^[A-Z][a-zA-Z0-9]*\\.(kt|java|xml)$"
    path: src/main/
    description: "main 目录下的源码/配置文件必须使用大驼峰命名"
    severity: warning # 违反则警告

# 代码规范规则
code_rules:
  # Kotlin 代码规范（适配安卓 Gradle 开发）
  kotlin:
    - rule: "禁止使用过时的 Android API"
      pattern: "android\\.os\\.AsyncTask"
      replacement: "使用 Coroutines 替代 AsyncTask"
      severity: error
    - rule: "Gradle 版本锁定"
      pattern: "com.android.tools.build:gradle:(\\d+\\.\\d+\\.\\d+)"
      allowed_values: ["7.4.2", "8.0.0"] # 限定支持的 Gradle 插件版本
      severity: error
  # Flutter 与安卓交互规范
  flutter_android:
    - rule: "禁止直接修改 FlutterActivity 源码"
      pattern: "class.*extends FlutterActivity\\s*\\{"
      description: "需通过继承 FlutterFragment 或自定义 Delegate 扩展"
      severity: warning
    - rule: "权限申请必须兼容 Android 13+"
      pattern: "Manifest.permission\\.(RECORD_AUDIO|WRITE_EXTERNAL_STORAGE)"
      required_check: "ContextCompat.checkSelfPermission"
      severity: error

# 构建规则
build_rules:
  # Gradle 构建约束
  gradle:
    - rule: "强制启用 R8 混淆"
      check_content: "minifyEnabled true"
      file: build.gradle.kts
      severity: error
    - rule: "指定 JDK 版本"
      check_content: "jdkVersion = JavaVersion.VERSION_17"
      file: build.gradle.kts
      severity: warning
  # 构建产物约束
  output:
    - rule: "APK 命名规范"
      pattern: "^recorder-app-v\\d+\\.\\d+\\.\\d+-(debug|release)\\.apk$"
      severity: error

# 忽略规则（无需检查的文件/目录）
ignore:
  - build/ # 忽略构建目录
  - .gradle/ # 忽略 Gradle 缓存
  - src/main/res/raw/ # 忽略原生资源文件
