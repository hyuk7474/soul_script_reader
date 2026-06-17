import 'package:dio/dio.dart';
import 'package:soul_script_reader/core/constants/api_paths.dart';
import 'package:soul_script_reader/core/errors/error_mapper.dart';
import 'package:soul_script_reader/core/errors/exceptions.dart';
import 'package:soul_script_reader/data/models/draw_record_model.dart';

/// 히스토리 원격 DataSource 인터페이스
abstract class HistoryRemoteDataSource {
  Future<List<DrawRecordModel>> getHistory({
    int limit = 50,
    int offset = 0,
  });

  Future<DrawRecordModel> save({
    required int cardId,
    required bool isReversed,
    String? note,
  });
}

/// 히스토리 원격 DataSource 구현
class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  const HistoryRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<DrawRecordModel>> getHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiPaths.history,
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      final data = response.data?['data'];

      if (data is! List) {
        throw const ParseException('히스토리 응답 형식이 올바르지 않습니다.');
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(DrawRecordModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throwDioException(error);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ParseException('히스토리 응답을 파싱할 수 없습니다.');
    }
  }

  @override
  Future<DrawRecordModel> save({
    required int cardId,
    required bool isReversed,
    String? note,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiPaths.history,
        data: {
          'card_id': cardId,
          'is_reversed': isReversed,
          'note': ?note,
        },
      );
      final data = response.data?['data'];

      if (data is! Map<String, dynamic>) {
        throw const ParseException('히스토리 저장 응답 형식이 올바르지 않습니다.');
      }

      return DrawRecordModel.fromJson(data);
    } on DioException catch (error) {
      throwDioException(error);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ParseException('히스토리 저장 응답을 파싱할 수 없습니다.');
    }
  }
}
