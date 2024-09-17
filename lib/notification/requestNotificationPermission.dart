import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      print('Notification permission granted');
    } else if (status.isDenied) {
      print('Notification permission denied');
    } else if (status.isPermanentlyDenied) {
      print('Notification permission permanently denied');

      await openAppSettings();
    }
  } else if (Platform.isIOS) {
    print('Request notification permission on iOS requires native code.');
  }
}
