import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soul_script_reader/data/models/tarot_card_model.dart';
import 'package:soul_script_reader/domain/entities/draw_result.dart';

part 'draw_result_model.freezed.dart';
part 'draw_result_model.g.dart';

/// 랜덤 뽑기 결과 JSON 모델
@freezed
abstract class DrawResultModel with _$DrawResultModel {
  const DrawResultModel._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory DrawResultModel({
    required TarotCardModel card,
    required bool isReversed,
  }) = _DrawResultModel;

  factory DrawResultModel.fromJson(Map<String, dynamic> json) =>
      _$DrawResultModelFromJson(json);

  /// Entity로 변환
  DrawResult toEntity() {
    return DrawResult(
      card: card.toEntity(),
      isReversed: isReversed,
    );
  }
}
