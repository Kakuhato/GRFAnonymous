import 'dart:async';

import '../pageRequest/cookieInterceptor.dart';
import 'hivUtil.dart';

/// 会话版本隔离旧请求，防止重新登录后被旧的 401 再次退出。
class AuthSession {
  static final instance = AuthSession._();
  AuthSession._();

  int revision = 0;
  bool _expired = false;
  Future<void>? _clearing;
  void Function()? onExpired;

  String get token => HiveUtil.instance().getString(HiveUtil.tokenKey, defaultValue: '');

  void expire(int requestRevision) {
    if (requestRevision != revision || _expired) return;
    _expired = true;
    revision++;
    _clearing = _clearCredentials();
    unawaited(_clearing!.catchError((Object _) {}));
    // 导航不等待磁盘清理；登录保存前会等待同一清理任务。
    onExpired?.call();
  }

  Future<void> _clearCredentials() async {
    try {
      await HiveUtil.instance().setString(HiveUtil.tokenKey, '');
    } finally {
      // Cookie 清理失败也不应阻塞登录页或产生未处理异常。
      try { await CookieInterceptor.clear(); } catch (_) {}
    }
  }

  Future<void> waitForCredentialCleanup() async {
    await _clearing;
  }

  Future<void> saveToken(String value) async {
    if (value.isEmpty) throw const FormatException('登录响应缺少凭证');
    await _clearing;
    revision++;
    await HiveUtil.instance().setString(HiveUtil.tokenKey, value);
    _expired = false;
  }

  Future<void> logout() async {
    revision++;
    _expired = true;
    _clearing = _clearCredentials();
    await _clearing;
  }

  bool get expired => _expired;
}
