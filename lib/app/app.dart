import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul_script_reader/app/router/app_router.dart';
import 'package:soul_script_reader/app/theme/app_theme.dart';

/// 앱 루트 위젯
class SoulScriptReaderApp extends ConsumerWidget {
  const SoulScriptReaderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Soul Script Reader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
