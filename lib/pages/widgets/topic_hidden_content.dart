import 'package:flutter/material.dart';

import '../../models/webViewContent.dart';
import '../../ui/uiSizeUtil.dart';

/// 在正文的 showFold 占位处展开；折叠时不布局隐藏正文。
class TopicHiddenContentView extends StatefulWidget {
  const TopicHiddenContentView({super.key, required this.content});
  final TopicHiddenContent content;

  @override
  State<TopicHiddenContentView> createState() => _TopicHiddenContentViewState();
}

class _TopicHiddenContentViewState extends State<TopicHiddenContentView> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFF26C1C);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          value: _expanded ? '已展开' : '已收起',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Icon(_expanded ? Icons.arrow_drop_down : Icons.arrow_right,
                  color: orange, size: 22),
                Expanded(child: Text(
                  widget.content.title.isEmpty ? '折叠内容' : widget.content.title,
                  style: TextStyle(color: orange, fontSize: UiSizeUtil.postContentFontSize),
                )),
              ]),
            ),
          ),
        ),
        if (_expanded)
          Text(widget.content.description,
            style: TextStyle(color: Colors.black, fontSize: UiSizeUtil.postContentFontSize)),
      ],
    );
  }
}
