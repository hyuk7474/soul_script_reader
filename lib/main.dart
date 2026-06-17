import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul_script_reader/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env 미존재 시에도 골격 단계에서는 앱 실행 가능
  }

  runApp(const ProviderScope(child: SoulScriptReaderApp()));
}
