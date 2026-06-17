import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soul_script_reader/domain/entities/tarot_card.dart';

part 'tarot_card_model.freezed.dart';
part 'tarot_card_model.g.dart';

/// 타로 카드 JSON 모델
@freezed
abstract class TarotCardModel with _$TarotCardModel {
  const TarotCardModel._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TarotCardModel({
    required int id,
    required String code,
    required String nameEn,
    required String nameKo,
    required String arcana,
    String? suit,
    int? number,
    String? imageUrl,
    required String meaningUpright,
    required String meaningReversed,
  }) = _TarotCardModel;

  factory TarotCardModel.fromJson(Map<String, dynamic> json) =>
      _$TarotCardModelFromJson(json);

  /// Entity로 변환
  TarotCard toEntity() {
    return TarotCard(
      id: id,
      code: code,
      nameEn: nameEn,
      nameKo: nameKo,
      arcana: arcana,
      suit: suit,
      number: number,
      imageUrl: imageUrl,
      meaningUpright: meaningUpright,
      meaningReversed: meaningReversed,
    );
  }
}
