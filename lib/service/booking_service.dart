import 'package:dio/dio.dart';
import '../model/request/booking_create_request.dart';
import '../model/response/booking_response.dart';
import 'api_client.dart';

class BookingService {
  late final Dio _dio;

  BookingService() {
    _dio = ApiClient.dio;
  }

  Future<Map<String, dynamic>> getAllBookings({
    required String token,
  }) async {
    try {
      Response response;
      try {
        // Prefer non-paginated call (app doesn't expose pagination)
        response = await _dio.get(
          '/booking/getAll',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } on DioException catch (e) {
        // Some backends require page/limit; fallback silently with a large limit.
        final status = e.response?.statusCode;
        if (status == 400) {
          response = await _dio.get(
            '/booking/getAll',
            queryParameters: const {
              'page': 1,
              'limit': 1000,
            },
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          );
        } else {
          rethrow;
        }
      }

      final dynamic body = response.data;
      List<dynamic> rawList = const <dynamic>[];

      if (body is List) {
        rawList = body;
      } else if (body is Map<String, dynamic>) {
        final dynamic data = body['data'] ?? body;
        if (data is List) {
          rawList = data;
        } else if (data is Map && data['bookings'] is List) {
          rawList = data['bookings'] as List<dynamic>;
        }
      }

      final bookings = rawList
          .map((e) => BookingResponse.fromJson(e as Map<String, dynamic>))
          .toList();

      return {
        'success': true,
        'data': bookings,
        'message': 'Lấy danh sách booking thành công',
      };
    } on DioException catch (e) {
      String errorMessage = 'Có lỗi xảy ra khi lấy danh sách booking';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 401:
            errorMessage = 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại';
            break;
          case 403:
            errorMessage = 'Bạn không có quyền truy cập';
            break;
          case 500:
            errorMessage = 'Lỗi server, vui lòng thử lại sau';
            break;
          default:
            errorMessage = (responseData is Map ? responseData['message'] : null) ??
                'Lấy danh sách booking thất bại';
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
        'message': 'Có lỗi không xác định xảy ra: $e',
      };
    }
  }

  Future<Map<String, dynamic>> createBooking(
    BookingCreateRequest request, {
    String? token,
  }) async {
    try {
      final response = await _dio.post(
        '/booking/create',
        data: request.toJson(),
        options: token != null && token.isNotEmpty
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      return {
        'success': true,
        'data': response.data,
        'message': 'Đặt phòng thành công',
      };
    } on DioException catch (e) {
      String errorMessage = 'Có lỗi xảy ra khi đặt phòng';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 400:
            errorMessage = responseData['message'] ?? 'Thông tin đặt phòng không hợp lệ';
            break;
          case 401:
            errorMessage = 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại';
            break;
          case 404:
            errorMessage = responseData['message']?.toString() ??
                'Không tìm thấy thông tin yêu cầu';
            break;
          case 409:
            errorMessage = responseData['message'] ?? 'Phòng đã được đặt, vui lòng chọn phòng khác';
            break;
          case 500:
            errorMessage = 'Lỗi server, vui lòng thử lại sau';
            break;
          default:
            errorMessage = responseData['message'] ?? 'Đặt phòng thất bại';
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


