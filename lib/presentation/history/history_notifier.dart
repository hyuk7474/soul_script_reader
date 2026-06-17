import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul_script_reader/domain/entities/draw_record.dart';
import 'package:soul_script_reader/presentation/providers/providers.dart';

/// 카드 내역 Notifier
class HistoryNotifier extends AsyncNotifier<List<DrawRecord>> {
  @override
  Future<List<DrawRecord>> build() async {
    return _fetchHistory();
  }

  Future<List<DrawRecord>> _fetchHistory() {
    return ref.read(getDrawHistoryProvider).call();
  }

  /// 목록 새로고침 (화면 진입·pull-to-refresh 시)
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchHistory);
  }
}

/// 카드 내역 Notifier Provider
final historyNotifierProvider =
    AsyncNotifierProvider<HistoryNotifier, List<DrawRecord>>(
  HistoryNotifier.new,
);
