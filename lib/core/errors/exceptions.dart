/// 데이터 계층 예외
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;
}

/// 네트워크 예외
final class NetworkException extends AppException {
  const NetworkException([super.message = '네트워크 연결에 실패했습니다.']);
}

/// 서버 예외
final class ServerException extends AppException {
  const ServerException([super.message = '서버 오류가 발생했습니다.']);
}

/// 파싱 예외
final class ParseException extends AppException {
  const ParseException([super.message = '응답 데이터를 처리할 수 없습니다.']);
}
