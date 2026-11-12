import 'package:flutter/material.dart';

import '../../ui/uiSizeUtil.dart';

/// 帖子内的回复面板，由父页面提供数据和评论交互。
class CommentRepliesSheet extends StatefulWidget {
  const CommentRepliesSheet({
    super.key,
    required this.changes,
    required this.loadReplies,
    required this.parentBuilder,
    required this.replyCount,
    required this.replyBuilder,
  });

  final ValueNotifier<int> changes;
  final Future<void> Function() loadReplies;
  final WidgetBuilder parentBuilder;
  final int Function() replyCount;
  final IndexedWidgetBuilder replyBuilder;

  @override
  State<CommentRepliesSheet> createState() => _CommentRepliesSheetState();
}

class _CommentRepliesSheetState extends State<CommentRepliesSheet> {
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _failed = false; });
    try {
      await widget.loadReplies();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
            child: Row(children: [
              Expanded(child: Text('全部回复', style: TextStyle(
                fontSize: UiSizeUtil.headerFontSize, fontWeight: FontWeight.bold,
              ))),
              IconButton(
                tooltip: '关闭',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: widget.changes,
              builder: (context, _, __) => ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: widget.replyCount() + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(children: [
                      widget.parentBuilder(context),
                      const Divider(height: 24),
                    ]);
                  }
                  if (index <= widget.replyCount()) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(children: [
                        widget.replyBuilder(context, index - 1),
                        const Divider(height: 16),
                      ]),
                    );
                  }
                  if (_loading) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(16), child: CircularProgressIndicator(),
                    ));
                  }
                  if (_failed) {
                    return Center(child: TextButton(
                      onPressed: _load, child: const Text('回复加载失败，点击重试'),
                    ));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
