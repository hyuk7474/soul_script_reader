import 'package:soul_script_reader/domain/entities/draw_record.dart';
import 'package:soul_script_reader/domain/repositories/history_repository.dart';
import 'package:soul_script_reader/data/datasources/history_remote_datasource.dart';

/// 히스토리 Repository 구현
class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._remoteDataSource);

  final HistoryRemoteDataSource _remoteDataSource;

  @override
  Future<List<DrawRecord>> getHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    final models = await _remoteDataSource.getHistory(
      limit: limit,
      offset: offset,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<DrawRecord> save({
    required int cardId,
    required bool isReversed,
    String? note,
  }) async {
    final model = await _remoteDataSource.save(
      cardId: cardId,
      isReversed: isReversed,
      note: note,
    );
    return model.toEntity();
  }
}
