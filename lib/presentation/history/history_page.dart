import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul_script_reader/app/theme/app_theme.dart';
import 'package:soul_script_reader/core/errors/error_mapper.dart';
import 'package:soul_script_reader/core/utils/date_formatter.dart';
import 'package:soul_script_reader/domain/entities/draw_record.dart';
import 'package:soul_script_reader/presentation/common/widgets/cached_card_image.dart';
import 'package:soul_script_reader/presentation/common/widgets/primary_nav_button.dart';
import 'package:soul_script_reader/presentation/history/history_notifier.dart';

/// 카드 내역 화면
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  void initState() {
    super.initState();
    // draw 저장 후 진입 등 최신 목록 반영
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(historyNotifierProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('카드 내역')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: mapExceptionToFailure(error).message,
          onRetry: () => ref.read(historyNotifierProvider.notifier).refresh(),
        ),
        data: (records) => _HistoryBody(
          records: records,
          onRefresh: () => ref.read(historyNotifierProvider.notifier).refresh(),
          onTap: _showDetailSheet,
        ),
      ),
    );
  }

  void _showDetailSheet(DrawRecord record) {
    final card = record.card;
    if (card == null) return;

    final meaning = card.meaningFor(isReversed: record.isReversed);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                    _OrientationChip(isReversed: record.isReversed),
                    IconButton(
                      onPressed: null,
                      icon: Icon(Icons.close, color: Colors.transparent),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  card.nameKo,
                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  formatDrawnAt(record.drawnAt),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CachedCardImage(
                  imageUrl: card.imageUrl!,
                  width: double.infinity,
                ),
                Text(
                  meaning,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 히스토리 목록 본문
class _HistoryBody extends StatelessWidget {
  const _HistoryBody({
    required this.records,
    required this.onRefresh,
    required this.onTap,
  });

  final List<DrawRecord> records;
  final Future<void> Function() onRefresh;
  final void Function(DrawRecord record) onTap;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: AppTheme.accent,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox(height: 120), _EmptyState()],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.accent,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: records.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final record = records[index];
          return _HistoryListTile(record: record, onTap: () => onTap(record));
        },
      ),
    );
  }
}

/// 히스토리 ListTile
class _HistoryListTile extends StatelessWidget {
  const _HistoryListTile({required this.record, required this.onTap});

  final DrawRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardName = record.card?.nameKo ?? '카드 #${record.cardId}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppTheme.primary,
        child: Icon(
          record.isReversed ? Icons.flip : Icons.style,
          color: AppTheme.accent,
          size: 22,
        ),
      ),
      title: Text(
        cardName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${formatDrawnAt(record.drawnAt)} · ${record.isReversed ? '역방향' : '정방향'}',
        style: theme.textTheme.bodyLarge?.copyWith(fontSize: 13),
      ),
      trailing: _OrientationChip(isReversed: record.isReversed, compact: true),
      onTap: record.card != null ? onTap : null,
    );
  }
}

/// 정/역 방향 칩
class _OrientationChip extends StatelessWidget {
  const _OrientationChip({required this.isReversed, this.compact = false});

  final bool isReversed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: isReversed
            ? Colors.deepPurple.withValues(alpha: 0.3)
            : AppTheme.accent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isReversed ? '역' : '정',
        style: TextStyle(
          color: isReversed ? Colors.deepPurpleAccent : AppTheme.accent,
          fontSize: compact ? 12 : 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 빈 목록 상태
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.colorScheme.secondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 뽑은 카드가 없습니다',
            style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '카드 뽑기에서 타로 카드를 뽑고\n히스토리에 저장해보세요',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 에러 뷰
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
          const SizedBox(height: 24),
          PrimaryNavButton(
            label: '다시 시도',
            icon: Icons.refresh,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
