import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_log.dart';

const petstoreBaseUrl = 'https://petstore3.swagger.io/api/v3';

/// DIO: the single, app-wide HTTP client.
///
/// Exposed through a Riverpod [Provider] so that:
///  * every feature shares the same configuration and interceptors, and
///  * tests can swap it with `ProviderScope(overrides: [dioProvider.overrideWithValue(fake)])`.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: petstoreBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    // 1. Adds a header to every request (where you'd put an auth token).
    ApiKeyInterceptor(),
    // 2. Records every request into a Riverpod provider so the UI can show it.
    NetworkLogInterceptor(ref.read(networkLogProvider.notifier)),
    // 3. Dio's built-in console logger (debug builds only).
    if (kDebugMode) LogInterceptor(requestBody: true, responseBody: false),
  ]);

  // Clean up when the provider is disposed.
  ref.onDispose(dio.close);
  return dio;
});

/// DIO INTERCEPTOR: runs code before each request / after each response.
/// Typical uses: auth tokens, refreshing expired tokens, retries, logging.
class ApiKeyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // The Petstore accepts a dummy key called "special-key".
    options.headers['api_key'] = 'special-key';
    handler.next(options); // continue to the next interceptor / the network
  }
}

/// Feeds requests into [NetworkLogNotifier] so the in-app inspector updates live.
class NetworkLogInterceptor extends Interceptor {
  NetworkLogInterceptor(this._log);

  final NetworkLogNotifier _log;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Stash the log id on the request so we can find it again in onResponse.
    options.extra['logId'] = _log.started(
      options.method,
      options.uri.toString(),
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log.finished(
      response.requestOptions.extra['logId'] as int,
      statusCode: response.statusCode,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log.finished(
      err.requestOptions.extra['logId'] as int,
      statusCode: err.response?.statusCode,
      error: err.type.name,
    );
    handler.next(err);
  }
}

/// Turns any [DioException] into a short message a human can read.
String describeDioError(Object error) {
  if (error is! DioException) return error.toString();
  return switch (error.type) {
    DioExceptionType.connectionTimeout => 'Connection timed out',
    DioExceptionType.receiveTimeout => 'Server took too long to respond',
    DioExceptionType.sendTimeout => 'Sending the request took too long',
    DioExceptionType.transformTimeout => 'Decoding the response took too long',
    DioExceptionType.badResponse =>
      'Server replied ${error.response?.statusCode}: ${error.response?.data}',
    DioExceptionType.cancel => 'Request was cancelled',
    DioExceptionType.connectionError => 'No internet connection?',
    DioExceptionType.badCertificate => 'Bad SSL certificate',
    DioExceptionType.unknown => 'Unexpected error: ${error.error}',
  };
}
