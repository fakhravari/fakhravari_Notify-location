import 'dart:async';
import 'dart:convert';
import 'package:fakhravari/ApiService/ApiService.dart';
import 'package:fakhravari/DTO/CaptchaResponse.dart';
import 'package:fakhravari/ServiceControlScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController(text: 'محمدحسین');
  final lastNameController = TextEditingController(text: 'فخرآوری');
  final nationalCodeController = TextEditingController(text: '3490061098');
  final birthDateController = TextEditingController(text: '1990-07-25');
  final phoneNumberController = TextEditingController(text: '09173700916');
  final emailController = TextEditingController(text: 'fakhravary@gmail.com');
  final passwordController = TextEditingController(text: '12Fged%67');
  final captchaController = TextEditingController(text: '');
  final captchaSecretController = TextEditingController(text: '');
  final smsController = TextEditingController(text: '');
  bool isLoading = false;

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

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

      if (result.status == true) {
        var step1 = await ApiService().registerStep1();

        if (step1.status == true) {
          Get.snackbar(
            'موفق',
            'ثبتنام موفقیت آمیز بود',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          showDialogWithTimer(context);
        } else {
          Get.snackbar(
            step1.title!,
            step1.message!,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          result.title!,
          result.message!,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      setState(() {
        isLoading = false;
      });
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
                        var step2 = await ApiService()
                            .registerStep2(smsController.text.trim());

                        if (step2.status == true) {
                          Get.snackbar(
                            'موفق',
                            'ثبتنام موفقیت آمیز بود',
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
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
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
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
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
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                        .hasMatch(value)) {
                                      return 'ایمیل معتبر نیست';
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
                            SizedBox(
                              width: 250,
                              child: Image.memory(
                                bytes!,
                                fit: BoxFit.fill,
                              ),
                            ),
                          if (bytes == null) Text(''),
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
                          ElevatedButton(
                            onPressed: isLoading ? null : submitForm,
                            child: isLoading
                                ? CircularProgressIndicator(
                                    value: progressValue, // مقدار پیشرفت
                                    strokeWidth: 6.0, // ضخامت
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue), // رنگ پیشرفت
                                    backgroundColor:
                                        Colors.grey[300], // رنگ پس‌زمینه
                                  )
                                : Text('ارسال'),
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
