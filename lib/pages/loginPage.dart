import 'package:demo/pages/tabPage.dart';
import 'package:demo/utils/routeUtil.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordLogin = true;
  String input = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 244, 244, 1),
      body: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isPasswordLogin
                  ? _buildPasswordLoginForm()
                  : _buildVerificationCodeLoginForm(),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isPasswordLogin = !_isPasswordLogin;
                  });
                },
                child: Text(_isPasswordLogin ? '验证码登录' : '账号密码登录',
                    style: TextStyle(color: Colors.black)),
              )
            ],
          )),
    );
  }

  Widget _buildPasswordLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InputField("请输入散爆账号"),
        const SizedBox(height: 20),
        _InputField("请输入密码"),
        SizedBox(height: 10),
        ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.lightBlueAccent),
            ),
            onPressed: () {},
            child: Center(
              child: Text(
                '登录',
                style: TextStyle(color: Colors.black),
              ),
            )),
      ],
    );
  }

  Widget _buildVerificationCodeLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InputField("请输入手机号"),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _InputField("请输入短信验证码"),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5))),
                backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
              ),
              onPressed: () {},
              child: Center(
                child: Text(
                  '获取验证码',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.lightBlueAccent),
            ),
            onPressed: () {},
            child: Center(
              child: Text(
                '登录',
                style: TextStyle(color: Colors.black),
              ),
            )),
      ],
    );
  }

  Widget _InputField(String labelText) {
    return TextField(
      onChanged: (value) {
        input = value;
      },
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        focusColor: Colors.red,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent),
        ),
      ),
    );
  }
}
