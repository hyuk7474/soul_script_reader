import 'package:soul_script_reader/domain/entities/tarot_card.dart';

/// 랜덤 뽑기 결과 엔티티
class DrawResult {
  const DrawResult({
    required this.card,
    required this.isReversed,
  });

  final TarotCard card;
  final bool isReversed;
}
