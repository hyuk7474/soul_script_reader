import 'package:flutter_test/flutter_test.dart';
import 'package:soul_script_reader/data/models/draw_record_model.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('DrawRecordModel', () {
    test('JSON에서 모델을 파싱한다', () {
      final model = DrawRecordModel.fromJson(Fixtures.drawRecordJson);

      expect(model.id, 101);
      expect(model.cardId, 1);
      expect(model.isReversed, isFalse);
      expect(model.card?.nameKo, '바보');
    });

    test('모델을 Entity로 변환한다', () {
      final entity = Fixtures.drawRecordModel.toEntity();

      expect(entity.id, Fixtures.drawRecord.id);
      expect(entity.card?.nameKo, '바보');
      expect(entity.isReversed, isFalse);
    });
  });
}
