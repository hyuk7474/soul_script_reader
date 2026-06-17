import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Base URL 조회 (dotenv 미로드 시 기본값 사용)
String resolveApiBaseUrl() {
  try {
    return dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8080';
  } catch (_) {
    return 'http://127.0.0.1:8080';
  }
}

/// Dio 인스턴스 생성
Dio createDioClient() {
  final baseUrl = resolveApiBaseUrl();

  return Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );
}
