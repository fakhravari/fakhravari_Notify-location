import 'package:fakhravari/Config/LightTheme.dart';
import 'package:fakhravari/Pages/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: lightTheme,
      locale: Locale('fa', 'IR'),
      builder: (context, widget) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: widget!,
        );
      },
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: SplashScreen(),
    );
  }
}
