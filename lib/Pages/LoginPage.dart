import 'dart:async';
import 'package:fakhravari/ApiService/ApiService.dart';
import 'package:fakhravari/ServiceControlScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final userNameController = TextEditingController(text: '09173700916');
  final passwordController = TextEditingController(text: '12Fged%67');
  final captchaController = TextEditingController();
  final captchaSecretController = TextEditingController();
  final smsController = TextEditingController(text: '');

  bool isTimerVisible = false;
  bool isButtonDisabled = false;
  int remainingTime = 120;
  Timer? timer;
  double progressValue = 1.0;
  String formattedTime = '02:00';

  void login() async {
    if (_formKey.currentState!.validate()) {
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
        await Get.offAll(ServiceControlScreen());
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
      appBar: AppBar(
        title: Text('فرم ورود'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: userNameController,
                  decoration: InputDecoration(
                    labelText: 'نام کاربری',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفاً نام کاربری را وارد کنید';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'رمز عبور',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفاً رمز عبور را وارد کنید';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: captchaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    labelText: 'کپچا',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفاً کپچا را وارد کنید';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                if (isTimerVisible) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
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
                      ElevatedButton(
                        onPressed: isButtonDisabled
                            ? null
                            : () async {
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
                                    isButtonDisabled = false;
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
                        child: Text('ارسال مجدد'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('زمان باقی‌مانده: $formattedTime'),
                ],
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: login,
                  child: Text('ورود'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
