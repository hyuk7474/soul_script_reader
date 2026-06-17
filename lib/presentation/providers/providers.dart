import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul_script_reader/core/network/dio_client.dart';
import 'package:soul_script_reader/data/datasources/history_remote_datasource.dart';
import 'package:soul_script_reader/data/datasources/tarot_remote_datasource.dart';
import 'package:soul_script_reader/data/repositories/history_repository_impl.dart';
import 'package:soul_script_reader/data/repositories/tarot_repository_impl.dart';
import 'package:soul_script_reader/domain/repositories/history_repository.dart';
import 'package:soul_script_reader/domain/repositories/tarot_repository.dart';
import 'package:soul_script_reader/domain/usecases/draw_random_card.dart';
import 'package:soul_script_reader/domain/usecases/get_draw_history.dart';
import 'package:soul_script_reader/domain/usecases/get_tarot_card_by_id.dart';
import 'package:soul_script_reader/domain/usecases/save_draw_history.dart';

/// Dio 클라이언트 Provider
final dioProvider = Provider<Dio>((ref) => createDioClient());

/// 타로 원격 DataSource Provider
final tarotRemoteDataSourceProvider = Provider<TarotRemoteDataSource>((ref) {
  return TarotRemoteDataSourceImpl(ref.watch(dioProvider));
});

/// 히스토리 원격 DataSource Provider
final historyRemoteDataSourceProvider = Provider<HistoryRemoteDataSource>((ref) {
  return HistoryRemoteDataSourceImpl(ref.watch(dioProvider));
});

/// 타로 Repository Provider
final tarotRepositoryProvider = Provider<TarotRepository>((ref) {
  return TarotRepositoryImpl(ref.watch(tarotRemoteDataSourceProvider));
});

/// 히스토리 Repository Provider
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl(ref.watch(historyRemoteDataSourceProvider));
});

/// 랜덤 카드 뽑기 UseCase Provider
final drawRandomCardProvider = Provider<DrawRandomCard>((ref) {
  return DrawRandomCard(ref.watch(tarotRepositoryProvider));
});

/// 히스토리 저장 UseCase Provider
final saveDrawHistoryProvider = Provider<SaveDrawHistory>((ref) {
  return SaveDrawHistory(ref.watch(historyRepositoryProvider));
});

/// 히스토리 조회 UseCase Provider
final getDrawHistoryProvider = Provider<GetDrawHistory>((ref) {
  return GetDrawHistory(ref.watch(historyRepositoryProvider));
});

/// 카드 ID 조회 UseCase Provider
final getTarotCardByIdProvider = Provider<GetTarotCardById>((ref) {
  return GetTarotCardById(ref.watch(tarotRepositoryProvider));
});
