import 'dart:developer';
import 'package:dio/dio.dart';

class PrintLogInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log("\n================== 请求数据 ==========================");
    options.headers.forEach((key, value) {
      log("请求头: $key: $value");
    });
    log("请求url: ${options.uri}");
    log("请求方法: ${options.method}");
    log("请求参数: ${options.data}");
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log("\n================== 响应数据 ==========================");
    log("请求url: ${response.realUri}");
    log("响应头: ${response.headers.toString()}");
    log("响应数据: ${response.data}");
    log("响应状态: ${response.statusCode}");
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log("\n================== 错误响应数据 ==========================");
    log("错误信息: ${err.toString()}");
    super.onError(err, handler);
  }
}