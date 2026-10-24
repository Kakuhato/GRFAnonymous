import 'package:flutter/material.dart';
import 'topic_identity_badge.dart';

/// 一级评论、楼中楼及被回复用户共用的帖子作者标识。
class TopicAuthorBadge extends StatelessWidget {
  const TopicAuthorBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const TopicIdentityBadge(label: '作者');
  }
}
