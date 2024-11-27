import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:fakhravari/Config/LocationDatabase.dart';
import 'package:fakhravari/Config/TokenService.dart';
import 'package:fakhravari/Config/Tools.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Timer? timer;

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  service.on('stopService').listen((_) {
    timer?.cancel();
    service.stopSelf();
  });

  final sec = await Tools.GetTimerService();

  timer = Timer.periodic(Duration(seconds: sec), (_) async {
    var taeiMobile = (await Tools.GetstatusLoginTaid());
    var isRun = (await Tools.GetisRunning());

    if (taeiMobile && isRun) {
      await showNotify();
      await callback();
    }
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
    'PishroAtieh',
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
  final statuses = await [
    Permission.location,
    Permission.notification,
    Permission.phone
  ].request();
  final prefs = await SharedPreferences.getInstance();

  if (statuses[Permission.location]!.isGranted &&
      statuses[Permission.notification]!.isGranted &&
      statuses[Permission.phone]!.isGranted) {
    await prefs.setBool('isOk', true);
    Get.snackbar('دسترسی ها', 'کامل داده شده است');
  } else {
    Get.snackbar('دسترسی ها', 'دسترسی ها ناقص است');
    openAppSettings();
  }

  if (await Geolocator.checkPermission() != LocationPermission.always) {
    Get.snackbar('مکان', 'مجوز مکان باید روی همیشه تنظیم شود');
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
    const androidSettings = AndroidInitializationSettings('ic_launcher');
    await flutterLocalNotificationsPlugin
        .initialize(const InitializationSettings(android: androidSettings));

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

    await service.configure(
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

    final isLoggedIn = await TokenService().getTokens();
    var taeiMobile = (await Tools.GetstatusLoginTaid());
    var isRun = (await Tools.GetisRunning());
    if (isLoggedIn != null && taeiMobile && isRun) {
      try {
        await Future.delayed(const Duration(seconds: 2));
        await FlutterBackgroundService().startService();
      } catch (e) {
        print(e);
      }
    } else {
      try {
        var isRuning = await FlutterBackgroundService().isRunning();
        if (isRuning) {
          await Future.delayed(const Duration(seconds: 2));
          FlutterBackgroundService().invoke('stopService');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  String TextBtn = '';

  @override
  Widget build(BuildContext context) {
    Tools.GetisRunning().then(
      (value) {
        setState(() {
          if (value) {
            TextBtn = 'فعال است';
          } else {
            TextBtn = 'غیر فعال است';
          }
        });
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Service Control'), actions: [
        IconButton(
          icon: Icon(Icons.power_settings_new),
          onPressed: () {
            SystemNavigator.pop();
          },
          tooltip: 'خروج از اپ',
        ),
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () async {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            await prefs.clear();
            exit(0);
          },
          tooltip: 'خروج از حساب',
        ),
      ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('وضعیت سرویس » $TextBtn'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async => await requestPermissions(context),
              child: const Text('بررسی دسترسی'),
            ),
          ],
        ),
      ),
    );
  }
}
