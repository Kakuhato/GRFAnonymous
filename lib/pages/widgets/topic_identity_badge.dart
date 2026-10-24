import 'package:flutter/material.dart';

/// 作者和社区等级徽标共用样式，保持高度及内边距一致。
class TopicIdentityBadge extends StatelessWidget {
  const TopicIdentityBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFF701F),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
      ),
    );
  }
}

class TopicLevelBadge extends StatelessWidget {
  const TopicLevelBadge({super.key, required this.level});

  final int level;

  @override
  Widget build(BuildContext context) => TopicIdentityBadge(label: 'lv.$level');
}
