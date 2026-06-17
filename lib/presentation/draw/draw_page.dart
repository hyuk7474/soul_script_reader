import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soul_script_reader/app/theme/app_theme.dart';
import 'package:soul_script_reader/domain/entities/draw_result.dart';
import 'package:soul_script_reader/presentation/common/widgets/cached_card_image.dart';
import 'package:soul_script_reader/presentation/common/widgets/primary_nav_button.dart';
import 'package:soul_script_reader/presentation/draw/draw_notifier.dart';

/// 카드 뽑기 화면
class DrawPage extends ConsumerStatefulWidget {
  const DrawPage({super.key});

  @override
  ConsumerState<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends ConsumerState<DrawPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drawState = ref.watch(drawNotifierProvider);
    final theme = Theme.of(context);

    ref.listen<DrawState>(drawNotifierProvider, (previous, next) {
      if (previous?.status != DrawStatus.revealed &&
          next.status == DrawStatus.revealed) {
        _flipController.forward(from: 0);
      }
      if (previous?.status != DrawStatus.saved &&
          next.status == DrawStatus.saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('히스토리에 저장되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('카드 뽑기')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildCardArea(drawState, theme)),
              if (drawState.errorMessage != null) ...[
                _ErrorBanner(message: drawState.errorMessage!),
                const SizedBox(height: 16),
              ],
              _buildActions(drawState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardArea(DrawState drawState, ThemeData theme) {
    final showFront =
        drawState.result != null &&
        drawState.status != DrawStatus.drawing &&
        drawState.status != DrawStatus.idle;

    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: drawState.status == DrawStatus.drawing
            ? _DrawingIndicator(key: const ValueKey('drawing'))
            : showFront
            ? _CardFront(
                key: ValueKey(drawState.result!.card.id),
                result: drawState.result!,
                flipAnimation: _flipController,
              )
            : _CardBack(key: const ValueKey('back'), theme: theme),
      ),
    );
  }

  Widget _buildActions(DrawState drawState) {
    if (drawState.status == DrawStatus.idle ||
        (drawState.status == DrawStatus.error && drawState.result == null)) {
      return PrimaryNavButton(
        label: drawState.status == DrawStatus.error ? '다시 시도' : '카드 뽑기',
        icon: Icons.style,
        onPressed: drawState.isLoading
            ? null
            : () => ref.read(drawNotifierProvider.notifier).drawCard(),
      );
    }

    if (drawState.result == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (drawState.canSave)
          PrimaryNavButton(
            label: drawState.status == DrawStatus.saving
                ? '저장 중...'
                : '히스토리에 저장',
            icon: Icons.bookmark_add_outlined,
            onPressed: drawState.isLoading
                ? null
                : () => ref.read(drawNotifierProvider.notifier).saveToHistory(),
          ),
        if (drawState.status == DrawStatus.saved) ...[
          const SizedBox(height: 8),
          Text(
            '저장 완료',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.accent.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: drawState.isLoading
                    ? null
                    : () => ref.read(drawNotifierProvider.notifier).reset(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('다시 뽑기'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: drawState.isLoading
                    ? null
                    : () => context.push('/history'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('내역 보기'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 카드 뒷면
class _CardBack extends StatelessWidget {
  const _CardBack({super.key, required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.surface],
        ),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 56,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'SOUL',
            style: theme.textTheme.headlineMedium?.copyWith(
              letterSpacing: 4,
              color: AppTheme.accent,
            ),
          ),
        ],
      ),
    );
  }
}

/// 뽑기 중 인디케이터
class _DrawingIndicator extends StatelessWidget {
  const _DrawingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 220,
          height: 320,
          child: Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.secondary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('카드를 뽑는 중...', style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

/// 카드 앞면 (해석 표시)
class _CardFront extends StatelessWidget {
  const _CardFront({
    super.key,
    required this.result,
    required this.flipAnimation,
  });

  final DrawResult result;
  final Animation<double> flipAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = result.card;
    final meaning = card.meaningFor(isReversed: result.isReversed);
    print('card.imageUrl: ${card.imageUrl}');

    return AnimatedBuilder(
      animation: flipAnimation,
      builder: (context, child) {
        final angle = flipAnimation.value * 3.14159;
        final isUnder = angle > 1.5708;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: isUnder
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(3.14159),
                  child: child,
                )
              : child,
        );
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),

          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                _OrientationBadge(isReversed: result.isReversed),
                const SizedBox(height: 16),
                Text(
                  card.nameKo,
                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  card.nameEn,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                if (card.imageUrl != null && card.imageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  CachedCardImage(
                    imageUrl: card.imageUrl!,
                    width: double.infinity,
                  ),
                ],
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    meaning,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 정/역 방향 뱃지
class _OrientationBadge extends StatelessWidget {
  const _OrientationBadge({required this.isReversed});

  final bool isReversed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isReversed
            ? Colors.deepPurple.withValues(alpha: 0.4)
            : AppTheme.accent.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isReversed ? Colors.deepPurpleAccent : AppTheme.accent,
        ),
      ),
      child: Text(
        isReversed ? '역방향' : '정방향',
        style: TextStyle(
          color: isReversed ? Colors.deepPurpleAccent : AppTheme.accent,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// 에러 배너
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
