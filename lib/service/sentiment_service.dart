import 'dart:io';

import 'package:dio/dio.dart';

class SentimentResult {
  final String label;
  final double pos;
  final double neg;
  final double neu;

  const SentimentResult({
    required this.label,
    required this.pos,
    required this.neg,
    required this.neu,
  });

  factory SentimentResult.fromJson(Map<String, dynamic> json) {
    final rawScores = json['scores'];
    final scores = rawScores is Map
        ? Map<String, dynamic>.from(rawScores as Map)
        : <String, dynamic>{};

    double readScore(String key) {
      final v = scores[key] ?? scores[key.toLowerCase()] ?? scores[key.toUpperCase()];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    return SentimentResult(
      label: (json['label'] ?? '').toString(),
      pos: readScore('POS'),
      neg: readScore('NEG'),
      neu: readScore('NEU'),
    );
  }
}

class SentimentService {
  static const String _path = '/sentiment';
  final Dio _dio;

  SentimentService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: resolveBaseUrl(),
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: const {
                  'Content-Type': 'application/json',
                },
              ),
            );

  static String resolveBaseUrl() {
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  Future<SentimentResult> analyze(String text) async {
    try {
      final res = await _dio.post(_path, data: {'text': text});
      final data = res.data;
      if (data is Map) {
        return SentimentResult.fromJson(Map<String, dynamic>.from(data));
      }
      throw Exception('Response không đúng định dạng JSON object');
    } on DioException catch (e) {
      // Fallback nếu API dùng query param hoặc không cho POST
      final status = e.response?.statusCode;
      if (status == 405 || status == 415 || status == 422) {
        final res = await _dio.get(_path, queryParameters: {'text': text});
        final data = res.data;
        if (data is Map) {
          return SentimentResult.fromJson(Map<String, dynamic>.from(data));
        }
      }
      rethrow;
    }
  }

  /// Công thức đề xuất sao (dùng cả POS/NEG/NEU):
  /// - Lấy độ lệch cảm xúc: (POS - NEG)
  /// - Giảm biên độ theo mức trung tính: * (1 - NEU)
  /// - Map về thang 1..5 quanh mốc 3 sao
  /// - Làm tròn 0.5 sao
  static double suggestStars({
    required double pos,
    required double neg,
    required double neu,
  }) {
    final adjusted = (pos - neg) * (1 - neu);
    final raw = 3 + 2 * adjusted; // [-1..1] -> [1..5]
    final clamped = raw.clamp(1.0, 5.0);
    return (clamped * 2).round() / 2.0;
  }
}


