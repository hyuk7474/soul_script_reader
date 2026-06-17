import 'package:soul_script_reader/domain/entities/draw_result.dart';
import 'package:soul_script_reader/domain/entities/tarot_card.dart';
import 'package:soul_script_reader/domain/repositories/tarot_repository.dart';
import 'package:soul_script_reader/data/datasources/tarot_remote_datasource.dart';

/// 타로 카드 Repository 구현
class TarotRepositoryImpl implements TarotRepository {
  const TarotRepositoryImpl(this._remoteDataSource);

  final TarotRemoteDataSource _remoteDataSource;

  @override
  Future<DrawResult> drawRandom() async {
    final model = await _remoteDataSource.drawRandom();
    return model.toEntity();
  }

  @override
  Future<TarotCard> getById(int id) async {
    final model = await _remoteDataSource.getById(id);
    return model.toEntity();
  }
}
