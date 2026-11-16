import 'dart:developer';
import 'package:dio/dio.dart';

// 不记录请求体、查询参数、凭证和完整响应，避免日志包含登录信息。
class PrintLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['startedAt'] = DateTime.now();
    handler.next(options);
  }

  void _record(RequestOptions request, String result) {
    final start = request.extra['startedAt'];
    final elapsed = start is DateTime ? DateTime.now().difference(start).inMilliseconds : 0;
    log('${request.method} ${request.path} $result ${elapsed}ms', name: 'API');
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _record(response.requestOptions, 'HTTP ${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    _record(error.requestOptions, 'HTTP ${error.response?.statusCode ?? "-"} ${error.type.name}');
    handler.next(error);
  }
}
