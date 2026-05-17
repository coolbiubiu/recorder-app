# Flutter 크로스 플랫폼 오디오 레코더

가볍고 광고 없는 크로스 플랫폼 오디오录制 애플리케이션. Android, iOS, Windows 및 macOS를 지원합니다.

## 주요 기능

### 🎙️ 세 가지 녹음 모드
- **마이크만**: 음성 및 환경음 녹음 (인터뷰, 메모에 적합)
- **시스템 소리만**: 시스템 내부 오디오 녹음 (온라인 강의, 게임, 영화에 적합)
- **혼합 녹음**: 마이크와 시스템 소리 동시 녹음 (해설, 더빙에 적합)

### ⏯️ 기본 기능
- 녹음 시작/일시정지/계속/중지
- 실시간 녹음 시간 표시
- 실시간 오디오 파형 시각화
- 백그라운드 녹음 지원
- 시간 제한 없음 (저장 공간만 제한)

### ⚙️ 오디오 설정
- 오디오 형식: MP3, WAV, AAC, M4A
- 샘플레이트: 8000Hz / 16000Hz / 44100Hz / 48000Hz
- 비트레이트: 128kbps / 256kbps / 320kbps
- 채널: 모노 / 스테레오

### 📁 파일 관리
- 녹음 파일 목록
- 파일 검색 및 정렬 (시간/크기/길이순)
- 온라인 재생
- 이름 변경 및 삭제
- 파일 공유

### 🎨 인터페이스 특징
- 간결하고 가벼운 디자인
- 다크/라이트 모드
- 다양한 화면 크기 지원

## 지원 플랫폼

| 플랫폼 | 최소 버전 | 상태 |
|--------|----------|------|
| Android | Android 8.0+ | ✅ |
| iOS | iOS 14.0+ | ✅ |
| Windows | Windows 10+ | 개발 중 |
| macOS | macOS 11.0+ | 개발 중 |

## 기술 스택

- **프레임워크**: Flutter 3.x
- **상태 관리**: Provider
- **로컬 저장소**: Hive
- **오디오 녹음**: record
- **오디오 재생**: audioplayers
- **권한 관리**: permission_handler

## 시작하기

### 환경 요구사항
- Flutter SDK 3.0+
- Android SDK (Android 빌드용)
- Xcode (iOS 빌드용)

### 의존성 설치

```bash
flutter pub get
```

### 앱 실행

```bash
# 디버그 버전 실행
flutter run

# Android APK 빌드
flutter build apk --debug

# Android 릴리스 빌드
flutter build apk --release

# iOS 빌드
flutter build ios --release
```

## 권한 설명

### Android
- `RECORD_AUDIO` - 녹음 권한
- `WRITE_EXTERNAL_STORAGE` - 저장 권한
- `READ_MEDIA_AUDIO` - 오디오 읽기 권한
- `FOREGROUND_SERVICE` - 백그라운드 서비스 권한

### iOS
- `NSMicrophoneUsageDescription` - 마이크 권한
- `UIBackgroundModes: audio` - 백그라운드 오디오

## 라이선스

본 프로젝트는 학습 및交流 목적으로만 사용됩니다.

---

**언어 버전**:
- [English](./README.md)
- [한국어](./README_KO.md)
- [日本語](./README_JA.md)
- [Français](./README_FR.md)
- [Tiếng Việt](./README_VI.md)
- [中文](./README_ZH.md)