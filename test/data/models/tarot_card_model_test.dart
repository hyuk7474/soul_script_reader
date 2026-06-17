import 'package:flutter_test/flutter_test.dart';
import 'package:soul_script_reader/data/models/tarot_card_model.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('TarotCardModel', () {
    test('JSON에서 모델을 파싱한다', () {
      final model = TarotCardModel.fromJson(Fixtures.tarotCardJson);

      expect(model.id, 1);
      expect(model.nameKo, '바보');
      expect(model.nameEn, 'The Fool');
      expect(model.meaningUpright, '새로운 시작');
    });

    test('모델을 Entity로 변환한다', () {
      final entity = Fixtures.tarotCardModel.toEntity();

      expect(entity.id, Fixtures.tarotCard.id);
      expect(entity.nameKo, Fixtures.tarotCard.nameKo);
      expect(entity.code, Fixtures.tarotCard.code);
    });
  });
}
