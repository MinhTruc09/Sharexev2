import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sharexev2/config/env.dart';

/// ApiClient with pluggable token provider and refresh hook.
/// Use `ApiClient.tokenProvider = () async => '<token>'` and
/// `ApiClient.refreshTokenProvider = () async => true` to integrate with
/// your auth manager/mock service.
class ApiClient {
  final Dio client;

  /// Global token getter. Set this from your auth manager.
  static Future<String?> Function()? tokenProvider;

  /// Global refresh token function. Should attempt refresh and return true if
  /// refresh succeeded.
  static Future<bool> Function()? refreshTokenProvider;

  ApiClient._internal(this.client);

  factory ApiClient() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env().fullApiUrl,
        connectTimeout: const Duration(seconds: 30), // Increased timeout
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        validateStatus: (status) {
          return status != null &&
              status < 500; // Accept all responses below 500
        },
      ),
    );

    // Interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            if (tokenProvider != null) {
              final token = await tokenProvider!();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            }
          } catch (_) {
            // ignore token errors; proceed without token
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          final response = err.response;
          // Only handle 401 once per request
          final requestOptions = err.requestOptions;
          final alreadyRetried = requestOptions.extra['__retried'] == true;

          if (response != null &&
              response.statusCode == 401 &&
              !alreadyRetried) {
            if (refreshTokenProvider != null) {
              try {
                final refreshed = await refreshTokenProvider!();
                if (refreshed) {
                  // mark retried and retry original request with new token
                  requestOptions.extra['__retried'] = true;
                  // get latest token
                  final newToken =
                      tokenProvider != null ? await tokenProvider!() : null;
                  if (newToken != null) {
                    requestOptions.headers['Authorization'] =
                        'Bearer $newToken';
                  }
                  final opts = Options(
                    method: requestOptions.method,
                    headers: requestOptions.headers,
                    responseType: requestOptions.responseType,
                    contentType: requestOptions.contentType,
                    extra: requestOptions.extra,
                  );
                  try {
                    final cloneResp = await dio.request<dynamic>(
                      requestOptions.path,
                      data: requestOptions.data,
                      queryParameters: requestOptions.queryParameters,
                      options: opts,
                    );
                    return handler.resolve(cloneResp);
                  } catch (e) {
                    // fall through to original error
                  }
                }
              } catch (_) {
                // refresh failed; continue to error handler below
              }
            }
          }

          // Enhanced retry logic for network errors with exponential backoff
          final isNetworkError =
              response == null &&
              (err.type == DioExceptionType.connectionTimeout ||
                  err.type == DioExceptionType.receiveTimeout ||
                  err.type == DioExceptionType.sendTimeout ||
                  err.type == DioExceptionType.connectionError);
          if (isNetworkError) {
            final int retryCount =
                (requestOptions.extra['__retry_count'] as int?) ?? 0;
            if (retryCount < 3) {
              // Increased max retries
              final backoffMs =
                  1000 * (1 << retryCount); // Exponential backoff: 1s, 2s, 4s
              if (kDebugMode) {
                print(
                  'Retrying request (${retryCount + 1}/3) after ${backoffMs}ms',
                );
              }
              await Future<void>.delayed(Duration(milliseconds: backoffMs));
              requestOptions.extra['__retry_count'] = retryCount + 1;
              try {
                final retryResp = await dio.request<dynamic>(
                  requestOptions.path,
                  data: requestOptions.data,
                  queryParameters: requestOptions.queryParameters,
                  options: Options(
                    method: requestOptions.method,
                    headers: requestOptions.headers,
                    responseType: requestOptions.responseType,
                    contentType: requestOptions.contentType,
                    extra: requestOptions.extra,
                  ),
                );
                return handler.resolve(retryResp);
              } catch (_) {}
            }
          }

          handler.next(err);
        },
      ),
    );

    // Optional detailed logging in debug mode
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return ApiClient._internal(dio);
  }
}
