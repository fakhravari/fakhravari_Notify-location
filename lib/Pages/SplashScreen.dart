import 'dart:async';
import 'package:fakhravari/Config/TokenService.dart';
import 'package:fakhravari/ServiceControlScreen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fakhravari/Pages/LoginPage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 1));

    final isLoggedIn = await TokenService().getTokens();

    if (isLoggedIn != null && isLoggedIn.mobileActive == true) {
      await Get.off(ServiceControlScreen());
    } else {
      await Get.off(LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'در حال بارگذاری ...',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
