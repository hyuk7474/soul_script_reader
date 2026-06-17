import 'package:dio/dio.dart';

/// 앱 초기화 결과
class AppInitResult {
  const AppInitResult({required this.healthCheckPassed});

  /// API 헬스 체크 성공 여부
  final bool healthCheckPassed;
}

/// 앱 시작 시 초기화 (헬스 체크 등)
class AppInitializer {
  const AppInitializer(this._dio);

  final Dio _dio;

  static const Duration _minSplashDuration = Duration(seconds: 2);
  static const Duration _healthCheckTimeout = Duration(seconds: 2);

  /// 최소 2초 대기 후 헬스 체크 결과와 함께 반환
  Future<AppInitResult> initialize() async {
    final healthFuture = _checkHealth();

    await Future<void>.delayed(_minSplashDuration);

    var healthCheckPassed = false;
    try {
      healthCheckPassed = await healthFuture.timeout(_healthCheckTimeout);
    } catch (_) {
      healthCheckPassed = false;
    }

    return AppInitResult(healthCheckPassed: healthCheckPassed);
  }

  /// API 서버 헬스 체크 (실패해도 앱 진행 가능)
  Future<bool> _checkHealth() async {
    try {
      final response = await _dio.get<dynamic>(
        '/health',
        options: Options(
          sendTimeout: _healthCheckTimeout,
          receiveTimeout: _healthCheckTimeout,
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
