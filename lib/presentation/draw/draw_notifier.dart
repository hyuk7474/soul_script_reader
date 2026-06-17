import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul_script_reader/core/errors/error_mapper.dart';
import 'package:soul_script_reader/domain/entities/draw_result.dart';
import 'package:soul_script_reader/presentation/providers/providers.dart';

/// 카드 뽑기 화면 상태
enum DrawStatus {
  idle,
  drawing,
  revealed,
  saving,
  saved,
  error,
}

/// 카드 뽑기 Notifier 상태
class DrawState {
  const DrawState({
    required this.status,
    this.result,
    this.errorMessage,
  });

  const DrawState.initial()
      : status = DrawStatus.idle,
        result = null,
        errorMessage = null;

  final DrawStatus status;
  final DrawResult? result;
  final String? errorMessage;

  bool get isLoading =>
      status == DrawStatus.drawing || status == DrawStatus.saving;

  bool get canDraw =>
      status == DrawStatus.idle ||
      status == DrawStatus.revealed ||
      status == DrawStatus.saved ||
      status == DrawStatus.error;

  bool get canSave =>
      result != null &&
      (status == DrawStatus.revealed || status == DrawStatus.error);

  DrawState copyWith({
    DrawStatus? status,
    DrawResult? result,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return DrawState(
      status: status ?? this.status,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// 카드 뽑기 Notifier
class DrawNotifier extends Notifier<DrawState> {
  @override
  DrawState build() => const DrawState.initial();

  /// 랜덤 카드 뽑기
  Future<void> drawCard() async {
    if (state.isLoading) return;

    state = state.copyWith(
      status: DrawStatus.drawing,
      clearError: true,
      clearResult: true,
    );

    try {
      final result = await ref.read(drawRandomCardProvider).call();
      state = state.copyWith(
        status: DrawStatus.revealed,
        result: result,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: DrawStatus.error,
        errorMessage: mapExceptionToFailure(error).message,
        clearResult: true,
      );
    }
  }

  /// 히스토리에 저장
  Future<bool> saveToHistory() async {
    final result = state.result;
    if (result == null || state.isLoading) return false;

    state = state.copyWith(status: DrawStatus.saving, clearError: true);

    try {
      await ref.read(saveDrawHistoryProvider).call(
            cardId: result.card.id,
            isReversed: result.isReversed,
          );
      state = state.copyWith(status: DrawStatus.saved, clearError: true);
      return true;
    } catch (error) {
      state = state.copyWith(
        status: DrawStatus.error,
        errorMessage: mapExceptionToFailure(error).message,
      );
      return false;
    }
  }

  /// 다시 뽑기 (idle로 초기화)
  void reset() {
    state = const DrawState.initial();
  }
}

/// 카드 뽑기 Notifier Provider
final drawNotifierProvider =
    NotifierProvider<DrawNotifier, DrawState>(DrawNotifier.new);
