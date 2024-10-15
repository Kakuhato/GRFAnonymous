import 'dart:convert';
import 'package:demo/pageRequest/cookieInterceptor.dart';
import 'package:demo/utils/hivUtil.dart';
import 'package:demo/utils/routeUtil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:crypto/crypto.dart';
import 'package:demo/pageRequest/requestUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class LoginRequest with ChangeNotifier {
  String username = "";
  String password = "";
  String msgCode = "";

  Future<bool> passWordLogin() async {
    var reg =
        "^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}\$";

    Response response = await DioInstance.instance().post(
      path: "/login/account",
      data: {
        "account_name": username,
        "passwd": md5.convert(utf8.encode(password)).toString(),
        "source": RegExp(reg).hasMatch(username) ? "mail" : "phone",
      },
    );
    var code = response.data['Code'];
    if (code == 0) {
      HiveUtil.instance().setString(HiveUtil.tokenKey, response.data['data']['account']['token']);
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
      HiveUtil.instance().setString(HiveUtil.tokenKey, response.data['data']['account']['token']);
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

  static Future<bool> isLogin() async {
    if (HiveUtil.instance().getString(HiveUtil.tokenKey) == "") {
      return false;
    }
    else {
      return true;
    }
  }

   static exit(){
    HiveUtil.instance().setString(HiveUtil.tokenKey, "");
    CookieInterceptor.clear();
  }

}
