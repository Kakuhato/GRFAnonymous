import 'package:flutter/material.dart';
import 'package:grfanonymous/models/webViewContent.dart';
import 'package:grfanonymous/ui/uiSizeUtil.dart';

/// 正文后的创作声明、所属分类、话题和时间信息。
class TopicDetailMetadata extends StatelessWidget {
  const TopicDetailMetadata({super.key, required this.topic});

  final WebViewContent topic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          '${topic.declare == 1 ? '允许规范转载' : '未经授权禁止转载'}'
          '${topic.hasAi ? ' · 包含AI生成内容' : ''}',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (topic.categoryName.isNotEmpty) _tag(topic.categoryName),
            for (final theme in topic.themeInfo)
              if (theme.name?.isNotEmpty == true)
                _tag('#${theme.name}', highlighted: theme.type != 0 && theme.active),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.end,
            children: [
              if (topic.createTime.isNotEmpty) _time('发布于 ${topic.createTime}'),
              if (topic.updateTime.isNotEmpty && topic.updateTime != topic.createTime)
                _time('编辑于 ${topic.updateTime}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _time(String text) => Text(text, style: TextStyle(
    fontSize: UiSizeUtil.postTimeFontSize,
    color: Colors.grey,
  ));

  Widget _tag(String text, {bool highlighted = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    decoration: BoxDecoration(
      color: highlighted ? const Color(0xFFFFEFE0) : const Color(0xFFEAEAEA),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(text, style: TextStyle(
      color: highlighted ? const Color(0xFFFF701F) : Colors.grey,
      fontSize: UiSizeUtil.tagFontSize,
    )),
  );
}
