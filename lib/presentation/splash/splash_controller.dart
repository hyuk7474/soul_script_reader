import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul_script_reader/presentation/providers/providers.dart';
import 'package:soul_script_reader/presentation/splash/app_initializer.dart';

/// 스플래시 화면 상태
class SplashState {
  const SplashState({
    this.isComplete = false,
    this.healthCheckPassed = true,
  });

  /// 초기화 완료 여부 (메인 이동 트리거)
  final bool isComplete;

  /// API 헬스 체크 성공 여부
  final bool healthCheckPassed;

  SplashState copyWith({
    bool? isComplete,
    bool? healthCheckPassed,
  }) {
    return SplashState(
      isComplete: isComplete ?? this.isComplete,
      healthCheckPassed: healthCheckPassed ?? this.healthCheckPassed,
    );
  }
}

/// AppInitializer Provider
final appInitializerProvider = Provider<AppInitializer>((ref) {
  return AppInitializer(ref.watch(dioProvider));
});

/// 스플래시 초기화 컨트롤러
class SplashController extends Notifier<SplashState> {
  @override
  SplashState build() => const SplashState();

  /// 초기화 실행
  Future<void> initialize() async {
    final result = await ref.read(appInitializerProvider).initialize();
    state = state.copyWith(
      isComplete: true,
      healthCheckPassed: result.healthCheckPassed,
    );
  }
}

/// 스플래시 컨트롤러 Provider
final splashControllerProvider =
    NotifierProvider<SplashController, SplashState>(SplashController.new);
