import 'package:dio/dio.dart';
import '../model/response/service_response.dart';
import 'api_client.dart';

class HotelServiceService {
  late final Dio _dio;

  HotelServiceService() {
    _dio = ApiClient.dio;
  }

  Future<Map<String, dynamic>> getAllServices() async {
    try {
      final response = await _dio.get('/services/getAll');

      final dynamic body = response.data;
      Map<String, dynamic> root = {};
      if (body is Map<String, dynamic>) {
        root = body;
      }

      dynamic dataContainer = root['data'] ?? root;
      List<dynamic> rawList;
      if (dataContainer is Map && dataContainer['services'] is List) {
        rawList = dataContainer['services'] as List<dynamic>;
      } else if (dataContainer is List) {
        rawList = dataContainer;
      } else {
        rawList = const [];
      }

      final List<ServiceResponse> services = rawList
          .map((e) => ServiceResponse.fromJson(e as Map<String, dynamic>))
          .toList();

      return {
        'success': true,
        'data': services,
        'message': 'Lấy danh sách dịch vụ thành công',
      };
    } on DioException catch (e) {
      String errorMessage = 'Có lỗi xảy ra khi lấy danh sách dịch vụ';
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        switch (statusCode) {
          case 400:
            errorMessage = (responseData is Map ? responseData['message'] : null) ??
                'Yêu cầu không hợp lệ';
            break;
          case 404:
            errorMessage = 'Không tìm thấy dịch vụ';
            break;
          case 500:
            errorMessage = 'Lỗi server, vui lòng thử lại sau';
            break;
          default:
            errorMessage = (responseData is Map ? responseData['message'] : null) ??
                'Lấy danh sách dịch vụ thất bại';
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


