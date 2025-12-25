import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logging interceptor for debugging API calls
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        '→ ${options.method} ${options.path}',
        name: 'API',
      );
      if (options.data != null) {
        developer.log('  Body: ${options.data}', name: 'API');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        '← ${response.statusCode} ${response.requestOptions.path}',
        name: 'API',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        '✗ ${err.response?.statusCode ?? 'ERR'} ${err.requestOptions.path}',
        name: 'API',
        error: err.message,
      );
    }
    handler.next(err);
  }
}

/// Auth interceptor for token management
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Token is already set in ApiClient.setAuthToken()
    // This interceptor can add additional auth logic
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle token refresh or logout
      // In a real app, you'd trigger a token refresh here
      developer.log('Auth token expired', name: 'API');
    }
    handler.next(err);
  }
}

/// Retry interceptor for transient failures
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor(
    this.dio, {
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    // Only retry on specific errors
    final shouldRetry = _shouldRetry(err) && retryCount < maxRetries;

    if (shouldRetry) {
      await Future.delayed(retryDelay * (retryCount + 1));

      err.requestOptions.extra['retryCount'] = retryCount + 1;

      if (kDebugMode) {
        developer.log(
          '↻ Retry ${retryCount + 1}/$maxRetries: ${err.requestOptions.path}',
          name: 'API',
        );
      }

      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Continue to next error handler
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500 &&
            err.response!.statusCode! < 600);
  }
}

/// Simple in-memory cache interceptor
class CacheInterceptor extends Interceptor {
  final Map<String, _CacheEntry> _cache = {};
  final Duration cacheDuration;

  CacheInterceptor({this.cacheDuration = const Duration(minutes: 5)});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Only cache GET requests
    if (options.method != 'GET') {
      handler.next(options);
      return;
    }

    // Check for force refresh
    if (options.extra['forceRefresh'] == true) {
      handler.next(options);
      return;
    }

    final key = _getCacheKey(options);
    final cached = _cache[key];

    if (cached != null && !cached.isExpired) {
      if (kDebugMode) {
        developer.log('⚡ Cache hit: ${options.path}', name: 'API');
      }
      handler.resolve(
        Response(
          requestOptions: options,
          data: cached.data,
          statusCode: 200,
        ),
      );
      return;
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Only cache successful GET responses
    if (response.requestOptions.method == 'GET' &&
        response.statusCode == 200) {
      final key = _getCacheKey(response.requestOptions);
      _cache[key] = _CacheEntry(
        data: response.data,
        expiry: DateTime.now().add(cacheDuration),
      );
    }
    handler.next(response);
  }

  String _getCacheKey(RequestOptions options) {
    return '${options.method}:${options.uri}';
  }

  void clear() {
    _cache.clear();
  }

  void remove(String path) {
    _cache.removeWhere((key, _) => key.contains(path));
  }
}

class _CacheEntry {
  final dynamic data;
  final DateTime expiry;

  _CacheEntry({required this.data, required this.expiry});

  bool get isExpired => DateTime.now().isAfter(expiry);
}
