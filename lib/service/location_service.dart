import 'package:dio/dio.dart';
import '../model/response/location_response.dart';
import 'api_client.dart';

class LocationService {
  late final Dio _dio;

  LocationService() {
    _dio = ApiClient.dio;
  }

  Future<Map<String, dynamic>> getLocations() async {
    try {
      final response = await _dio.get('/locations');

      final dynamic body = response.data;

      List<dynamic> listData = const <dynamic>[];

      if (body is List) {
        listData = body;
      } else if (body is Map<String, dynamic>) {
        final dynamic data = body['data'];
        if (data is List) {
          listData = data;
        } else if (data is Map) {
          final dynamic nested = data['locations'];
          if (nested is List) {
            listData = nested;
          }
        } else {
          final dynamic direct = body['locations'];
          if (direct is List) {
            listData = direct;
          }
        }
      }

      final locations = listData
          .map((e) => LocationResponse.fromJson(e as Map<String, dynamic>))
          .toList();

      return {
        'success': true,
        'data': locations,
        'message': 'Lấy danh sách địa điểm thành công',
      };
    } on DioException catch (e) {
      String errorMessage = 'Có lỗi xảy ra khi lấy danh sách địa điểm';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 400:
            errorMessage = responseData['message'] ?? 'Yêu cầu không hợp lệ';
            break;
          case 404:
            errorMessage = 'Không tìm thấy danh sách địa điểm';
            break;
          case 500:
            errorMessage = 'Lỗi server, vui lòng thử lại sau';
            break;
          default:
            errorMessage = responseData['message'] ?? 'Lấy danh sách địa điểm thất bại';
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


