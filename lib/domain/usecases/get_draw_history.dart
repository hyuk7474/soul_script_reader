import 'package:soul_script_reader/domain/entities/draw_record.dart';
import 'package:soul_script_reader/domain/repositories/history_repository.dart';

/// 뽑기 히스토리 조회 UseCase
class GetDrawHistory {
  const GetDrawHistory(this._repository);

  final HistoryRepository _repository;

  Future<List<DrawRecord>> call({
    int limit = 50,
    int offset = 0,
  }) {
    return _repository.getHistory(limit: limit, offset: offset);
  }
}
