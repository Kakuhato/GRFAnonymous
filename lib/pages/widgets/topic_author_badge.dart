import 'package:flutter/material.dart';

/// 一级评论、楼中楼及被回复用户共用的帖子作者标识。
class TopicAuthorBadge extends StatelessWidget {
  const TopicAuthorBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFF701F),
        borderRadius: BorderRadius.circular(2),
      ),
      child: const Text(
        '作者',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
      ),
    );
  }
}
