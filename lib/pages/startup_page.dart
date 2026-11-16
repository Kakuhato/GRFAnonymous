import 'package:flutter/material.dart';

import '../pageRequest/loginRequest.dart';
import '../pageRequest/request_failure.dart';
import '../ui/uiSizeUtil.dart';
import '../utils/routeUtil.dart';
import 'loginPage.dart';
import 'tabPage.dart';
import 'widgets/request_error_view.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});
  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted || _loading) return;
    setState(() { _loading = true; _error = null; });
    try {
      final loggedIn = await LoginRequest.isLogin();
      if (!mounted) return;
      RouteUtils.pushAndRemove(context, loggedIn ? TabPage() : const LoginPage());
    } catch (error) {
      if (mounted && !RequestFailure.from(error).isSilent) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: Colors.black, centerTitle: true,
      toolbarHeight: UiSizeUtil.headerHeight,
      title: Text('主  页', style: TextStyle(color: Colors.white,
        fontSize: UiSizeUtil.headerFontSize, fontWeight: FontWeight.bold))),
    body: _error != null ? RequestErrorView(error: _error!, onRetry: _load)
        : const Center(child: CircularProgressIndicator()),
  );
}
