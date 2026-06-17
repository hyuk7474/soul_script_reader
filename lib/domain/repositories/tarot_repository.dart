import 'package:soul_script_reader/domain/entities/draw_result.dart';
import 'package:soul_script_reader/domain/entities/tarot_card.dart';

/// 타로 카드 Repository 인터페이스
abstract class TarotRepository {
  Future<DrawResult> drawRandom();

  Future<TarotCard> getById(int id);
}
