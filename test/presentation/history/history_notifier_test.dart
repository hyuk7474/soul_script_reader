import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_script_reader/core/errors/exceptions.dart';
import 'package:soul_script_reader/domain/entities/draw_record.dart';
import 'package:soul_script_reader/domain/repositories/history_repository.dart';
import 'package:soul_script_reader/domain/usecases/get_draw_history.dart';
import 'package:soul_script_reader/presentation/history/history_notifier.dart';
import 'package:soul_script_reader/presentation/providers/providers.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

void main() {
  group('HistoryNotifier', () {
    late ProviderContainer container;
    late FakeHistoryRepository historyRepository;

    setUp(() {
      historyRepository = FakeHistoryRepository(
        records: [Fixtures.drawRecord],
      );

      container = ProviderContainer(
        overrides: [
          getDrawHistoryProvider.overrideWithValue(
            GetDrawHistory(historyRepository),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('build 시 히스토리 목록을 로드한다', () async {
      final records = await container.read(historyNotifierProvider.future);

      expect(records, hasLength(1));
      expect(records.first.card?.nameKo, '바보');
    });

    test('refresh 시 목록을 다시 로드한다', () async {
      await container.read(historyNotifierProvider.future);

      historyRepository = FakeHistoryRepository(
        records: [Fixtures.drawRecord, Fixtures.drawRecord],
      );
      container.dispose();
      container = ProviderContainer(
        overrides: [
          getDrawHistoryProvider.overrideWithValue(
            GetDrawHistory(historyRepository),
          ),
        ],
      );

      await container.read(historyNotifierProvider.notifier).refresh();
      final state = container.read(historyNotifierProvider);

      expect(state.value, hasLength(2));
    });

    test('로드 실패 시 error 상태가 된다', () async {
      historyRepository = FakeHistoryRepository();
      container.dispose();
      container = ProviderContainer(
        overrides: [
          getDrawHistoryProvider.overrideWithValue(
            GetDrawHistory(_ThrowingHistoryRepository()),
          ),
        ],
      );

      await container.read(historyNotifierProvider.notifier).refresh();
      final state = container.read(historyNotifierProvider);

      expect(state.hasError, isTrue);
    });
  });
}

/// 항상 예외를 던지는 HistoryRepository
class _ThrowingHistoryRepository implements HistoryRepository {
  @override
  Future<List<DrawRecord>> getHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    throw const NetworkException('연결 실패');
  }

  @override
  Future<DrawRecord> save({
    required int cardId,
    required bool isReversed,
    String? note,
  }) async {
    throw UnimplementedError();
  }
}
