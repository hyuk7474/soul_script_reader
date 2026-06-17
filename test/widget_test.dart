import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul_script_reader/app/app.dart';
import 'package:soul_script_reader/presentation/splash/app_initializer.dart';
import 'package:soul_script_reader/presentation/splash/splash_controller.dart';

void main() {
  testWidgets('앱이 정상적으로 부팅된다', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appInitializerProvider.overrideWithValue(
            _FakeAppInitializer(),
          ),
        ],
        child: const SoulScriptReaderApp(),
      ),
    );

    // 스플래시 화면 표시
    expect(find.text('Soul Script Reader'), findsOneWidget);

    // 초기화 완료 후 메인 화면 진입
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('카드 뽑기'), findsOneWidget);
    expect(find.text('카드 내역'), findsOneWidget);
  });
}

/// 테스트용 AppInitializer (네트워크·dotenv 없이 부팅 검증)
class _FakeAppInitializer extends AppInitializer {
  _FakeAppInitializer() : super(Dio());

  @override
  Future<AppInitResult> initialize() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return const AppInitResult(healthCheckPassed: true);
  }
}
