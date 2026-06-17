import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_script_reader/core/errors/exceptions.dart';
import 'package:soul_script_reader/domain/usecases/draw_random_card.dart';
import 'package:soul_script_reader/domain/usecases/save_draw_history.dart';
import 'package:soul_script_reader/presentation/draw/draw_notifier.dart';
import 'package:soul_script_reader/presentation/providers/providers.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

void main() {
  group('DrawNotifier', () {
    late ProviderContainer container;
    late FakeTarotRepository tarotRepository;
    late FakeHistoryRepository historyRepository;

    setUp(() {
      tarotRepository = FakeTarotRepository();
      historyRepository = FakeHistoryRepository();

      container = ProviderContainer(
        overrides: [
          drawRandomCardProvider.overrideWithValue(
            DrawRandomCard(tarotRepository),
          ),
          saveDrawHistoryProvider.overrideWithValue(
            SaveDrawHistory(historyRepository),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('초기 상태는 idle이다', () {
      final state = container.read(drawNotifierProvider);
      expect(state.status, DrawStatus.idle);
      expect(state.result, isNull);
    });

    test('drawCard 성공 시 revealed 상태가 된다', () async {
      final notifier = container.read(drawNotifierProvider.notifier);

      await notifier.drawCard();

      final state = container.read(drawNotifierProvider);
      expect(state.status, DrawStatus.revealed);
      expect(state.result?.card.nameKo, '바보');
    });

    test('drawCard 실패 시 error 상태와 메시지가 설정된다', () async {
      tarotRepository = FakeTarotRepository(
        drawError: const NetworkException('서버에 연결할 수 없습니다.'),
      );
      container.dispose();
      container = ProviderContainer(
        overrides: [
          drawRandomCardProvider.overrideWithValue(
            DrawRandomCard(tarotRepository),
          ),
          saveDrawHistoryProvider.overrideWithValue(
            SaveDrawHistory(historyRepository),
          ),
        ],
      );

      final notifier = container.read(drawNotifierProvider.notifier);
      await notifier.drawCard();

      final state = container.read(drawNotifierProvider);
      expect(state.status, DrawStatus.error);
      expect(state.errorMessage, '서버에 연결할 수 없습니다.');
    });

    test('saveToHistory 성공 시 saved 상태가 된다', () async {
      final notifier = container.read(drawNotifierProvider.notifier);

      await notifier.drawCard();
      final saved = await notifier.saveToHistory();

      expect(saved, isTrue);
      expect(container.read(drawNotifierProvider).status, DrawStatus.saved);
      expect(historyRepository.saveCallCount, 1);
      expect(historyRepository.lastSavedCardId, Fixtures.tarotCard.id);
    });

    test('reset 호출 시 idle 상태로 돌아간다', () async {
      final notifier = container.read(drawNotifierProvider.notifier);

      await notifier.drawCard();
      notifier.reset();

      final state = container.read(drawNotifierProvider);
      expect(state.status, DrawStatus.idle);
      expect(state.result, isNull);
    });
  });
}
