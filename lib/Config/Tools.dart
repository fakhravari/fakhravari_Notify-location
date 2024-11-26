import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
import 'package:unique_identifier/unique_identifier.dart';

class Tools {
  static Future<String?> UniqueIdentifierState() async {
    String? identifier;
    try {
      identifier = await UniqueIdentifier.serial;
      return identifier;
    } catch (e) {
      return identifier;
    }
  }

  static Future<Map<String, String>> DeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final Map<String, String> deviceData = {};

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceData.addAll({
          'model': androidInfo.model ?? 'Unknown',
          'isPhysicalDevice': androidInfo.isPhysicalDevice.toString(),
          'systemName': 'Android',
          'systemVersion': androidInfo.version.release ?? 'Unknown',
          'id': await UniqueIdentifierState() ?? 'Unknown',
        });
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceData.addAll({
          'model': iosInfo.model ?? 'Unknown',
          'isPhysicalDevice': iosInfo.isPhysicalDevice.toString(),
          'systemName': iosInfo.systemName ?? 'iOS',
          'systemVersion': iosInfo.systemVersion ?? 'Unknown',
          'id': await UniqueIdentifierState() ?? 'Unknown',
        });
      }
    } catch (e) {
      // برای مدیریت خطاها می‌توانید اینجا لاگ اضافه کنید
      print('Error fetching device info: $e');
    }

    return deviceData;
  }
}
