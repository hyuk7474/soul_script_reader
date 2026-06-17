import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soul_script_reader/app/theme/app_theme.dart';
import 'package:soul_script_reader/presentation/common/widgets/primary_nav_button.dart';

/// 메인 화면
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Soul Script Reader')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 2),
                    Icon(
                      Icons.auto_awesome,
                      size: 64,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '오늘의 카드',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 26,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '타로 카드를 뽑거나\n지금까지의 기록을 확인해보세요',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white60,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(flex: 3),
                    PrimaryNavButton(
                      label: '카드 뽑기',
                      icon: Icons.style,
                      onPressed: () => context.push('/draw'),
                    ),
                    const SizedBox(height: 16),
                    PrimaryNavButton(
                      label: '카드 내역',
                      icon: Icons.history,
                      onPressed: () => context.push('/history'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '뽑은 카드는 히스토리에 저장됩니다',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.accent.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
              const _DataSourceAttribution(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 카드 데이터 출처 로고 (동일 높이·원본 비율 유지)
class _DataSourceAttribution extends StatelessWidget {
  const _DataSourceAttribution();

  static const _logoHeight = 22.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          '데이터 출처',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white38,
            fontSize: 11,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: _SourceLogo(
                  assetPath: 'assets/images/logo/logo_src_biddy_tarot.png',
                  semanticLabel: 'Biddy Tarot',
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _SourceLogo(
                assetPath: 'assets/images/logo/logo_src_labyrinthos.png',
                semanticLabel: 'Labyrinthos',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SourceLogo extends StatelessWidget {
  const _SourceLogo({required this.assetPath, required this.semanticLabel});

  final String assetPath;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Image.asset(
        assetPath,
        height: _DataSourceAttribution._logoHeight,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
