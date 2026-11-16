import 'package:flutter/material.dart';

import '../../pageRequest/request_failure.dart';

/// 嵌入现有 Scaffold 的内容区域，页眉与导航保持不变。
class RequestErrorView extends StatelessWidget {
  const RequestErrorView({super.key, required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = RequestFailure.from(error);
    return Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(failure.isNetwork ? Icons.wifi_off : Icons.error_outline,
          size: 56, color: Colors.grey),
        const SizedBox(height: 16),
        Text(failure.isNetwork ? '网络连接失败' : '加载失败',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(failure.message, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton(onPressed: onRetry, child: const Text('重新加载')),
        if (Navigator.canPop(context))
          TextButton(onPressed: () => Navigator.maybePop(context), child: const Text('返回')),
      ]),
    ));
  }
}
