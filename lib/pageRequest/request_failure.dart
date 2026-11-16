import 'dart:io';

import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';

enum FailureKind { connection, timeout, unauthorized, forbidden, notFound, server, business, invalidData, cancelled }

class RequestFailure implements Exception {
  const RequestFailure(this.kind, this.message);

  final FailureKind kind;
  final String message;
  bool get isNetwork => kind == FailureKind.connection || kind == FailureKind.timeout;
  bool get isSilent => kind == FailureKind.cancelled || kind == FailureKind.unauthorized;

  static RequestFailure from(Object error) {
    if (error is RequestFailure) return error;
    if (error is DioException) {
      if (error.error is RequestFailure) return error.error as RequestFailure;
      switch (error.type) {
        case DioExceptionType.cancel:
          return const RequestFailure(FailureKind.cancelled, '请求已取消');
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const RequestFailure(FailureKind.timeout, '请求超时，请重试');
        case DioExceptionType.connectionError:
          return const RequestFailure(FailureKind.connection, '无法连接服务器，请检查网络');
        case DioExceptionType.badCertificate:
          return const RequestFailure(FailureKind.server, '无法建立安全连接，请检查设备时间或网络');
        default:
          break;
      }
      final status = error.response?.statusCode;
      if (status == 401) return const RequestFailure(FailureKind.unauthorized, '登录已过期，请重新登录');
      if (status == 403) return const RequestFailure(FailureKind.forbidden, '暂无权限访问此内容');
      if (status == 404) return const RequestFailure(FailureKind.notFound, '内容不存在或已删除');
      if (status != null && status >= 500) return const RequestFailure(FailureKind.server, '服务暂时不可用，请稍后重试');
      if (error.error is SocketException) return const RequestFailure(FailureKind.connection, '无法连接服务器，请检查网络');
      return const RequestFailure(FailureKind.server, '请求失败，请稍后重试');
    }
    return const RequestFailure(FailureKind.invalidData, '数据加载异常，请重试');
  }

  static String? _lastMessage;
  static DateTime? _lastShown;

  static void notify(Object error) {
    final failure = from(error);
    if (failure.isSilent) return;
    final now = DateTime.now();
    if (_lastMessage == failure.message && _lastShown != null &&
        now.difference(_lastShown!) < const Duration(seconds: 2)) return;
    _lastMessage = failure.message;
    _lastShown = now;
    showToast(failure.message);
  }

  @override
  String toString() => message;
}

// 写操作只做防重入与错误收尾，绝不自动重试。
final _pendingActions = <String>{};
Future<bool> runRequestAction(String key, Future<bool> Function() action) async {
  if (!_pendingActions.add(key)) return false;
  try {
    return await action();
  } catch (error) {
    RequestFailure.notify(error);
    return false;
  } finally {
    _pendingActions.remove(key);
  }
}
