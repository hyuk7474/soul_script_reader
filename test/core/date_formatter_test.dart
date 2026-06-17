import 'package:flutter_test/flutter_test.dart';
import 'package:soul_script_reader/core/utils/date_formatter.dart';

void main() {
  group('formatDrawnAt', () {
    test('UTC 시간을 로컬 yyyy.MM.dd HH:mm 형식으로 포맷한다', () {
      final utc = DateTime.utc(2026, 6, 5, 5, 30);
      final formatted = formatDrawnAt(utc);

      expect(formatted, contains('2026.06.05'));
      expect(formatted, contains(':'));
    });
  });
}
