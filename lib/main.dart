import 'package:flutter/material.dart';
import 'app.dart';
import 'data/services/log_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/permission_service.dart';
import 'data/services/floating_window_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.initialize();

  await LogService().initialize();

  final permissionService = PermissionService();
  await permissionService.requestAllPermissions();

  FloatingWindowService.setMethodCallHandler();

  runApp(RecorderApp(storageService: storageService));
}