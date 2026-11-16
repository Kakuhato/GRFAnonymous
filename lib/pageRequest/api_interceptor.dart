import 'package:dio/dio.dart';

import '../utils/auth_session.dart';
import 'request_failure.dart';

class ApiInterceptor extends Interceptor {
  bool _isLogin(RequestOptions request) => request.path.startsWith('/login/');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final session = AuthSession.instance;
    if (_isLogin(options)) {
      try { await session.waitForCredentialCleanup(); }
      catch (_) {
        handler.reject(DioException(requestOptions: options,
          error: const RequestFailure(FailureKind.invalidData, '登录信息清理失败，请重启应用后重试')));
        return;
      }
    }
    options.extra['sessionRevision'] = session.revision;
    if (!_isLogin(options)) {
      if (session.expired) {
        handler.reject(DioException(requestOptions: options,
          error: const RequestFailure(FailureKind.unauthorized, '请先登录')));
        return;
      }
      if (session.token.isNotEmpty) options.headers['Authorization'] = session.token;
    }
    handler.next(options);
  }

  bool _stale(RequestOptions options) =>
      options.extra['sessionRevision'] != AuthSession.instance.revision;

  DioException _error(Response response, RequestFailure failure) => DioException(
    requestOptions: response.requestOptions, response: response,
    type: DioExceptionType.badResponse, error: failure,
  );

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_stale(response.requestOptions)) {
      handler.reject(DioException(requestOptions: response.requestOptions, type: DioExceptionType.cancel));
      return;
    }
    final body = response.data;
    if (body is! Map || !body.containsKey('Code')) {
      handler.reject(_error(response, const RequestFailure(FailureKind.invalidData, '服务器响应格式异常，请重试')));
      return;
    }
    final code = '${body['Code']}';
    if (code == '401' && !_isLogin(response.requestOptions)) {
      AuthSession.instance.expire(response.requestOptions.extra['sessionRevision'] as int);
      handler.reject(_error(response, const RequestFailure(FailureKind.unauthorized, '登录已过期，请重新登录')));
      return;
    }
    final signIn = response.requestOptions.path == '/community/task/sign_in' ||
        response.requestOptions.path == '/community/task/get_current_sign_in_status';
    if (code != '0' && !(signIn && code == '30010')) {
      final message = body['Message']?.toString();
      handler.reject(_error(response, RequestFailure(
        code == '20005' ? FailureKind.notFound : FailureKind.business,
        code == '20005' ? '帖子不存在或已删除' :
            (message == null || message.isEmpty ? '操作失败，请重试' : message),
      )));
      return;
    }
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    if (_stale(error.requestOptions)) {
      handler.next(DioException(requestOptions: error.requestOptions, type: DioExceptionType.cancel));
      return;
    }
    if (error.response?.statusCode == 401 && !_isLogin(error.requestOptions)) {
      AuthSession.instance.expire(error.requestOptions.extra['sessionRevision'] as int);
      handler.next(error.copyWith(error: const RequestFailure(FailureKind.unauthorized, '登录已过期，请重新登录')));
      return;
    }
    // 登录接口的 401 是本次登录失败，不应再次触发全局导航。
    if (_isLogin(error.requestOptions) && error.response?.statusCode == 401) {
      final body = error.response?.data;
      handler.next(error.copyWith(error: RequestFailure(FailureKind.business,
        body is Map ? (body['Message']?.toString() ?? '登录失败，请检查账号信息') : '登录失败，请检查账号信息')));
      return;
    }
    handler.next(error);
  }
}
