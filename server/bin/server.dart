import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dotenv/dotenv.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:soul_script_reader_server/card_mapper.dart';
import 'package:soul_script_reader_server/database.dart';

Future<void> main() async {
  final env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
  final config = DatabaseConfig.fromEnv({
    'MYSQL_HOST': env['MYSQL_HOST'] ?? '127.0.0.1',
    'MYSQL_PORT': env['MYSQL_PORT'] ?? '3306',
    'MYSQL_USER': env['MYSQL_USER'] ?? 'soul_app',
    'MYSQL_PASSWORD': env['MYSQL_PASSWORD'] ?? '',
    'MYSQL_DATABASE': env['MYSQL_DATABASE'] ?? 'soul_script_reader',
  });
  final database = Database(config);
  final port = int.tryParse(env['PORT'] ?? '') ?? 8080;
  final random = Random();

  final router = Router();

  // 랜덤 카드 뽑기
  router.get('/api/v1/cards/random', (Request request) async {
    try {
      final conn = await database.connection;
      final result = await conn.execute(
        '''
        SELECT id, code, name_en, name_ko, arcana, suit, number,
               image_url, meaning_upright, meaning_reversed
        FROM tarot_cards
        ORDER BY RAND()
        LIMIT 1
        ''',
      );

      if (result.rows.isEmpty) {
        return _jsonResponse({'error': '카드 데이터가 없습니다.'}, statusCode: 404);
      }

      final card = mapTarotCardRow(result.rows.first.typedAssoc());
      final isReversed = random.nextBool();

      return _jsonResponse({
        'data': {
          'card': card,
          'is_reversed': isReversed,
        },
      });
    } catch (error) {
      return _jsonResponse({'error': error.toString()}, statusCode: 500);
    }
  });

  // 카드 ID 조회
  router.get('/api/v1/cards/<id>', (Request request, String id) async {
    try {
      final cardId = int.tryParse(id);
      if (cardId == null) {
        return _jsonResponse({'error': '잘못된 카드 ID입니다.'}, statusCode: 400);
      }

      final conn = await database.connection;
      final result = await conn.execute(
        '''
        SELECT id, code, name_en, name_ko, arcana, suit, number,
               image_url, meaning_upright, meaning_reversed
        FROM tarot_cards
        WHERE id = :cardId
        LIMIT 1
        ''',
        {'cardId': cardId},
      );

      if (result.rows.isEmpty) {
        return _jsonResponse({'error': '카드를 찾을 수 없습니다.'}, statusCode: 404);
      }

      return _jsonResponse({
        'data': mapTarotCardRow(result.rows.first.typedAssoc()),
      });
    } catch (error) {
      return _jsonResponse({'error': error.toString()}, statusCode: 500);
    }
  });

  // 히스토리 목록
  router.get('/api/v1/history', (Request request) async {
    try {
      final limit =
          int.tryParse(request.url.queryParameters['limit'] ?? '50') ?? 50;
      final offset =
          int.tryParse(request.url.queryParameters['offset'] ?? '0') ?? 0;

      final conn = await database.connection;
      final result = await conn.execute(
        '''
        SELECT h.id, h.card_id, h.is_reversed, h.drawn_at, h.note,
               c.code, c.name_en, c.name_ko, c.arcana, c.suit, c.number,
               c.image_url, c.meaning_upright, c.meaning_reversed
        FROM draw_history h
        INNER JOIN tarot_cards c ON c.id = h.card_id
        ORDER BY h.drawn_at DESC
        LIMIT :limit OFFSET :offset
        ''',
        {'limit': limit, 'offset': offset},
      );

      final data =
          result.rows.map((row) => mapDrawHistoryRow(row.typedAssoc())).toList();
      return _jsonResponse({'data': data});
    } catch (error) {
      return _jsonResponse({'error': error.toString()}, statusCode: 500);
    }
  });

  // 히스토리 저장
  router.post('/api/v1/history', (Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final rawCardId = json['card_id'];
      final cardId = switch (rawCardId) {
        int value => value,
        num value => value.toInt(),
        _ => null,
      };
      final isReversed = json['is_reversed'] as bool? ?? false;
      final note = json['note'] as String?;

      if (cardId == null) {
        return _jsonResponse({'error': 'card_id는 필수입니다.'}, statusCode: 400);
      }

      final conn = await database.connection;
      final insertResult = await conn.execute(
        '''
        INSERT INTO draw_history (card_id, is_reversed, note)
        VALUES (:cardId, :isReversed, :note)
        ''',
        {
          'cardId': cardId,
          'isReversed': isReversed ? 1 : 0,
          'note': note,
        },
      );

      final historyId = insertResult.lastInsertID.toInt();
      final result = await conn.execute(
        '''
        SELECT h.id, h.card_id, h.is_reversed, h.drawn_at, h.note,
               c.code, c.name_en, c.name_ko, c.arcana, c.suit, c.number,
               c.image_url, c.meaning_upright, c.meaning_reversed
        FROM draw_history h
        INNER JOIN tarot_cards c ON c.id = h.card_id
        WHERE h.id = :historyId
        LIMIT 1
        ''',
        {'historyId': historyId},
      );

      if (result.rows.isEmpty) {
        return _jsonResponse({'error': '저장된 히스토리를 찾을 수 없습니다.'}, statusCode: 500);
      }

      return _jsonResponse({
        'data': mapDrawHistoryRow(result.rows.first.typedAssoc()),
      });
    } catch (error) {
      return _jsonResponse({'error': error.toString()}, statusCode: 500);
    }
  });

  // 헬스 체크
  router.get('/health', (Request request) {
    return _jsonResponse({'status': 'ok'});
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  stdout.writeln(
    'Soul Script Reader API 서버가 http://${server.address.host}:${server.port} 에서 실행 중입니다.',
  );
}

Response _jsonResponse(
  Map<String, dynamic> body, {
  int statusCode = 200,
}) {
  return Response(
    statusCode,
    body: jsonEncode(body),
    headers: {'Content-Type': 'application/json; charset=utf-8'},
  );
}
