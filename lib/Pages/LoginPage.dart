import 'dart:async';
import 'dart:convert';
import 'package:fakhravari/ApiService/ApiService.dart';
import 'package:fakhravari/DTO/CaptchaResponse.dart';
import 'package:fakhravari/Pages/RegisterPage.dart';
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

  void login() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "userName": userNameController.text.trim(),
        "password": passwordController.text.trim(),
        "captcha": captchaController.text.trim(),
        "captchaSecret": captchaSecretController.text.trim()
      };

      var result = await ApiService().Login(data);
      if (result.status == true) {
        showDialogWithTimer(context);
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

  bool isButtonDisabled = true;
  int remainingTime = 120;
  Timer? timer;
  double progressValue = 1.0; // مقدار پیشرفت به صورت درصد (1.0 = 100%)
  String formattedTime = '02:00'; // زمان باقی‌مانده به فرمت 00:00

  void showDialogWithTimer(BuildContext context) {
    remainingTime = 120;
    isButtonDisabled = true;
    progressValue = 1.0;
    formattedTime = '02:00';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            startTimer(dialogSetState);
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop(); // بستن دیالوگ
                          timer?.cancel(); // توقف تایمر
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'تایید شماره همراه',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Row(
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
                              : () {
                                  dialogSetState(() {
                                    isButtonDisabled = true;
                                    remainingTime = 120;
                                    progressValue = 1.0;
                                    formattedTime = '02:00';
                                  });
                                  startTimer(dialogSetState);
                                },
                          child: Text('ارسال'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    if (isButtonDisabled) ...[
                      Text('زمان باقی‌مانده: $formattedTime'),
                    ],
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (smsController.text.trim().isEmpty) {
                          return;
                        }

                        var data = {
                          "userName": userNameController.text.trim(),
                          "password": passwordController.text.trim(),
                          'token': smsController.text.trim()
                        };

                        var step2 = await ApiService().Login2(data);
                        if (step2.status == true) {
                          Get.snackbar(
                            'موفق',
                            'ورود موفقیت آمیز بود',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );

                          await Get.offAll(ServiceControlScreen());
                          timer?.cancel();
                        } else {
                          Get.snackbar(
                            step2.title!,
                            step2.message!,
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: Text('تأیید کد'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void startTimer(void Function(void Function()) dialogSetState) {
    timer?.cancel();

    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (remainingTime > 0) {
        dialogSetState(() {
          remainingTime--;
          progressValue = remainingTime / 120;
          formattedTime =
              '${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}';
        });
      } else {
        t.cancel();
        dialogSetState(() {
          isButtonDisabled = false;
          remainingTime = 120;
          progressValue = 1.0;
          formattedTime = '02:00';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('فرم ورود'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Card(
                margin: EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                      bytes != null
                          ? SizedBox(
                              width: 250,
                              child: Image.memory(
                                bytes!,
                                fit: BoxFit.fill,
                              ),
                            )
                          : SizedBox.shrink(),
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: login,
                            child: Text('ورود'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await Get.to(RegisterPage());
                            },
                            child: Text('ثبتنام'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    captchaController.dispose();
    captchaSecretController.dispose();

    super.dispose();
  }
}
