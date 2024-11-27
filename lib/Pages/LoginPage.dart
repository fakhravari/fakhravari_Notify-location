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
  final passwordController = TextEditingController(text: 'p!#^(MHF1');
  final captchaController = TextEditingController();
  final captchaSecretController = TextEditingController();

  void login() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "userName": userNameController.text,
        "password": passwordController.text,
        "captcha": captchaController.text,
        "captchaSecret": captchaSecretController.text
      };

      var result = await ApiService().Login(data);
      if (result.status == true) {
        Get.snackbar(
          'موفق',
          'ورود موفقیت آمیز بود',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await Get.off(ServiceControlScreen());
      } else {
        Get.snackbar(
          'خطا',
          result.message!,
          snackPosition: SnackPosition.BOTTOM,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      SizedBox(height: 20),
                      bytes != null
                          ? Image.memory(
                              bytes!,
                              fit: BoxFit.fill,
                              width: 100,
                            )
                          : SizedBox.shrink(),
                      SizedBox(height: 20),
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
