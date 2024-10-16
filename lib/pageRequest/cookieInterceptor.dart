import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:grfanonymous/utils/fileUtil.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class CookieInterceptor {
  static CookieJar? cookieJar;
  static CookieManager? cookieManager;

  static init() async {
    cookieJar = PersistCookieJar(
      storage: FileStorage(await FileUtil.getCookieDir()),
    );
    cookieManager = CookieManager(cookieJar!);
  }

  static clear() {
    cookieJar!.deleteAll();
  }
}
