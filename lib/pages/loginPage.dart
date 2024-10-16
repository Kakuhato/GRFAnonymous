import 'package:cached_network_image/cached_network_image.dart';
import 'package:grfanonymous/pageRequest/loginRequest.dart';
import 'package:grfanonymous/pages/tabPage.dart';
import 'package:grfanonymous/utils/routeUtil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginRequest loginRequest = LoginRequest();

  bool _isPasswordLogin = true;
  String input = '';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => loginRequest,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(244, 244, 244, 1),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                  "https://gf2-cn.cdn.sunborngame.com/website/official/source/bbspc1727171270263/img/all-bg.ce70261e.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20)
                  .add(const EdgeInsets.only(top: 100)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                      imageUrl:
                          "https://i0.hdslb.com/bfs/new_dyn/bc18c57775319c311d7059213c137393697654195.jpg"),
                  SizedBox(height: 50),
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
                        style: const TextStyle(color: Colors.grey)),
                  ),
                  const Spacer(),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildPasswordLoginForm() {
    return Consumer<LoginRequest>(builder: (context, loginRequest, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField("请输入散爆账号", (value) {
            loginRequest.username = value;
          }),
          const SizedBox(height: 20),
          _inputField("请输入密码", obscure: true, (value) {
            loginRequest.password = value;
          }),
          SizedBox(height: 10),
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    const Color.fromRGBO(241, 108, 28, 1)),
              ),
              onPressed: () {
                loginRequest.passWordLogin().then((value) {
                  if (value) {
                    RouteUtils.pushAndRemove(context, TabPage());
                  }
                });
              },
              child: const Center(
                child: Text(
                  '登录',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
        ],
      );
    });
  }

  Widget _buildVerificationCodeLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inputField("请输入手机号", (value) {
          loginRequest.username = value;
        }),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _inputField("请输入短信验证码", (value) {
                loginRequest.msgCode = value;
              }),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5))),
                backgroundColor: WidgetStateProperty.all(
                    const Color.fromRGBO(48, 122, 152, 1)),
              ),
              onPressed: () {
                loginRequest.getMsg();
              },
              child: const Center(
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
              backgroundColor: WidgetStateProperty.all(
                  const Color.fromRGBO(241, 108, 28, 1)),
            ),
            onPressed: () {
              loginRequest.msgCodeLogin().then((value) {
                if (value) {
                  RouteUtils.pushAndRemove(context, TabPage());
                }
              });
            },
            child: const Center(
              child: Text(
                '登录',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
      ],
    );
  }

  Widget _inputField(
    String labelText,
    ValueChanged<String> onChanged, {
    bool obscure = false,
  }) {
    return TextField(
      obscureText: obscure,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        focusColor: Colors.red,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent),
        ),
      ),
    );
  }
}
