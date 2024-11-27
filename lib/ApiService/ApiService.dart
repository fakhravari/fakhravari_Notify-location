import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:fakhravari/Config/TokenService.dart';
import 'package:fakhravari/DTO/CaptchaResponse.dart';
import 'package:fakhravari/DTO/LoginResult.dart';
import 'package:fakhravari/DTO/ShereModel.dart';

class ApiServiceResult {
  bool status;
  String msg;
  String body;
  ApiServiceResult(
      {required this.status, required this.msg, required this.body});
}

class ApiService {
  var dio = Dio(
    BaseOptions(
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(InterceptorsWrapper(
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
      final response = await dio.post(
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
        'https://attendance-api.pishroatieh.com/api/users/generate-captcha');

    if (response.statusCode == 200) {
      return CaptchaResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to load captcha');
    }
  }

  Future<ModelResult> registerUser(Map<String, String> data) async {
    try {
      final response = await dio.post(
        'https://attendance-api.pishroatieh.com/api/users/register',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var token = response.data['data'];
        var tokenResponse = LoginDataToken.fromJson(token);
        await TokenService().saveTokens(tokenResponse, false);

        return ModelResult(message: 'موفق', status: true);
      } else {
        return ModelResult(message: 'خطا', status: false);
      }
    } on DioException catch (e) {
      var msg = handleApiResponse(e.response!.data);
      return ModelResult(message: msg.message, title: msg.title, status: false);
    }
  }

  Future<ModelResult> registerStep1() async {
    try {
      final response = await dio.get(
          'https://attendance-api.pishroatieh.com/api/users/phone-number-confirmation-step-1');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ModelResult(message: 'موفق', status: true);
      } else {
        return ModelResult(message: 'خطا', status: false);
      }
    } on DioException catch (e) {
      var msg = handleApiResponse(e.response!.data);
      return ModelResult(message: msg.message, title: msg.title, status: false);
    }
  }

  Future<ModelResult> registerStep2(smsCode) async {
    try {
      final response = await dio.post(
          'https://attendance-api.pishroatieh.com/api/users/phone-number-confirmation-step-2',
          data: {'token': smsCode});

      if (response.statusCode == 200 || response.statusCode == 201) {
        var token = response.data['data'];
        var tokenResponse = LoginDataToken.fromJson(token);
        await TokenService().saveTokens(tokenResponse, true);

        return ModelResult(message: 'موفق', status: true);
      } else {
        return ModelResult(message: 'خطا', status: false);
      }
    } on DioException catch (e) {
      var msg = handleApiResponse(e.response!.data);
      return ModelResult(message: msg.message, title: msg.title, status: false);
    }
  }

  Future<ModelResult> Login(Map<String, String> data) async {
    try {
      final response = await dio.post(
        'https://attendance-api.pishroatieh.com/api/users/login',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var tokenResponse = LoginResult.fromJson(response.data);
        await TokenService().saveTokens(tokenResponse.data!, false);
        return ModelResult(message: 'موفق', status: true);
      } else {
        return ModelResult(message: 'خطا', status: false);
      }
    } on DioException catch (e) {
      var msg = handleApiResponse(e.response!.data);
      return ModelResult(message: msg.message, title: msg.title, status: false);
    }
  }

  ModelResult2 handleApiResponse(Map<String, dynamic> data) {
    String title = data['message'] ?? 'خطای نامشخص رخ داده است!';
    String errorMessage = '';
    try {
      // خطاهای منطقی
      if (data['logicalErrors'] != null && data['logicalErrors'] is List) {
        List logicalErrors = data['logicalErrors'];
        if (logicalErrors.isNotEmpty) {
          String logicalErrorMessages = logicalErrors
              .map((error) => error['message'] ?? 'خطای نامشخص')
              .join('\n');
          errorMessage += '\n\nخطاهای منطقی:\n$logicalErrorMessages';
        }
      }

      // خطاهای اعتبارسنجی
      if (data['validationErrors'] != null &&
          data['validationErrors'] is List) {
        List validationErrors = data['validationErrors'];
        if (validationErrors.isNotEmpty) {
          String validationErrorMessages = validationErrors.map((error) {
            String propertyName = error['propertyName'] ?? 'فیلد ناشناس';
            List messages = error['messages'] ?? [];
            String combinedMessages = messages.join(', ');
            return "$propertyName: $combinedMessages";
          }).join('\n');
          errorMessage += '\n\nخطاهای اعتبارسنجی:\n$validationErrorMessages';
        }
      }
    } catch (e) {}

    return ModelResult2(message: errorMessage, title: title);
  }
}
