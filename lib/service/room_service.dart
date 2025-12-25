import 'package:dio/dio.dart';
import '../model/response/room_response.dart';
import '../model/response/room_type_response.dart';
import 'api_client.dart';

class RoomService {
  late final Dio _dio;

  RoomService() {
    _dio = ApiClient.dio;
  }

  Future<Map<String, dynamic>> getAllRoomTypes() async {
    try {
      final response = await _dio.get('/roomtypes/getAll');

      // Parse response data
      final dynamic body = response.data;
      print('Full API Response: $body'); // Debug log

      final Map<String, dynamic> responseMap = body as Map<String, dynamic>;
      final Map<String, dynamic> dataMap = responseMap['data'] as Map<String, dynamic>;
      final List<dynamic> roomTypesData = dataMap['roomTypes'] as List<dynamic>;
      
      final List<RoomTypeResponse> roomTypes = roomTypesData
          .map((json) => RoomTypeResponse.fromJson(json as Map<String, dynamic>))
          .toList();

      print('Parsed ${roomTypes.length} room types successfully'); // Debug log
      
      return {
        'success': true,
        'data': roomTypes,
        'message': 'Lấy danh sách loại phòng thành công',
      };
    } on DioException catch (e) {
      print('DioException: ${e.message}'); // Debug log
      String errorMessage = 'Có lỗi xảy ra khi lấy danh sách loại phòng';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        switch (statusCode) {
          case 400:
            errorMessage = responseData['message'] ?? 'Yêu cầu không hợp lệ';
            break;
          case 404:
            errorMessage = 'Không tìm thấy danh sách loại phòng';
            break;
          case 500:
            errorMessage = 'Lỗi server, vui lòng thử lại sau';
            break;
          default:
            errorMessage = responseData['message'] ?? 'Lấy danh sách loại phòng thất bại';
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
      print('General Exception: $e');
      return {
        'success': false,
        'message': 'Có lỗi không xác định xảy ra: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getAllRooms() async {
    try {
      final response = await _dio.get('/rooms/getAll');

      final dynamic body = response.data;
      print('Full API Response (rooms): $body');

      final Map<String, dynamic> responseMap = body as Map<String, dynamic>;
      final Map<String, dynamic> dataMap =
          responseMap['data'] as Map<String, dynamic>;
      final List<dynamic> roomsData = dataMap['rooms'] as List<dynamic>;

      final List<RoomResponse> rooms = roomsData
          .map((json) => RoomResponse.fromJson(json as Map<String, dynamic>))
          .toList();

      print('Parsed ${rooms.length} rooms successfully');

      return {
        'success': true,
        'data': rooms,
        'message': 'Lấy danh sách phòng thành công',
      };
    } on DioException catch (e) {
      print('DioException (rooms): ${e.message}');
      String errorMessage = 'Có lỗi xảy ra khi lấy danh sách phòng';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 400:
            errorMessage = responseData['message'] ?? 'Yêu cầu không hợp lệ';
            break;
          case 404:
            errorMessage = 'Không tìm thấy danh sách phòng';
            break;
          case 500:
            errorMessage = 'Lỗi server, vui lòng thử lại sau';
            break;
          default:
            errorMessage = responseData['message'] ?? 'Lấy danh sách phòng thất bại';
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
      print('General Exception (rooms): $e');
      return {
        'success': false,
        'message': 'Có lỗi không xác định xảy ra: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getAvailableRooms({
    required String checkIn,
    required String checkOut,
    String? token,
  }) async {
    try {
      final response = await _dio.get(
        '/rooms/search/room-available',
        queryParameters: {
          'checkIn': checkIn,
          'checkOut': checkOut,
        },
        options: token != null && token.isNotEmpty
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      final dynamic body = response.data;
      print('Full API Response (room-available): $body');

      List<dynamic> roomsData = const <dynamic>[];

      if (body is List) {
        roomsData = body;
      } else if (body is Map<String, dynamic>) {
        final dynamic data = body['data'];
        if (data is List) {
          roomsData = data;
        } else if (data is Map) {
          final dynamic nestedRooms = data['rooms'];
          if (nestedRooms is List) {
            roomsData = nestedRooms;
          }
        } else {
          final dynamic directRooms = body['rooms'];
          if (directRooms is List) {
            roomsData = directRooms;
          }
        }
      }

      final List<RoomResponse> rooms = roomsData
          .map((json) => RoomResponse.fromJson(json as Map<String, dynamic>))
          .toList();

      print('Parsed ${rooms.length} available rooms successfully');

      return {
        'success': true,
        'data': rooms,
        'message': 'Lấy danh sách phòng trống thành công',
      };
    } on DioException catch (e) {
      print('DioException (room-available): ${e.message}');
      String errorMessage = 'Có lỗi xảy ra khi lấy danh sách phòng trống';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 400:
            errorMessage = responseData['message'] ?? 'Yêu cầu không hợp lệ';
            break;
          case 404:
            errorMessage = 'Không tìm thấy danh sách phòng trống';
            break;
          case 500:
            errorMessage = 'Lỗi server, vui lòng thử lại sau';
            break;
          default:
            errorMessage =
                responseData['message'] ?? 'Lấy danh sách phòng trống thất bại';
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
      print('General Exception (room-available): $e');
      return {
        'success': false,
        'message': 'Có lỗi không xác định xảy ra: $e',
      };
    }
  }
}
