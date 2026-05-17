# Flutter クロスプラットフォーム音声レコーダー

軽量で広告のないクロスプラットフォーム音声録音アプリケーション。Android、iOS、Windows、macOSをサポート。

## 主な機能

### 🎙️ 3つの録音モード
- **マイクのみ**: 音声と環境音を録音（インタビュー、メモに適しています）
- **システム音のみ**: システム内部音声を録音（オンライン講義、ゲーム、映画に適しています）
- **混合録音**: マイクとシステム音を同時に録音（解説、声優作業に適しています）

### ⏯️ 基本機能
- 録音開始/一時停止/再開/停止
- リアルタイム録音時間表示
- リアルタイム音声波形視覚化
- バックグラウンド録音サポート
- 時間制限なし（保存容量のみ制限）

### ⚙️ 音声設定
- 音声形式: MP3, WAV, AAC, M4A
- サンプルレート: 8000Hz / 16000Hz / 44100Hz / 48000Hz
- ビットレート: 128kbps / 256kbps / 320kbps
- チャンネル: モノラル / ステレオ

### 📁 ファイル管理
- 録音ファイルリスト
- ファイル検索とソート（時間/サイズ/長さ順）
- オンライン再生
- 名前の変更と削除
- ファイル共有

### 🎨 インターフェース特徴
- シンプルで軽量な 디자인
- ダーク/ライトモード
-  다양한画面サイズに対応

## サポートプラットフォーム

| プラットフォーム | 最小バージョン | 状態 |
|----------------|---------------|------|
| Android | Android 8.0+ | ✅ |
| iOS | iOS 14.0+ | ✅ |
| Windows | Windows 10+ | 開発中 |
| macOS | macOS 11.0+ | 開発中 |

## 技術スタック

- **フレームワーク**: Flutter 3.x
- **状態管理**: Provider
- **ローカルストレージ**: Hive
- **音声録音**: record
- **音声再生**: audioplayers
- **権限管理**: permission_handler

## 始める前に

### 環境要件
- Flutter SDK 3.0+
- Android SDK（Androidビルド用）
- Xcode（iOSビルド用）

### 依存関係のインストール

```bash
flutter pub get
```

### アプリの実行

```bash
# デバッグバージョンを実行
flutter run

# Android APKをビルド
flutter build apk --debug

# Android リリースバージョンをビルド
flutter build apk --release

# iOSをビルド
flutter build ios --release
```

## 権限の説明

### Android
- `RECORD_AUDIO` - 録音権限
- `WRITE_EXTERNAL_STORAGE` - ストレージ権限
- `READ_MEDIA_AUDIO` - オーディオ読み取り権限
- `FOREGROUND_SERVICE` - バックグラウンドサービス権限

### iOS
- `NSMicrophoneUsageDescription` - マイク権限
- `UIBackgroundModes: audio` - バックグラウンドオーディオ

## ライセンス

本プロジェクトは学習交流目的のみに使用されます。

---

**言語バージョン**:
- [English](./README.md)
- [한국어](./README_KO.md)
- [日本語](./README_JA.md)
- [Français](./README_FR.md)
- [Tiếng Việt](./README_VI.md)
- [中文](./README_ZH.md)