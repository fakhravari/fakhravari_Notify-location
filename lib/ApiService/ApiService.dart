import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:fakhravari/Config/TokenService.dart';
import 'package:fakhravari/DTO/CaptchaResponse.dart';
import 'package:fakhravari/DTO/LoginResult.dart';

class ApiServiceResult {
  bool status;
  String msg;
  String body;
  ApiServiceResult(
      {required this.status, required this.msg, required this.body});
}

class ApiService {
  var dio = Dio()
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenService().getTokens();
        if (token != null) {
          options.headers["Authorization"] = "Bearer ${token.token}";
        }
        return handler.next(options);
      },
    ));

  Future<ApiServiceResult> sendDataToApi(String jsonEncode) async {
    print("Sending data to API...");

    // بررسی وضعیت اتصال
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print("No internet connection.");
      return ApiServiceResult(
        status: false,
        msg: 'No internet connection - ${DateTime.now().toIso8601String()}',
        body: '',
      );
    }

    try {
      Response response = await dio.post(
          'http://location.pishroatieh.com:5953/Location/create',
          data: jsonEncode);

      if (response.statusCode == 200) {
        print("statusCode == 200");
        return ApiServiceResult(
          status: true,
          msg: '${response.data}',
          body: DateTime.now().toIso8601String(),
        );
      } else {
        return ApiServiceResult(
          status: false,
          msg: 'error: ${response.statusCode} - ${response.statusMessage}',
          body: DateTime.now().toIso8601String(),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      return ApiServiceResult(
        status: false,
        msg: 'error: ${e.toString()}',
        body: DateTime.now().toIso8601String(),
      );
    }
  }

  Future<CaptchaResponse> fetchCaptcha() async {
    final response = await dio.get(
      'https://attendance-api.pishroatieh.com/api/users/generate-captcha',
      options: Options(headers: {'accept': '*/*'}),
    );

    if (response.statusCode == 200) {
      return CaptchaResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to load captcha');
    }
  }

  Future<bool> registerUser(Map<String, String> data) async {
    // final data = {
    //   "firstName": "محمدحسین",
    //   "lastName": "فخرآوری",
    //   "nationalCode": "3490061098",
    //   "birthDate": "1990-07-25",
    //   "phoneNumber": "09173700916",
    //   "email": "fakhravary@gmail.com",
    //   "password": "1",
    //   "captcha": "1",
    //   "captchaSecret": 'captchaSecret',
    // };

    try {
      final response = await dio.post(
        'https://attendance-api.pishroatieh.com/api/users/register',
        data: data,
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var tokenResponse = LoginDataToken.fromJson(response.data);
        await TokenService().saveTokens(tokenResponse);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> Login(Map<String, String> data) async {
    try {
      final response = await dio.post(
        'https://attendance-api.pishroatieh.com/api/users/login',
        data: data,
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var tokenResponse = LoginResult.fromJson(response.data);
        await TokenService().saveTokens(tokenResponse.data!);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
