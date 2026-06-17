import 'package:soul_script_reader/domain/entities/draw_record.dart';
import 'package:soul_script_reader/domain/repositories/history_repository.dart';

/// 뽑기 히스토리 저장 UseCase
class SaveDrawHistory {
  const SaveDrawHistory(this._repository);

  final HistoryRepository _repository;

  Future<DrawRecord> call({
    required int cardId,
    required bool isReversed,
    String? note,
  }) {
    return _repository.save(
      cardId: cardId,
      isReversed: isReversed,
      note: note,
    );
  }
}
