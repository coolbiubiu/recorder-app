import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class SystemAudioService {
  static const MethodChannel _channel = MethodChannel('com.example.recoder_app/system_audio');

  static Future<bool> requestPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestSystemAudioPermission');
      debugPrint('SystemAudioService.requestPermission result: $result');
      return result ?? false;
    } catch (e) {
      debugPrint('Error requesting system audio permission: $e');
      return false;
    }
  }

  static Future<bool> checkPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkSystemAudioPermission');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking system audio permission: $e');
      return false;
    }
  }

  static Future<bool> isMediaProjectionAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isMediaProjectionAvailable');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking media projection: $e');
      return false;
    }
  }

  static Future<bool> startCapture(String outputPath) async {
    final result = await _channel.invokeMethod<bool>('startSystemAudioCapture', {'outputPath': outputPath});
    debugPrint('SystemAudioService.startCapture result: $result');
    return result ?? false;
  }

  static Future<Map<String, dynamic>?> stopCapture() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('stopSystemAudioCapture');
      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
      return null;
    } catch (e) {
      debugPrint('Error stopping system audio capture: $e');
      return null;
    }
  }

  static Future<int> getDuration() async {
    try {
      final result = await _channel.invokeMethod<int>('getSystemAudioDuration');
      return result ?? 0;
    } catch (e) {
      debugPrint('Error getting system audio duration: $e');
      return 0;
    }
  }

  static void setMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      debugPrint('SystemAudioService received: ${call.method}');
    });
  }
}