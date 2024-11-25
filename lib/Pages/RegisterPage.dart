import 'dart:convert';
import 'dart:typed_data';
import 'package:fakhravari/ApiService/ApiService.dart';
import 'package:fakhravari/DTO/CaptchaResponse.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final nationalCodeController = TextEditingController();
  final birthDateController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final captchaController = TextEditingController();
  final captchaSecretController = TextEditingController();

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      final formData = {
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "nationalCode": nationalCodeController.text,
        "birthDate": birthDateController.text,
        "phoneNumber": phoneNumberController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "captcha": captchaController.text,
        "captchaSecret": captchaSecretController.text,
      };

      var result = await ApiService().registerUser(formData);
      if (result) {
        Get.snackbar(
          'موفق',
          'ورود موفقیت آمیز بود',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خطا',
          'یک خطا رخ داده است',
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
        title: Text('فرم ثبت‌نام'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    margin: EdgeInsets.all(2.0),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: firstNameController,
                                  decoration: InputDecoration(
                                    labelText: 'نام',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'لطفاً نام خود را وارد کنید';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: lastNameController,
                                  decoration: InputDecoration(
                                    labelText: 'نام خانوادگی',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'لطفاً نام خانوادگی خود را وارد کنید';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: nationalCodeController,
                                  decoration: InputDecoration(
                                    labelText: 'کد ملی',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'لطفاً کد ملی خود را وارد کنید';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: birthDateController,
                                  decoration: InputDecoration(
                                    labelText: 'تاریخ تولد (yyyy-mm-dd)',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'لطفاً تاریخ تولد خود را وارد کنید';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: phoneNumberController,
                                  decoration: InputDecoration(
                                    labelText: 'شماره تلفن',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'لطفاً شماره تلفن خود را وارد کنید';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: 'ایمیل',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'لطفاً ایمیل خود را وارد کنید';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
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
                                return 'لطفاً رمز عبور خود را وارد کنید';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          if (bytes != null)
                            Image.memory(
                              bytes!,
                              fit: BoxFit.fill,
                              width: double.infinity,
                            ),
                          if (bytes == null) Text(''),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: captchaController,
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
                          ElevatedButton(
                            onPressed: submitForm,
                            child: Text('ارسال'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    nationalCodeController.dispose();
    birthDateController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    captchaController.dispose();
    captchaSecretController.dispose();

    super.dispose();
  }
}
