import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soul_script_reader/data/models/tarot_card_model.dart';
import 'package:soul_script_reader/domain/entities/draw_record.dart';

part 'draw_record_model.freezed.dart';
part 'draw_record_model.g.dart';

/// 뽑기 히스토리 JSON 모델
@freezed
abstract class DrawRecordModel with _$DrawRecordModel {
  const DrawRecordModel._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory DrawRecordModel({
    required int id,
    required int cardId,
    required bool isReversed,
    required DateTime drawnAt,
    TarotCardModel? card,
    String? note,
  }) = _DrawRecordModel;

  factory DrawRecordModel.fromJson(Map<String, dynamic> json) =>
      _$DrawRecordModelFromJson(json);

  /// Entity로 변환
  DrawRecord toEntity() {
    return DrawRecord(
      id: id,
      cardId: cardId,
      isReversed: isReversed,
      drawnAt: drawnAt,
      card: card?.toEntity(),
      note: note,
    );
  }
}
