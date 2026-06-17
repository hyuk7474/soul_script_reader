import 'package:dio/dio.dart';
import 'package:soul_script_reader/core/errors/exceptions.dart';
import 'package:soul_script_reader/core/errors/failures.dart';

/// 예외를 Failure로 변환
Failure mapExceptionToFailure(Object error) {
  return switch (error) {
    NetworkException(:final message) => NetworkFailure(message),
    ServerException(:final message) => ServerFailure(message),
    ParseException(:final message) => ParseFailure(message),
    DioException() => const NetworkFailure(),
    _ => UnknownFailure(error.toString()),
  };
}

/// Dio 오류를 AppException으로 변환
Never throwDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      throw const NetworkException('서버에 연결할 수 없습니다.');
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      throw ServerException('서버 오류 ($statusCode)');
    default:
      throw NetworkException(error.message ?? '네트워크 오류');
  }
}
