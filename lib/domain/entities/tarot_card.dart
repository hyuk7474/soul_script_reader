/// 타로 카드 엔티티
class TarotCard {
  const TarotCard({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.nameKo,
    required this.arcana,
    required this.meaningUpright,
    required this.meaningReversed,
    this.suit,
    this.number,
    this.imageUrl,
  });

  final int id;
  final String code;
  final String nameEn;
  final String nameKo;
  final String arcana;
  final String? suit;
  final int? number;
  final String? imageUrl;
  final String meaningUpright;
  final String meaningReversed;

  /// 정/역 방향에 따른 해석 반환
  String meaningFor({required bool isReversed}) {
    return isReversed ? meaningReversed : meaningUpright;
  }
}
