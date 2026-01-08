import 'package:dio/dio.dart';
import '../model/request/register_request.dart';
import '../model/request/login_request.dart';
import '../model/response/login_response.dart';
import '../model/response/user_response.dart';
import 'api_client.dart';

class AuthService {
  late final Dio _dio;

  AuthService() {
    _dio = ApiClient.dio;
  }

  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await _dio.post(
        '/auth/send-otp',
        queryParameters: {'email': email},
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Đã gửi mã OTP',
      };
    } on DioException catch (e) {
      String errorMessage = 'Có lỗi xảy ra khi gửi OTP';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 400:
            errorMessage = responseData['message'] ?? 'Email không hợp lệ';
            break;
          case 404:
            errorMessage = responseData['message'] ?? 'Không tìm thấy email';
            break;
          case 409:
            errorMessage =
                responseData['message'] ?? 'Email đã được sử dụng';
            break;
          case 500:
            errorMessage = 'Lỗi server, vui lòng thử lại sau';
            break;
          default:
            errorMessage = responseData['message'] ?? 'Gửi OTP thất bại';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Kết nối timeout, vui lòng kiểm tra mạng';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Không thể kết nối đến server';
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi không xác định xảy ra',
      };
    }
  }

  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/register/customer',
        data: request.toJson(),
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Đăng ký thành công',
      };
    } on DioException catch (e) {
      String errorMessage = 'Có lỗi xảy ra khi đăng ký';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        switch (statusCode) {
          case 400:
            errorMessage = responseData['message'] ?? 'Thông tin đăng ký không hợp lệ';
            break;
          case 409:
            errorMessage = 'Email đã được sử dụng';
            break;
          case 410:
            errorMessage = responseData['message'] ?? 'OTP không hợp lệ hoặc đã hết hạn';
            break;
          case 500:
            errorMessage = 'Lỗi server, vui lòng thử lại sau';
            break;
          default:
            errorMessage = responseData['message'] ?? 'Đăng ký thất bại';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Kết nối timeout, vui lòng kiểm tra mạng';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Không thể kết nối đến server';
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi không xác định xảy ra',
      };
    }
  }

  Future<Map<String, dynamic>> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: request.toJson(),
      );

      // Backend bọc dữ liệu trong field "data"
      final dynamic body = response.data;
      final dynamic data = (body is Map && body['data'] != null) ? body['data'] : body;
      final loginResponse = LoginResponse.fromJson(data as Map<String, dynamic>);

      return {
        'success': true,
        'data': loginResponse,
        'message': 'Đăng nhập thành công',
      };
    } on DioException catch (e) {
      String errorMessage = 'Có lỗi xảy ra khi đăng nhập';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        switch (statusCode) {
          case 400:
          case 401:
            errorMessage = 'Email hoặc mật khẩu không đúng';
            break;
          case 500:
            errorMessage = 'Lỗi server, vui lòng thử lại sau';
            break;
          default:
            errorMessage = responseData['message'] ?? 'Đăng nhập thất bại';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Kết nối timeout, vui lòng kiểm tra mạng';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Không thể kết nối đến server';
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi không xác định xảy ra',
      };
    }
  }

  Future<Map<String, dynamic>> getUserInfo(String token) async {
    try {
      final response = await _dio.get(
        '/user/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      final dynamic body = response.data;
      final dynamic data = (body is Map && body['data'] != null) ? body['data'] : body;
      final userResponse = UserResponse.fromJson(data as Map<String, dynamic>);
      return {
        'success': true,
        'data': userResponse,
        'message': 'Lấy thông tin người dùng thành công',
      };
    } on DioException catch (e) {
      String errorMessage = 'Có lỗi xảy ra khi lấy thông tin user';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        switch (statusCode) {
          case 401:
            errorMessage = 'Token không hợp lệ hoặc đã hết hạn';
            break;
          case 404:
            errorMessage = 'Không tìm thấy thông tin user';
            break;
          case 500:
            errorMessage = 'Lỗi server, vui lòng thử lại sau';
            break;
          default:
            errorMessage = responseData['message'] ?? 'Lấy thông tin user thất bại';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Kết nối timeout, vui lòng kiểm tra mạng';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Không thể kết nối đến server';
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi không xác định xảy ra',
      };
    }
  }
}