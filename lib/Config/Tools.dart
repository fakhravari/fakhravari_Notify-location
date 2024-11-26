import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;

class Tools {
  static Future<Map<String, String>> DeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var deviceData;
    try {
      if (Platform.isAndroid) {


        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData = {
          'model': androidInfo.model.toString(),
          'isPhysicalDevice': androidInfo.isPhysicalDevice.toString(),
          'systemName': 'Android',
          'systemVersion': androidInfo.version.release.toString(),
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceData = {
          'model': iosInfo.model,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
        };
      }

      return deviceData;
    } catch (e) {
      return {};
    }
  }
}
