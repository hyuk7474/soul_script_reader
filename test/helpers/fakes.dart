import 'package:dio/dio.dart';
import 'package:soul_script_reader/data/datasources/tarot_remote_datasource.dart';
import 'package:soul_script_reader/data/models/draw_result_model.dart';
import 'package:soul_script_reader/data/models/tarot_card_model.dart';
import 'package:soul_script_reader/domain/entities/draw_record.dart';
import 'package:soul_script_reader/domain/entities/draw_result.dart';
import 'package:soul_script_reader/domain/entities/tarot_card.dart';
import 'package:soul_script_reader/domain/repositories/history_repository.dart';
import 'package:soul_script_reader/domain/repositories/tarot_repository.dart';
import 'package:soul_script_reader/presentation/splash/app_initializer.dart';

import 'fixtures.dart';

/// 테스트용 TarotRepository
class FakeTarotRepository implements TarotRepository {
  FakeTarotRepository({
    DrawResult? drawResult,
    this.drawError,
    TarotCard? card,
    this.getByIdError,
  })  : drawResult = drawResult ?? Fixtures.drawResult,
        card = card ?? Fixtures.tarotCard;

  final DrawResult drawResult;
  final Object? drawError;
  final TarotCard card;
  final Object? getByIdError;

  @override
  Future<DrawResult> drawRandom() async {
    if (drawError != null) throw drawError!;
    return drawResult;
  }

  @override
  Future<TarotCard> getById(int id) async {
    if (getByIdError != null) throw getByIdError!;
    return card;
  }
}

/// 테스트용 HistoryRepository
class FakeHistoryRepository implements HistoryRepository {
  FakeHistoryRepository({
    List<DrawRecord>? records,
    this.saveError,
    DrawRecord? savedRecord,
  })  : records = records ?? const [],
        savedRecord = savedRecord ?? Fixtures.drawRecord;

  final List<DrawRecord> records;
  final Object? saveError;
  final DrawRecord savedRecord;

  int saveCallCount = 0;
  int? lastSavedCardId;
  bool? lastSavedIsReversed;

  @override
  Future<List<DrawRecord>> getHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    return records;
  }

  @override
  Future<DrawRecord> save({
    required int cardId,
    required bool isReversed,
    String? note,
  }) async {
    saveCallCount++;
    lastSavedCardId = cardId;
    lastSavedIsReversed = isReversed;
    if (saveError != null) throw saveError!;
    return savedRecord;
  }
}

/// 테스트용 TarotRemoteDataSource
class FakeTarotRemoteDataSource implements TarotRemoteDataSource {
  FakeTarotRemoteDataSource({
    DrawResultModel? drawResultModel,
    this.drawError,
    TarotCardModel? cardModel,
  })  : drawResultModel = drawResultModel ?? Fixtures.drawResultModel,
        cardModel = cardModel ?? Fixtures.tarotCardModel;

  final DrawResultModel drawResultModel;
  final Object? drawError;
  final TarotCardModel cardModel;

  @override
  Future<DrawResultModel> drawRandom() async {
    if (drawError != null) throw drawError!;
    return drawResultModel;
  }

  @override
  Future<TarotCardModel> getById(int id) async {
    return cardModel;
  }
}

/// 테스트용 AppInitializer
class FakeAppInitializer extends AppInitializer {
  FakeAppInitializer({
    required Dio dio,
    this.healthCheckPassed = true,
    this.delay = Duration.zero,
  }) : super(dio);

  final bool healthCheckPassed;
  final Duration delay;

  @override
  Future<AppInitResult> initialize() async {
    await Future<void>.delayed(delay);
    return AppInitResult(healthCheckPassed: healthCheckPassed);
  }
}
