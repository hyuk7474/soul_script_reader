import 'package:soul_script_reader/domain/entities/draw_result.dart';
import 'package:soul_script_reader/domain/repositories/tarot_repository.dart';

/// 랜덤 카드 뽑기 UseCase
class DrawRandomCard {
  const DrawRandomCard(this._repository);

  final TarotRepository _repository;

  Future<DrawResult> call() => _repository.drawRandom();
}
