import 'package:intl/intl.dart';

/// 히스토리 날짜 포맷
String formatDrawnAt(DateTime drawnAt) {
  return DateFormat('yyyy.MM.dd HH:mm').format(drawnAt.toLocal());
}
