import 'package:dio/dio.dart';
import '../model/response/review_response.dart';
import 'api_client.dart';

class ReviewService {
  late final Dio _dio;

  ReviewService() {
    _dio = ApiClient.dio;
  }

  Future<Map<String, dynamic>> getAllReviews() async {
    try {
      final response = await _dio.get('/reviews/getAll');

      final dynamic body = response.data;
      dynamic data = body;
      if (body is Map && body['data'] != null) {
        data = body['data'];
      }

      List<dynamic> rawList;
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['reviews'] is List) {
        rawList = data['reviews'] as List<dynamic>;
      } else if (data is Map && data['items'] is List) {
        rawList = data['items'] as List<dynamic>;
      } else {
        rawList = const [];
      }

      final List<ReviewResponse> reviews = rawList
          .map((json) => ReviewResponse.fromJson(json as Map<String, dynamic>))
          .toList();

      return {
        'success': true,
        'data': reviews,
        'message': 'Lấy danh sách đánh giá thành công',
      };
    } on DioException catch (e) {
      String errorMessage = 'Có lỗi xảy ra khi lấy danh sách đánh giá';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        switch (statusCode) {
          case 400:
            errorMessage = (responseData is Map ? responseData['message'] : null) ??
                'Yêu cầu không hợp lệ';
            break;
          case 404:
            errorMessage = 'Không tìm thấy đánh giá';
            break;
          case 500:
            errorMessage = 'Lỗi server, vui lòng thử lại sau';
            break;
          default:
            errorMessage = (responseData is Map ? responseData['message'] : null) ??
                'Lấy danh sách đánh giá thất bại';
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
}


