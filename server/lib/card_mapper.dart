/// DB Row를 JSON Map으로 변환
Map<String, dynamic> mapTarotCardRow(Map<String, dynamic> row) {
  return {
    'id': row['id'],
    'code': row['code'],
    'name_en': row['name_en'],
    'name_ko': row['name_ko'],
    'arcana': row['arcana'],
    'suit': row['suit'],
    'number': row['number'],
    'image_url': row['image_url'],
    'meaning_upright': row['meaning_upright'],
    'meaning_reversed': row['meaning_reversed'],
  };
}

/// 히스토리 Row를 JSON Map으로 변환 (카드 정보 포함)
Map<String, dynamic> mapDrawHistoryRow(Map<String, dynamic> row) {
  final drawnAt = row['drawn_at'];
  final isReversed = row['is_reversed'];

  return {
    'id': row['id'],
    'card_id': row['card_id'],
    'is_reversed': isReversed is bool
        ? isReversed
        : isReversed is int
            ? isReversed == 1
            : isReversed.toString() == '1',
    'drawn_at': drawnAt is DateTime
        ? drawnAt.toUtc().toIso8601String()
        : drawnAt.toString(),
    'note': row['note'],
    'card': {
      'id': row['card_id'],
      'code': row['code'],
      'name_en': row['name_en'],
      'name_ko': row['name_ko'],
      'arcana': row['arcana'],
      'suit': row['suit'],
      'number': row['number'],
      'image_url': row['image_url'],
      'meaning_upright': row['meaning_upright'],
      'meaning_reversed': row['meaning_reversed'],
    },
  };
}
