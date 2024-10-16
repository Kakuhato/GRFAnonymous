import 'dart:io';

import 'package:grfanonymous/pageRequest/cookieInterceptor.dart';
import 'package:grfanonymous/pageRequest/printLogInterceptor.dart';
import 'package:dio/dio.dart';

//筛选条件
enum SortType {
  reply(1, "最近回复"),
  post(2, "最新发布"),
  hot(3, "热度");

  final int type;
  final String description;

  const SortType(this.type, this.description);
}

//发现，休息室，攻略，同人，世界观，官方
enum CategoryId {
  none(100, "没有这一栏"),
  recommend(1, "发现"),
  restroom(2, "休息室"),
  strategy(3, "攻略");

  final int type;
  final String description;

  const CategoryId(this.type, this.description);
}

//主页下栏目
enum QueryType {
  homepage(1, "主页"),
  follow(3, "关注"),
  identity(4, "我的");

  final int type;
  final String description;

  const QueryType(this.type, this.description);
}

class HttpMethod {
  static const String GET = "GET";
  static const String POST = "POST";
  static const String PUT = "PUT";
  static const String DELETE = "DELETE";
}

class DioInstance {
  static DioInstance? _instance;

  DioInstance._();

  static DioInstance instance() {
    return _instance ??= DioInstance._();
  }

  final Dio _dio = Dio();
  final _defaultTimeout = const Duration(seconds: 30);

  Future<void> initDio({
    required String baseUrl,
    String? httpMethod = HttpMethod.GET,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    ResponseType? responseType,
    String? contentType,
  }) async {
    _dio.options = BaseOptions(
      method: httpMethod,
      baseUrl: baseUrl,
      connectTimeout: connectTimeout ?? _defaultTimeout,
      receiveTimeout: receiveTimeout ?? _defaultTimeout,
      sendTimeout: sendTimeout ?? _defaultTimeout,
      responseType: responseType ?? ResponseType.json,
      contentType: contentType,
    );
    // cookie拦截器
    _dio.interceptors.add(CookieInterceptor.cookieManager!);
    //一般拦截器
    _dio.interceptors.add(PrintLogInterceptor());
  }

  Future<Response> get({
    required String path,
    Map<String, dynamic>? param,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.get(
      path,
      queryParameters: param,
      options: options ??
          Options(
            method: HttpMethod.GET,
            receiveTimeout: _defaultTimeout,
            sendTimeout: _defaultTimeout,
          ),
      cancelToken: cancelToken,
    );
  }

  Future<Response> post({
    required String path,
    Map<String, dynamic>? param,
    Options? options,
    CancelToken? cancelToken,
    dynamic data,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: param,
      options: options ??
          Options(
            method: HttpMethod.POST,
            receiveTimeout: _defaultTimeout,
            sendTimeout: _defaultTimeout,
          ),
      cancelToken: cancelToken,
    );
  }
}
