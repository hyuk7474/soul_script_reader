import 'package:flutter_test/flutter_test.dart';
import 'package:soul_script_reader/data/repositories/tarot_repository_impl.dart';
import 'package:soul_script_reader/core/errors/exceptions.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

void main() {
  group('TarotRepositoryImpl', () {
    test('drawRandom은 DrawResult Entity를 반환한다', () async {
      final repository = TarotRepositoryImpl(
        FakeTarotRemoteDataSource(),
      );

      final result = await repository.drawRandom();

      expect(result.card.nameKo, Fixtures.tarotCard.nameKo);
      expect(result.isReversed, isFalse);
    });

    test('getById는 TarotCard Entity를 반환한다', () async {
      final repository = TarotRepositoryImpl(
        FakeTarotRemoteDataSource(),
      );

      final card = await repository.getById(1);

      expect(card.id, 1);
      expect(card.nameKo, '바보');
    });

    test('DataSource 오류를 그대로 전파한다', () async {
      final repository = TarotRepositoryImpl(
        FakeTarotRemoteDataSource(
          drawError: const NetworkException('연결 실패'),
        ),
      );

      expect(
        repository.drawRandom(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
