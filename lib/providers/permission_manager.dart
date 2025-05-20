import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  // 앱이 실행될 때 한 번 호출하여 필요한 권한을 모두 요청합니다.
  static Future<void> requestAllNecessaryPermissions() async {
    await _requestLocationPermission();
    await _requestActivityRecognitionPermission();
  }

  // 위치 권한 요청
  static Future<void> _requestLocationPermission() async {
    final locationStatus = await Permission.location.status;

    if (locationStatus.isDenied || locationStatus.isRestricted || locationStatus.isPermanentlyDenied) {
      final result = await Permission.location.request();

      if (!result.isGranted) {
        print('❗ 위치 권한이 거부됨');
      }
    }
  }

  // 활동 인식 권한 요청 (만보기)
  static Future<void> _requestActivityRecognitionPermission() async {
    final activityStatus = await Permission.activityRecognition.status;

    if (activityStatus.isDenied || activityStatus.isRestricted || activityStatus.isPermanentlyDenied) {
      final result = await Permission.activityRecognition.request();

      if (!result.isGranted) {
        print('❗ 활동 인식 권한이 거부됨');
      }
    }
  }
}
