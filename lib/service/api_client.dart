import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'https://hotel-management-system-be-1.onrender.com/api';
  static Dio? _dio;

  static Dio get dio {
    if (_dio == null) {
      _dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ));

      _dio!.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print(obj),
      ));
    }
    return _dio!;
  }
}
