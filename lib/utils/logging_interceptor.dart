import 'dart:developer';

import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
    log("[LoggingInterceptor] Error $err");
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);
    log("[LoggingInterceptor] Request $options");
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
    log("[LoggingInterceptor] Response $response");
  }
}
