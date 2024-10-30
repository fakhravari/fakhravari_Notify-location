import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

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
        options.headers["X-Token-JWT"] = "fakhravari.ir";
        options.headers["Accept-Language"] = "fa-IR";
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
      // Response response = await dio.post('https://ef2.noyankesht.ir/api/v1/Product/WorkManager/WorkManager', data: jsonEncode);
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
}
