import 'package:soul_script_reader/domain/entities/draw_record.dart';

/// 히스토리 Repository 인터페이스
abstract class HistoryRepository {
  Future<List<DrawRecord>> getHistory({
    int limit = 50,
    int offset = 0,
  });

  Future<DrawRecord> save({
    required int cardId,
    required bool isReversed,
    String? note,
  });
}
