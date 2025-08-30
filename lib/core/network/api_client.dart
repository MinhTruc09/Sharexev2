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
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json"},
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
