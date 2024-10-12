
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 控制是否显示密码登录页面
  bool isPasswordLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登录'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 根据状态显示不同的登录表单
            isPasswordLogin ? buildPasswordLoginForm() : buildVerificationCodeLoginForm(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 切换到验证码登录
                TextButton(
                  onPressed: () {
                    setState(() {
                      isPasswordLogin = !isPasswordLogin;
                    });
                  },
                  child: Text(
                    isPasswordLogin ? '验证码登录' : '账号密码登录',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
                // 忘记密码与注册链接
                TextButton(
                  onPressed: () {
                    // 忘记密码的逻辑
                  },
                  child: Text('忘记密码'),
                ),
                TextButton(
                  onPressed: () {
                    // 注册逻辑
                  },
                  child: Text('立即注册'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 账号密码登录表单
  Widget buildPasswordLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: '请输入散爆账号',
          ),
        ),
        TextField(
          decoration: InputDecoration(
            labelText: '请输入密码',
          ),
          obscureText: true,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Checkbox(value: false, onChanged: (value) {}),
            Text('阅读并同意'),
            TextButton(
              onPressed: () {},
              child: Text('《用户协议》'),
            ),
            TextButton(
              onPressed: () {},
              child: Text('《隐私政策》'),
            ),
          ],
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // 登录逻辑
          },
          child: Center(child: Text('登录')),
        ),
      ],
    );
  }

  // 验证码登录表单
  Widget buildVerificationCodeLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: '请输入手机号',
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: '请输入短信验证码',
                ),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                // 发送验证码的逻辑
              },
              child: Text('发送验证码'),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Checkbox(value: false, onChanged: (value) {}),
            Text('阅读并同意'),
            TextButton(
              onPressed: () {},
              child: Text('《用户协议》'),
            ),
            TextButton(
              onPressed: () {},
              child: Text('《隐私政策》'),
            ),
          ],
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // 登录逻辑
          },
          child: Center(child: Text('登录')),
        ),
      ],
    );
  }
}