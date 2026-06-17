import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('TarotCard', () {
    test('정방향일 때 meaningUpright를 반환한다', () {
      expect(
        Fixtures.tarotCard.meaningFor(isReversed: false),
        '새로운 시작',
      );
    });

    test('역방향일 때 meaningReversed를 반환한다', () {
      expect(
        Fixtures.tarotCard.meaningFor(isReversed: true),
        '무모함',
      );
    });
  });
}
