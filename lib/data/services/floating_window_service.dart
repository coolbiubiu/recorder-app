import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class FloatingWindowService {
  static const MethodChannel _channel = MethodChannel('com.example.recoder_app/floating_window');
  static const EventChannel _eventChannel = EventChannel('com.example.recoder_app/floating_window_events');

  static Function(String)? onPausePressed;
  static Function(String)? onResumePressed;
  static Function(String)? onStopPressed;
  static Function(String)? onClosePressed;

  static StreamSubscription? _eventSubscription;

  static Future<bool> requestPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestOverlayPermission');
      return result ?? false;
    } catch (e) {
      debugPrint('Error requesting overlay permission: $e');
      return false;
    }
  }

  static Future<bool> checkPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkOverlayPermission');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking overlay permission: $e');
      return false;
    }
  }

  static Future<void> showFloatingWindow({
    required Duration duration,
    required bool isRecording,
    required bool isPaused,
  }) async {
    try {
      final args = {
        'duration': duration.inSeconds,
        'isRecording': isRecording,
        'isPaused': isPaused,
      };
      await _channel.invokeMethod('showFloatingWindow', args);
    } catch (e) {
      debugPrint('Error showing floating window: $e');
    }
  }

  static Future<void> updateFloatingWindow({
    Duration? duration,
    bool? isRecording,
    bool? isPaused,
  }) async {
    try {
      final args = <String, dynamic>{};
      if (duration != null) args['duration'] = duration.inSeconds;
      if (isRecording != null) args['isRecording'] = isRecording;
      if (isPaused != null) args['isPaused'] = isPaused;
      await _channel.invokeMethod('updateFloatingWindow', args);
    } catch (e) {
      debugPrint('Error updating floating window: $e');
    }
  }

  static Future<void> hideFloatingWindow() async {
    try {
      await _channel.invokeMethod('hideFloatingWindow');
    } catch (e) {
      debugPrint('Error hiding floating window: $e');
    }
  }

  static void setMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onPausePressed':
          onPausePressed?.call(call.arguments.toString());
          break;
        case 'onResumePressed':
          onResumePressed?.call(call.arguments.toString());
          break;
        case 'onStopPressed':
          onStopPressed?.call(call.arguments.toString());
          break;
        case 'onClosePressed':
          onClosePressed?.call(call.arguments.toString());
          break;
      }
    });
  }

  static void startListening(void Function(String) onEvent) {
    _eventSubscription?.cancel();
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is String) {
          debugPrint('FloatingWindowService received event: $event');
          onEvent(event);
        }
      },
      onError: (error) {
        debugPrint('FloatingWindowService error: $error');
      },
    );
  }

  static void stopListening() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }
}