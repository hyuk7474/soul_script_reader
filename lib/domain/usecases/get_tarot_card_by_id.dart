import 'package:soul_script_reader/domain/entities/tarot_card.dart';
import 'package:soul_script_reader/domain/repositories/tarot_repository.dart';

/// ID로 타로 카드 조회 UseCase
class GetTarotCardById {
  const GetTarotCardById(this._repository);

  final TarotRepository _repository;

  Future<TarotCard> call(int id) => _repository.getById(id);
}
