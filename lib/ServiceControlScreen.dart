import 'dart:async';
import 'dart:ui';
import 'package:fakhravari/Config/LocationDatabase.dart';
import 'package:get/get.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final textTimer = TextEditingController(text: '10').obs;
Timer? timer;

class ServiceController extends GetxController {
  var isServiceRunning = false.obs;

  Future<void> checkServiceStatus() async {
    bool running = await FlutterBackgroundService().isRunning();
    if (!running) {
      await FlutterBackgroundService().startService();
      isServiceRunning.value = true;
      Get.snackbar('Service Status', 'Service started');
    } else {
      FlutterBackgroundService().invoke('stopService');
      isServiceRunning.value = false;
      Get.snackbar('Service Status', 'Service stopped');
    }
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  service.on('stopService').listen((_) {
    timer?.cancel();
    service.stopSelf();
  });

  final prefs = await SharedPreferences.getInstance();
  final sec = prefs.getInt('timer') ?? 10;

  timer = Timer.periodic(Duration(seconds: sec), (_) async {
    await showNotify();
    await callback();
  });
}

Future<void> callback() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('isOk') ?? false) {
    final position = await Geolocator.getCurrentPosition();
    await LocationDatabase.instance
        .insertLocation(position.latitude, position.longitude);
    await LocationDatabase.instance.sendUnsentLocations();
  }
}

Future<void> showNotify() async {
  await flutterLocalNotificationsPlugin.show(
    0,
    'My App Service',
    'بروز رسانی : ${DateTime.now()}',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'foreground_service_channel',
        'Foreground Service',
        channelDescription: 'This is a foreground service',
        importance: Importance.high,
        priority: Priority.high,
        ongoing: true,
        playSound: false,
      ),
    ),
  );
}

Future<void> requestPermissions(BuildContext context) async {
  final statuses =
      await [Permission.location, Permission.notification].request();
  final prefs = await SharedPreferences.getInstance();

  if (statuses[Permission.location]!.isGranted &&
      statuses[Permission.notification]!.isGranted) {
    await prefs.setBool('isOk', true);
    Get.snackbar('Permissions', 'Permissions granted');
  } else {
    Get.snackbar('Permissions', 'Permissions not granted');
    openAppSettings();
  }

  if (await Geolocator.checkPermission() != LocationPermission.always) {
    Get.snackbar('Geolocator', 'Location permission must be set to always');
    openAppSettings();
  }
}

class ServiceControlScreen extends StatefulWidget {
  const ServiceControlScreen({super.key});

  @override
  State<ServiceControlScreen> createState() => _ServiceControlScreenState();
}

class _ServiceControlScreenState extends State<ServiceControlScreen> {
  void load() async {
    final prefs = await SharedPreferences.getInstance();

    var getix = Get.put(ServiceController());
    const androidSettings = AndroidInitializationSettings('ic_launcher');
    await flutterLocalNotificationsPlugin
        .initialize(const InitializationSettings(android: androidSettings));

    await prefs.setInt('timer', 10);

    final service = FlutterBackgroundService();
    const AndroidNotificationChannel callChannel = AndroidNotificationChannel(
        'foreground_service_channel', // channel ID
        'Foreground Service', // channel name
        description: 'Service is running',
        importance: Importance.high);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(callChannel);

    var forg = await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'foreground_service_channel',
        initialNotificationTitle: 'Foreground Service',
        initialNotificationContent: 'Service is running',
        foregroundServiceNotificationId: 600,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    if (forg) {
      getix.isServiceRunning.value =
          await FlutterBackgroundService().isRunning();
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then(
      (value) {
        textTimer.value.text = (value.getInt('timer') ?? 10).toString();
      },
    );
    final serviceController = Get.find<ServiceController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Service Control')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Obx(() => TextField(
                    controller: textTimer.value,
                    keyboardType: TextInputType.number,
                    onChanged: (value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('timer', int.tryParse(value) ?? 10);
                    },
                  )),
            ),
            Obx(() => ElevatedButton(
                  onPressed: () async =>
                      await serviceController.checkServiceStatus(),
                  child: Text(serviceController.isServiceRunning.value
                      ? 'فعال است'
                      : 'غیر فعال است'),
                )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async => await requestPermissions(context),
              child: const Text('Request Permissions'),
            ),
          ],
        ),
      ),
    );
  }
}
