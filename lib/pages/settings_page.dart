import 'package:flutter/material.dart';

import '../pageRequest/emoji_request.dart';
import '../pageRequest/loginRequest.dart';
import '../ui/uiSizeUtil.dart';
import '../utils/app_image_cache.dart';
import '../utils/routeUtil.dart';
import 'loginPage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int? _bytes;
  bool _calculating = true;
  bool _clearing = false;
  bool _loggingOut = false;
  bool _sizeFailed = false;

  @override
  void initState() {
    super.initState();
    _readSize();
  }

  Future<void> _readSize() async {
    if (mounted) setState(() { _calculating = true; _sizeFailed = false; });
    try {
      final bytes = await AppImageCache.instance.usedBytes();
      if (mounted) setState(() => _bytes = bytes);
    } catch (_) {
      if (mounted) setState(() => _sizeFailed = true);
    } finally {
      if (mounted) setState(() => _calculating = false);
    }
  }

  String get _sizeLabel {
    if (_clearing) return '清理中…';
    if (_calculating) return '计算中…';
    if (_sizeFailed) return '计算失败，点击重试';
    final bytes = _bytes ?? 0;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _clearCache() async {
    if (_clearing || _calculating || _loggingOut) return;
    setState(() => _clearing = true);
    try {
      await EmojiRequest.clearCache();
      _message('缓存已清理');
    } catch (_) {
      _message('部分缓存清理失败，请重试');
    } finally {
      if (mounted) {
        setState(() => _clearing = false);
        await _readSize();
      }
    }
  }

  Future<void> _logout() async {
    if (_loggingOut || _clearing) return;
    setState(() => _loggingOut = true);
    try {
      await LoginRequest.exit();
      if (!mounted) return;
      RouteUtils.pushAndRemove(context, const LoginPage());
    } catch (_) {
      _message('退出登录失败，请重试');
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: UiSizeUtil.headerHeight,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: Colors.white, size: UiSizeUtil.topIconSize),
        ),
        title: Text('设置', style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: UiSizeUtil.headerFontSize,
        )),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            ColoredBox(
              color: Colors.white,
              child: Column(children: [
                ListTile(
                  title: const Text('已用缓存'),
                  trailing: Text(_sizeLabel, style: const TextStyle(color: Colors.grey)),
                  onTap: !_clearing && !_calculating ? _readSize : null,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  title: const Text('清理缓存'),
                  enabled: !_clearing && !_calculating && !_loggingOut,
                  trailing: _clearing
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.chevron_right),
                  onTap: _clearCache,
                ),
              ]),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Text('清理后图片会在浏览时重新加载，不影响已保存到相册的图片。',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            ColoredBox(
              color: Colors.white,
              child: ListTile(
                enabled: !_clearing && !_loggingOut,
                title: Text(_loggingOut ? '正在退出…' : '退出登录',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red)),
                onTap: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
