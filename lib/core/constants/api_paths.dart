/// REST API 경로 상수
abstract final class ApiPaths {
  static const String apiV1 = '/api/v1';
  static const String cards = '$apiV1/cards';
  static const String cardsRandom = '$apiV1/cards/random';
  static const String history = '$apiV1/history';

  static String cardById(int id) => '$apiV1/cards/$id';
}
