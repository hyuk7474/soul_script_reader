import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_script_reader/presentation/splash/splash_controller.dart';

import '../../helpers/fakes.dart';

void main() {
  group('SplashController', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    test('initialize 완료 시 isComplete가 true가 된다', () async {
      container = ProviderContainer(
        overrides: [
          appInitializerProvider.overrideWithValue(
            FakeAppInitializer(dio: Dio(), healthCheckPassed: true),
          ),
        ],
      );

      final notifier = container.read(splashControllerProvider.notifier);
      await notifier.initialize();

      final state = container.read(splashControllerProvider);
      expect(state.isComplete, isTrue);
      expect(state.healthCheckPassed, isTrue);
    });

    test('헬스 체크 실패 시 healthCheckPassed가 false다', () async {
      container = ProviderContainer(
        overrides: [
          appInitializerProvider.overrideWithValue(
            FakeAppInitializer(dio: Dio(), healthCheckPassed: false),
          ),
        ],
      );

      final notifier = container.read(splashControllerProvider.notifier);
      await notifier.initialize();

      final state = container.read(splashControllerProvider);
      expect(state.isComplete, isTrue);
      expect(state.healthCheckPassed, isFalse);
    });
  });
}
