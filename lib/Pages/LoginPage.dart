import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fakhravari/ApiService/ApiService.dart';
import 'package:fakhravari/DTO/CaptchaResponse.dart';
import 'package:fakhravari/Pages/RegisterPage.dart';
import 'package:fakhravari/ServiceControlScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userNameController = TextEditingController(text: '09173700916');
  final passwordController = TextEditingController(text: '12Fged%67');
  final captchaController = TextEditingController();
  final captchaSecretController = TextEditingController();
  final smsController = TextEditingController(text: '');

  bool isTimerVisible = true;
  bool isButtonDisabled = false;
  int remainingTime = 120;
  Timer? timer;
  double progressValue = 1.0;
  String formattedTime = '02:00';

  void login() async {
    if (userNameController.text.isEmpty) {
      Get.snackbar('توجه', 'نام کاربری را وارد کنید');
      return;
    }
    if (passwordController.text.isEmpty) {
      Get.snackbar('توجه', 'رمز عبور را وارد کنید');
      return;
    }
    if (smsController.text.isEmpty) {
      Get.snackbar('توجه', 'کد ارسالی را وارد کنید');
      return;
    }

    setState(() {
      isTimerVisible = false;
      startTimer();
    });

    final data = {
      "userName": userNameController.text.trim(),
      "password": passwordController.text.trim(),
      "token": smsController.text.trim(),
    };

    var result = await ApiService().Login2(data);
    if (result.status == true) {
      Get.snackbar(
        'موفق',
        'ورود موفقیت آمیز بود',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await Get.offAll(() => ServiceControlScreen());
    } else {
      Get.snackbar(
        result.title!,
        result.message!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
          progressValue = remainingTime / 120;
          formattedTime =
              '${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}';
        });
      } else {
        t.cancel();
        setState(() {
          isButtonDisabled = false;
          remainingTime = 120;
          progressValue = 1.0;
          formattedTime = '02:00';
        });
      }
    });
  }

  CaptchaResponse? Captcha;
  Uint8List? bytes;
  @override
  void initState() {
    super.initState();
    CaptchaLoad();
  }

  Future<void> CaptchaLoad() async {
    Captcha = await ApiService().fetchCaptcha();
    bytes = base64Decode(Captcha!.captchaImage!);
    captchaSecretController.text = Captcha!.captchaSecret!;
    setState(() {});
  }

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    captchaController.dispose();
    captchaSecretController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(''), actions: [
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'ورود به حساب کاربری',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'نام کاربری *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: userNameController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  hintText: 'نام کاربری',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'رمز عبور *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'رمز عبور',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              Text(
                'کد امنیتی *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: captchaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        hintText: 'کد امنیتی',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: SizedBox(
                        child: (bytes != null)
                            ? Image.memory(
                                bytes!,
                                fit: BoxFit.fill,
                              )
                            : Text(''),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'رمز یکبار مصرف *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: smsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        labelText: 'کد تایید',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: isButtonDisabled
                          ? null
                          : () async {
                              if (userNameController.text.isEmpty) {
                                Get.snackbar('توجه', 'نام کاربری را وارد کنید');
                                return;
                              }
                              if (passwordController.text.isEmpty) {
                                Get.snackbar('توجه', 'رمز عبور را وارد کنید');
                                return;
                              }
                              if (captchaController.text.isEmpty) {
                                Get.snackbar('توجه', 'کد امنیتی را وارد کنید');
                                return;
                              }

                              final data = {
                                "userName": userNameController.text.trim(),
                                "password": passwordController.text.trim(),
                                "captcha": captchaController.text.trim(),
                                "captchaSecret":
                                    captchaSecretController.text.trim()
                              };

                              var result = await ApiService().Login1(data);
                              if (result.status == true) {
                                setState(() {
                                  isButtonDisabled = true;
                                  remainingTime = 120;
                                  progressValue = 1.0;
                                  formattedTime = '02:00';
                                  startTimer();
                                });
                              } else {
                                Get.snackbar(
                                  result.title!,
                                  result.message!,
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                      child: Text('ارسال کد'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              if (isTimerVisible) Text('زمان باقی‌مانده: $formattedTime'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('ورود به حساب'),
              ),
              SizedBox(height: 10),
              Divider(),
              InkWell(
                child: Text(
                  "ثبت نام",
                  style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 18),
                ),
                onTap: () async {
                  await Get.to(RegisterPage());
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
