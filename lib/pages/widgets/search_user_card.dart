import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/search_user.dart';
import 'topic_identity_badge.dart';

class SearchUserCard extends StatelessWidget {
  const SearchUserCard({super.key, required this.user, required this.onOpen});

  final SearchUser user;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
      child: Material(
        color: Colors.white,
        child: ListTile(
          onTap: user.uid > 0 ? onOpen : null,
          leading: ClipOval(
            child: SizedBox(
              width: 44,
              height: 44,
              child: user.avatar.isEmpty
                  ? const Icon(Icons.account_circle, size: 44, color: Colors.grey)
                  : CachedNetworkImage(
                      imageUrl: user.avatar,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(Icons.account_circle, size: 44, color: Colors.grey),
                    ),
            ),
          ),
          title: Wrap(
            spacing: 4,
            runSpacing: 3,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(user.nickname.isEmpty ? '未命名用户' : user.nickname),
              TopicLevelBadge(level: user.level),
            ],
          ),
          subtitle: Text('社区 ID：${user.uid}${user.isFollow ? ' · 已关注' : ''}'),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
