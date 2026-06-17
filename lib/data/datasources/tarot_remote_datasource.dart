import 'package:dio/dio.dart';
import 'package:soul_script_reader/core/constants/api_paths.dart';
import 'package:soul_script_reader/core/errors/error_mapper.dart';
import 'package:soul_script_reader/core/errors/exceptions.dart';
import 'package:soul_script_reader/data/models/draw_result_model.dart';
import 'package:soul_script_reader/data/models/tarot_card_model.dart';

/// 타로 카드 원격 DataSource 인터페이스
abstract class TarotRemoteDataSource {
  Future<DrawResultModel> drawRandom();

  Future<TarotCardModel> getById(int id);
}

/// 타로 카드 원격 DataSource 구현
class TarotRemoteDataSourceImpl implements TarotRemoteDataSource {
  const TarotRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<DrawResultModel> drawRandom() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiPaths.cardsRandom);
      final data = response.data?['data'];

      if (data is! Map<String, dynamic>) {
        throw const ParseException('랜덤 뽑기 응답 형식이 올바르지 않습니다.');
      }

      return DrawResultModel.fromJson(data);
    } on DioException catch (error) {
      throwDioException(error);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ParseException('랜덤 뽑기 응답을 파싱할 수 없습니다.');
    }
  }

  @override
  Future<TarotCardModel> getById(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiPaths.cardById(id));
      final data = response.data?['data'];

      if (data is! Map<String, dynamic>) {
        throw const ParseException('카드 응답 형식이 올바르지 않습니다.');
      }

      return TarotCardModel.fromJson(data);
    } on DioException catch (error) {
      throwDioException(error);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ParseException('카드 응답을 파싱할 수 없습니다.');
    }
  }
}
