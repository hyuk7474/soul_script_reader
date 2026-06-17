import 'package:soul_script_reader/domain/entities/tarot_card.dart';

/// 뽑기 히스토리 엔티티
class DrawRecord {
  const DrawRecord({
    required this.id,
    required this.cardId,
    required this.isReversed,
    required this.drawnAt,
    this.card,
    this.note,
  });

  final int id;
  final int cardId;
  final bool isReversed;
  final DateTime drawnAt;
  final TarotCard? card;
  final String? note;
}
