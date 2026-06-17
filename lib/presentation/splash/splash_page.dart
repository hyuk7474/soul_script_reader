import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soul_script_reader/app/theme/app_theme.dart';
import 'package:soul_script_reader/presentation/splash/splash_controller.dart';

/// 스플래시 화면
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashControllerProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SplashState>(splashControllerProvider, (previous, next) {
      if (next.isComplete && previous?.isComplete != true) {
        if (!next.healthCheckPassed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('서버에 연결할 수 없습니다. 오프라인으로 계속합니다.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        context.go('/main');
      }
    });

    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.background,
              AppTheme.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Icon(
                  Icons.auto_awesome,
                  size: 80,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(height: 28),
                Text(
                  'Soul Script Reader',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '타로 카드로 오늘의 메시지를 읽어보세요',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white60,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 2),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '준비 중...',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.accent.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
