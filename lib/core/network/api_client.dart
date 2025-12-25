import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_interceptors.dart';

/// API client configuration
class ApiConfig {
  static const String baseUrl = 'https://api.jobdiscover.example.com/v1';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

/// Singleton API client with Dio
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  factory ApiClient() {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    // Logging interceptor (debug only)
    if (kDebugMode) {
      _dio.interceptors.add(LoggingInterceptor());
    }

    // Auth interceptor
    _dio.interceptors.add(AuthInterceptor());

    // Retry interceptor
    _dio.interceptors.add(RetryInterceptor(_dio));

    // Cache interceptor
    _dio.interceptors.add(CacheInterceptor());
  }

  /// Update auth token
  void setAuthToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  /// Clear all cached data
  void clearCache() {
    // Implementation would clear the cache interceptor's storage
  }
}

/// API response wrapper
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int? statusCode;

  const ApiResponse({
    this.data,
    this.message,
    required this.success,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse(
      data: data,
      success: true,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      message: message,
      success: false,
      statusCode: statusCode,
    );
  }
}

/// API exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Connection timed out. Please try again.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No internet connection. Please check your network.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String message = 'Something went wrong';

        if (data is Map && data.containsKey('message')) {
          message = data['message'];
        } else if (statusCode == 401) {
          message = 'Unauthorized. Please log in again.';
        } else if (statusCode == 403) {
          message = 'Access denied.';
        } else if (statusCode == 404) {
          message = 'Resource not found.';
        } else if (statusCode == 500) {
          message = 'Server error. Please try again later.';
        }

        return ApiException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
      case DioExceptionType.cancel:
        return const ApiException(message: 'Request cancelled');
      default:
        return ApiException(message: error.message ?? 'Unknown error occurred');
    }
  }

  @override
  String toString() => message;
}
