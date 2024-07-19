import 'package:permission_handler/permission_handler.dart';

Future<bool> requestMicrophonePermission() async {
  final status = await Permission.microphone.request();

  if (status.isGranted) {
    return true;
  } else {
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  return false;
}