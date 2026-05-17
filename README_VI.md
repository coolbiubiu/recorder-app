# Flutter Trình Ghi Âm Đa Nền Tảng

Ứng dụng ghi âm đa nền tảng nhẹ và không quảng cáo, hỗ trợ Android, iOS, Windows và macOS.

## Tính Năng

### 🎙️ Ba Chế Độ Ghi Âm
- **Chỉ micro**: Ghi âm giọng nói và âm thanh môi trường (phù hợp cho phỏng vấn, ghi chú)
- **Chỉ âm thanh hệ thống**: Ghi âm nội bộ của hệ thống (phù hợp cho khóa học trực tuyến, game, phim)
- **Ghi hỗn hợp**: Ghi đồng thời micro và âm thanh hệ thống (phù hợp cho bình luận, lồng tiếng)

### ⏯️ Chức Năng Cơ Bản
- Bắt đầu/Tạm dừng/Tiếp tục/Dừng ghi âm
- Hiển thị thời gian ghi âm thực tế
- Hình ảnh hóa dạng sóng âm thanh thực tế
- Hỗ trợ ghi âm nền
- Không giới hạn thời gian (chỉ giới hạn bởi bộ nhớ)

### ⚙️ Cài Đặt Âm Thanh
- Định dạng âm thanh: MP3, WAV, AAC, M4A
- Tần số lấy mẫu: 8000Hz / 16000Hz / 44100Hz / 48000Hz
- Bitrate: 128kbps / 256kbps / 320kbps
- Kênh: Mono / Stereo

### 📁 Quản Lý File
- Danh sách file ghi âm
- Tìm kiếm và sắp xếp file (theo thời gian/kích thước/thời lượng)
- Phát trực tuyến
- Đổi tên và xóa
- Chia sẻ file

### 🎨 Đặc Điểm Giao Diện
- Thiết kế tối giản, nhẹ
- Chế độ tối/sáng
- Tương thích nhiều kích thước màn hình

## Các Nền Tảng Được Hỗ Trợ

| Nền tảng | Phiên bản tối thiểu | Trạng thái |
|----------|---------------------|------------|
| Android | Android 8.0+ | ✅ |
| iOS | iOS 14.0+ | ✅ |
| Windows | Windows 10+ | Đang phát triển |
| macOS | macOS 11.0+ | Đang phát triển |

## Công Nghệ Sử Dụng

- **Framework**: Flutter 3.x
- **Quản lý trạng thái**: Provider
- **Lưu trữ cục bộ**: Hive
- **Ghi âm**: record
- **Phát âm thanh**: audioplayers
- **Quản lý quyền**: permission_handler

## Bắt Đầu

### Yêu Cầu Môi Trường
- Flutter SDK 3.0+
- Android SDK (để build Android)
- Xcode (để build iOS)

### Cài Đặt Phụ Thuộc

```bash
flutter pub get
```

### Chạy Ứng Dụng

```bash
# Chạy phiên bản debug
flutter run

# Build APK Android
flutter build apk --debug

# Build phiên bản release Android
flutter build apk --release

# Build cho iOS
flutter build ios --release
```

## Quyền Truy Cập

### Android
- `RECORD_AUDIO` - Quyền ghi âm
- `WRITE_EXTERNAL_STORAGE` - Quyền lưu trữ
- `READ_MEDIA_AUDIO` - Quyền đọc âm thanh
- `FOREGROUND_SERVICE` - Quyền dịch vụ nền

### iOS
- `NSMicrophoneUsageDescription` - Quyền micro
- `UIBackgroundModes: audio` - Âm thanh nền

## Giấy Phép

Dự án này chỉ được sử dụng cho mục đích học tập và trao đổi.

---

**Ngôn ngữ**:
- [English](./README.md)
- [한국어](./README_KO.md)
- [日本語](./README_JA.md)
- [Français](./README_FR.md)
- [Tiếng Việt](./README_VI.md)
- [中文](./README_ZH.md)