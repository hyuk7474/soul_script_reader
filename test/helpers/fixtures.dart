import 'package:soul_script_reader/data/models/draw_record_model.dart';
import 'package:soul_script_reader/data/models/draw_result_model.dart';
import 'package:soul_script_reader/data/models/tarot_card_model.dart';
import 'package:soul_script_reader/domain/entities/draw_record.dart';
import 'package:soul_script_reader/domain/entities/draw_result.dart';
import 'package:soul_script_reader/domain/entities/tarot_card.dart';

/// 테스트용 고정 데이터
abstract final class Fixtures {
  static const tarotCard = TarotCard(
    id: 1,
    code: 'major_00_fool',
    nameEn: 'The Fool',
    nameKo: '바보',
    arcana: 'major',
    number: 0,
    imageUrl: '/assets/cards/00_fool.png',
    meaningUpright: '새로운 시작',
    meaningReversed: '무모함',
  );

  static const drawResult = DrawResult(
    card: tarotCard,
    isReversed: false,
  );

  static const reversedDrawResult = DrawResult(
    card: tarotCard,
    isReversed: true,
  );

  static final drawRecord = DrawRecord(
    id: 101,
    cardId: 1,
    isReversed: false,
    drawnAt: DateTime.utc(2026, 6, 5, 14, 30),
    card: tarotCard,
  );

  static final tarotCardJson = {
    'id': 1,
    'code': 'major_00_fool',
    'name_en': 'The Fool',
    'name_ko': '바보',
    'arcana': 'major',
    'suit': null,
    'number': 0,
    'image_url': '/assets/cards/00_fool.png',
    'meaning_upright': '새로운 시작',
    'meaning_reversed': '무모함',
  };

  static final drawResultJson = {
    'card': tarotCardJson,
    'is_reversed': false,
  };

  static final drawRecordJson = {
    'id': 101,
    'card_id': 1,
    'is_reversed': false,
    'drawn_at': '2026-06-05T14:30:00.000Z',
    'note': null,
    'card': tarotCardJson,
  };

  static TarotCardModel get tarotCardModel =>
      TarotCardModel.fromJson(tarotCardJson);

  static DrawResultModel get drawResultModel =>
      DrawResultModel.fromJson(drawResultJson);

  static DrawRecordModel get drawRecordModel =>
      DrawRecordModel.fromJson(drawRecordJson);
}
