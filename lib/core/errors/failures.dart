/// 도메인·프레젠테이션 계층에서 사용하는 실패 타입
sealed class Failure {
  const Failure(this.message);

  final String message;
}

/// 네트워크 연결 실패
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = '네트워크 연결에 실패했습니다.']);
}

/// 서버 응답 오류
final class ServerFailure extends Failure {
  const ServerFailure([super.message = '서버 오류가 발생했습니다.']);
}

/// 데이터 파싱 오류
final class ParseFailure extends Failure {
  const ParseFailure([super.message = '응답 데이터를 처리할 수 없습니다.']);
}

/// 알 수 없는 오류
final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = '알 수 없는 오류가 발생했습니다.']);
}
