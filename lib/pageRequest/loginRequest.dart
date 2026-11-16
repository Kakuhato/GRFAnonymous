import '../utils/auth_session.dart';
import 'dart:convert';
import 'package:oktoast/oktoast.dart';
import 'package:crypto/crypto.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:encrypt/encrypt.dart' as encrypt;


const String ds = "01234567890123456789012345678901 !\"#\$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

class LoginRequest with ChangeNotifier {
  String username = "";
  String password = "";
  String msgCode = "";

  String ms(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }


  String ai(String plainText) {
    // 密钥和 IV
    final key = encrypt.Key.fromUtf8("a86a86^oH\$04r6A1");
    final iv = encrypt.IV.fromUtf8("a86a86^oH\$04r6A1");

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
    );

    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // 标准 Base64 转 URL-safe
    String base64 = encrypted.base64;
    String urlSafe = base64
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll(RegExp(r'=+$'), '');

    return urlSafe;
  }




  Future<bool> passWordLogin() async {
    var reg =
        "^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}\$";

    String encryptedAccount = ai(username);
    String msPassword = ms(password);
    String encryptedPassword = ai(msPassword);
    // Response response = await DioInstance.instance().post(
    //   path: "/login/account",
    //   data: {
    //     "account_name": username,
    //     "passwd": md5.convert(utf8.encode(password)).toString(),
    //     "source": RegExp(reg).hasMatch(username) ? "mail" : "phone",
    //   },
    // );

    Response response = await DioInstance.instance().post(
      path: "/login/account",
      data: {
        "account_name": encryptedAccount,
        "passwd": encryptedPassword,
        "source": RegExp(reg).hasMatch(username) ? "mail" : "phone",
      },
    );

    var code = response.data['Code'];
    if (code == 0) {
      await AuthSession.instance.saveToken(response.data['data']['account']['token'] as String);
      return true;
    } else {
      showToast(response.data['Message'].toString());
      return false;
    }
  }

  Future<bool> msgCodeLogin() async {
    Response response = await DioInstance.instance().post(
      path: "/login/sms",
      data: {
        "account_name": username,
        "code": msgCode,
      },
    );
    var code = response.data['Code'];
    if (code == 0) {
      await AuthSession.instance.saveToken(response.data['data']['account']['token'] as String);
      return true;
    } else {
      showToast(response.data['Message'].toString());
      return false;
    }
  }

  Future<bool> getMsg() async {
    Response response = await DioInstance.instance().post(
      path: "/login/send_msg",
      data: {
        "account_name": username,
        "graph_code": "",
      },
    );
    var code = response.data['Code'];
    if (code == 0) {
      showToast(response.data['Message'].toString());
      return true;
    } else {
      showToast(response.data['Message'].toString());
      return false;
    }
  }

  // 网络失败向上传递，不能把无法验证当成未登录。
  static Future<bool> isLogin() async {
    if (AuthSession.instance.token.isEmpty) return false;
    await DioInstance.instance().post(path: '/community/member/info', data: {});
    return true;
  }

  static Future<void> exit() => AuthSession.instance.logout();
}
