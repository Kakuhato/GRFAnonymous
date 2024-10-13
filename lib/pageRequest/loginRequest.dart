import 'dart:convert';
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
      return true;
    } else {
      showToast(response.data['Message'].toString());
      return false;
    }
  }
}
