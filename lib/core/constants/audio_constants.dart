enum AudioFormat {
  mp3,
  wav,
  aac,
  m4a,
  flac,
}

extension AudioFormatExtension on AudioFormat {
  String get extension {
    switch (this) {
      case AudioFormat.mp3:
        return '.mp3';
      case AudioFormat.wav:
        return '.wav';
      case AudioFormat.aac:
        return '.aac';
      case AudioFormat.m4a:
        return '.m4a';
      case AudioFormat.flac:
        return '.flac';
    }
  }

  String get displayName {
    switch (this) {
      case AudioFormat.mp3:
        return 'MP3';
      case AudioFormat.wav:
        return 'WAV';
      case AudioFormat.aac:
        return 'AAC';
      case AudioFormat.m4a:
        return 'M4A';
      case AudioFormat.flac:
        return 'FLAC';
    }
  }

  String get mimeType {
    switch (this) {
      case AudioFormat.mp3:
        return 'audio/mpeg';
      case AudioFormat.wav:
        return 'audio/wav';
      case AudioFormat.aac:
        return 'audio/aac';
      case AudioFormat.m4a:
        return 'audio/mp4';
      case AudioFormat.flac:
        return 'audio/flac';
    }
  }
}

enum AudioSampleRate {
  hz8000(8000, '8000 Hz'),
  hz16000(16000, '16000 Hz'),
  hz44100(44100, '44100 Hz'),
  hz48000(48000, '48000 Hz');

  const AudioSampleRate(this.value, this.displayName);
  final int value;
  final String displayName;
}

enum AudioBitRate {
  kbps128(128, '128 kbps'),
  kbps256(256, '256 kbps'),
  kbps320(320, '320 kbps');

  const AudioBitRate(this.value, this.displayName);
  final int value;
  final String displayName;
}

enum AudioChannel {
  mono(1, '单声道'),
  stereo(2, '双声道');

  const AudioChannel(this.value, this.displayName);
  final int value;
  final String displayName;
}

enum RecordingMode {
  microphoneOnly(0, '仅麦克风', '🎤'),
  systemOnly(1, '仅系统声音', '🔊'),
  mixed(2, '混合录制', '🔊+🎤');

  const RecordingMode(this.value, this.displayName, this.icon);
  final int value;
  final String displayName;
  final String icon;

  bool get isSystemCaptureSupported {
    return false;
  }
}

extension RecordingModeExtension on RecordingMode {
  bool get requiresMediaProjection => this == RecordingMode.systemOnly;
}