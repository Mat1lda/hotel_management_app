import 'package:dio/dio.dart';
import '../model/response/promotion_response.dart';
import '../model/response/room_promotion_offer_response.dart';
import 'api_client.dart';

class PromotionService {
  late final Dio _dio;

  PromotionService() {
    _dio = ApiClient.dio;
  }

  Future<Map<String, dynamic>> getAllPromotions() async {
    try {
      final response = await _dio.get('/promotions/getAll');
      final dynamic body = response.data;
      final Map<String, dynamic> responseMap = body as Map<String, dynamic>;
      final Map<String, dynamic> dataMap =
          responseMap['data'] as Map<String, dynamic>;
      final List<dynamic> promotionsData =
          dataMap['promotions'] as List<dynamic>;

      final List<PromotionResponse> promotions = promotionsData
          .map((json) =>
              PromotionResponse.fromJson(json as Map<String, dynamic>))
          .toList();

      return {
        'success': true,
        'data': promotions,
        'message': responseMap['message']?.toString() ??
            'Lấy danh sách khuyến mãi thành công',
      };
    } on DioException catch (e) {
      String errorMessage = 'Có lỗi xảy ra khi lấy danh sách khuyến mãi';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        switch (statusCode) {
          case 400:
            errorMessage = responseData['message'] ?? 'Yêu cầu không hợp lệ';
            break;
          case 404:
            errorMessage = 'Không tìm thấy danh sách khuyến mãi';
            break;
          case 500:
            errorMessage = 'Lỗi server, vui lòng thử lại sau';
            break;
          default:
            errorMessage =
                responseData['message'] ?? 'Lấy danh sách khuyến mãi thất bại';
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

  Future<Map<String, dynamic>> getAllRoomPromotions() async {
    try {
      final response = await _dio.get('/room-promotions/getAll');
      final dynamic body = response.data;
      final Map<String, dynamic> responseMap = body as Map<String, dynamic>;
      final Map<String, dynamic> dataMap =
          responseMap['data'] as Map<String, dynamic>;
      final List<dynamic> items = dataMap['items'] as List<dynamic>;

      return {
        'success': true,
        'data': items,
        'message':
            responseMap['message']?.toString() ?? 'Lấy danh sách thành công',
      };
    } on DioException catch (e) {
      String errorMessage = 'Có lỗi xảy ra khi lấy danh sách khuyến mãi phòng';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        switch (statusCode) {
          case 400:
            errorMessage = responseData['message'] ?? 'Yêu cầu không hợp lệ';
            break;
          case 404:
            errorMessage = 'Không tìm thấy danh sách khuyến mãi phòng';
            break;
          case 500:
            errorMessage = 'Lỗi server, vui lòng thử lại sau';
            break;
          default:
            errorMessage = responseData['message'] ??
                'Lấy danh sách khuyến mãi phòng thất bại';
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

  Future<Map<String, dynamic>> getActivePromotionsByRoomType(
      int roomTypeId) async {
    try {
      final roomPromotionsResult = await getAllRoomPromotions();
      if (roomPromotionsResult['success'] != true) {
        return roomPromotionsResult;
      }

      final promotionsResult = await getAllPromotions();
      if (promotionsResult['success'] != true) {
        return promotionsResult;
      }

      final List<dynamic> items = roomPromotionsResult['data'] as List<dynamic>;
      final Map<int, int> promotionIdToRoomPromotionId = <int, int>{};
      for (final dynamic raw in items) {
        final Map item = raw as Map;
        final int rt = (item['roomTypeId'] as num?)?.toInt() ?? 0;
        if (rt != roomTypeId) continue;
        final int promotionId = (item['promotionId'] as num?)?.toInt() ?? 0;
        final int roomPromotionId = (item['id'] as num?)?.toInt() ?? 0;
        if (promotionId <= 0 || roomPromotionId <= 0) continue;
        promotionIdToRoomPromotionId[promotionId] = roomPromotionId;
      }
      final Set<int> promotionIds = promotionIdToRoomPromotionId.keys.toSet();

      final List<PromotionResponse> all =
          promotionsResult['data'] as List<PromotionResponse>;
      final List<PromotionResponse> active = all
          .where((p) => promotionIds.contains(p.id) && p.isActive)
          .map(
            (p) => PromotionResponse(
              roomPromotionId: promotionIdToRoomPromotionId[p.id],
              id: p.id,
              name: p.name,
              details: p.details,
              banner: p.banner,
              discount: p.discount,
              startTime: p.startTime,
              endTime: p.endTime,
              isActive: p.isActive,
            ),
          )
          .toList()
        ..sort((a, b) => b.discount.compareTo(a.discount));

      return {
        'success': true,
        'data': active,
        'message': 'Lấy danh sách khuyến mãi áp dụng thành công',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi không xác định xảy ra: $e',
      };
    }
  }

  /// Lấy danh sách khuyến mãi đang hoạt động theo mapping `room-promotions`,
  /// và join với data từ `/promotions/getAll` để có đủ thông tin (banner, discount,...).
  Future<Map<String, dynamic>> getActiveRoomPromotionOffers() async {
    try {
      final roomPromotionsResult = await getAllRoomPromotions();
      if (roomPromotionsResult['success'] != true) {
        return roomPromotionsResult;
      }

      final promotionsResult = await getAllPromotions();
      if (promotionsResult['success'] != true) {
        return promotionsResult;
      }

      final List<dynamic> items = roomPromotionsResult['data'] as List<dynamic>;
      final List<PromotionResponse> allPromotions =
          promotionsResult['data'] as List<PromotionResponse>;

      final Map<int, PromotionResponse> promotionById = <int, PromotionResponse>{};
      for (final p in allPromotions) {
        if (p.id > 0) promotionById[p.id] = p;
      }

      final List<RoomPromotionOfferResponse> offers = <RoomPromotionOfferResponse>[];

      for (final dynamic raw in items) {
        if (raw is! Map) continue;

        final int roomPromotionId = (raw['id'] as num?)?.toInt() ?? 0;
        final String roomPromotionDetails = raw['details']?.toString() ?? '';

        final int roomTypeId = (raw['roomTypeId'] as num?)?.toInt() ?? 0;
        final String roomTypeNameRaw = raw['roomTypeName']?.toString() ?? '';

        final int promotionId = (raw['promotionId'] as num?)?.toInt() ?? 0;

        if (roomPromotionId <= 0 || roomTypeId <= 0 || promotionId <= 0) {
          continue;
        }

        final PromotionResponse? p = promotionById[promotionId];
        if (p == null || !p.isActive) continue;

        offers.add(
          RoomPromotionOfferResponse(
            roomPromotionId: roomPromotionId,
            roomPromotionDetails: roomPromotionDetails,
            roomTypeId: roomTypeId,
            roomTypeName:
                roomTypeNameRaw.trim().isNotEmpty ? roomTypeNameRaw : 'Loại phòng #$roomTypeId',
            promotion: PromotionResponse(
              roomPromotionId: roomPromotionId,
              id: p.id,
              name: p.name,
              details: p.details,
              banner: p.banner,
              discount: p.discount,
              startTime: p.startTime,
              endTime: p.endTime,
              isActive: p.isActive,
            ),
          ),
        );
      }

      offers.sort((a, b) {
        final int byDiscount = b.promotion.discount.compareTo(a.promotion.discount);
        if (byDiscount != 0) return byDiscount;
        return a.promotion.name.compareTo(b.promotion.name);
      });

      return {
        'success': true,
        'data': offers,
        'message': 'Lấy danh sách ưu đãi thành công',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi không xác định xảy ra: $e',
      };
    }
  }
}


