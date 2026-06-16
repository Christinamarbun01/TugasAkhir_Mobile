import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/prediction_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class DetectionService {
  late final Dio _dio;

  DetectionService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugLog(obj.toString()),
      ),
    );
  }

  void debugLog(String msg) {
    // Only log in debug mode
    assert(() {
      // ignore: avoid_print
      print('[DetectionService] $msg');
      return true;
    }());
  }

  Future<PredictionResponse> predict(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        AppConstants.predictEndpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return PredictionResponse.fromJson(response.data!);
      } else {
        throw ApiException(
          message: 'Unexpected response status',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Koneksi timeout. Periksa server Anda.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Tidak dapat terhubung ke server.'
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?.toString() ?? 'Server error';
        return ApiException(
          message: 'Server error: $message',
          statusCode: statusCode,
        );
      default:
        return ApiException(message: 'Error jaringan: ${e.message}');
    }
  }
}
