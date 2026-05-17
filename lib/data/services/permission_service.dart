import 'package:permission_handler/permission_handler.dart' as ph;

class PermissionService {
  Future<bool> checkMicrophonePermission() async {
    final status = await ph.Permission.microphone.status;
    return status.isGranted;
  }

  Future<bool> checkStoragePermission() async {
    if (await ph.Permission.manageExternalStorage.status.isGranted) {
      return true;
    }
    final status = await ph.Permission.storage.status;
    return status.isGranted;
  }

  Future<bool> checkBackgroundAudioPermission() async {
    return true;
  }

  Future<PermissionResult> requestMicrophonePermission() async {
    final status = await ph.Permission.microphone.request();

    if (status.isGranted) {
      return PermissionResult.granted;
    } else if (status.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    } else {
      return PermissionResult.denied;
    }
  }

  Future<PermissionResult> requestStoragePermission() async {
    final manageStatus = await ph.Permission.manageExternalStorage.request();

    if (manageStatus.isGranted) {
      return PermissionResult.granted;
    }

    final storageStatus = await ph.Permission.storage.request();

    if (storageStatus.isGranted) {
      return PermissionResult.granted;
    } else if (storageStatus.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    } else {
      return PermissionResult.denied;
    }
  }

  Future<PermissionResult> requestAllPermissions() async {
    final micResult = await requestMicrophonePermission();
    if (micResult != PermissionResult.granted) {
      return micResult;
    }

    await requestStoragePermission();
    return PermissionResult.granted;
  }

  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  Future<Map<String, ph.PermissionStatus>> checkAllPermissions() async {
    return {
      'microphone': await ph.Permission.microphone.status,
      'storage': await ph.Permission.storage.status,
      'backgroundAudio': await ph.Permission.audio.status,
    };
  }

  bool isPermissionGranted(ph.PermissionStatus status) {
    return status.isGranted;
  }

  bool isPermissionDenied(ph.PermissionStatus status) {
    return status.isDenied || status.isRestricted;
  }

  bool isPermissionPermanentlyDenied(ph.PermissionStatus status) {
    return status.isPermanentlyDenied;
  }
}

enum PermissionResult {
  granted,
  denied,
  permanentlyDenied,
}