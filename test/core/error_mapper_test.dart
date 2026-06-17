import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_script_reader/core/errors/error_mapper.dart';
import 'package:soul_script_reader/core/errors/exceptions.dart';
import 'package:soul_script_reader/core/errors/failures.dart';

void main() {
  group('mapExceptionToFailure', () {
    test('NetworkException을 NetworkFailure로 변환한다', () {
      const exception = NetworkException('연결 실패');
      final failure = mapExceptionToFailure(exception);

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, '연결 실패');
    });

    test('ServerException을 ServerFailure로 변환한다', () {
      const exception = ServerException('서버 오류 (500)');
      final failure = mapExceptionToFailure(exception);

      expect(failure, isA<ServerFailure>());
      expect(failure.message, '서버 오류 (500)');
    });

    test('DioException을 NetworkFailure로 변환한다', () {
      final failure = mapExceptionToFailure(
        DioException(requestOptions: RequestOptions(path: '/health')),
      );

      expect(failure, isA<NetworkFailure>());
    });

    test('알 수 없는 예외를 UnknownFailure로 변환한다', () {
      final failure = mapExceptionToFailure(Exception('unknown'));

      expect(failure, isA<UnknownFailure>());
    });
  });
}
