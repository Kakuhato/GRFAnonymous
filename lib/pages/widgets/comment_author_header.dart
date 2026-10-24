import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:grfanonymous/models/replyList.dart';
import 'package:grfanonymous/ui/uiSizeUtil.dart';
import 'topic_author_badge.dart';
import 'topic_identity_badge.dart';

const _orange = Color(0xFFFF701F);

class CommentAuthorHeader extends StatelessWidget {
  const CommentAuthorHeader({
    super.key,
    required this.comment,
    required this.onOpenAuthor,
  });

  final SingleComment comment;
  final VoidCallback onOpenAuthor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenAuthor,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: UiSizeUtil.postAvatarSize,
            height: UiSizeUtil.postAvatarSize,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(comment.avatarFrame.isEmpty ? 0 : 3),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: comment.userAvatar,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Icon(Icons.account_circle),
                      ),
                    ),
                  ),
                ),
                if (comment.avatarFrame.isNotEmpty)
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: comment.avatarFrame,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                if (comment.isAdmin || comment.vip)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/certificateBadge.png',
                      width: 14,
                      height: 14,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 4,
                  runSpacing: 3,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(comment.userNickName,
                        style: TextStyle(fontSize: UiSizeUtil.postUserNameFontSize)),
                    CommentAuthorBadges(
                      author: comment,
                      level: comment.userLevel,
                      isAdmin: comment.isAdmin,
                    ),
                    if (comment.isAuthor)
                      const TopicAuthorBadge(),
                  ],
                ),
                Text(
                  '${comment.floorNum}L  ${comment.createTime}  ${comment.ipLocation.trim()}',
                  style: TextStyle(color: Colors.grey, fontSize: UiSizeUtil.postTimeFontSize),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 一级评论的用户徽标，容许窄屏和较大的系统字体自动换行。
class CommentAuthorBadges extends StatelessWidget {
  const CommentAuthorBadges({
    super.key,
    required this.author,
    required this.level,
    required this.isAdmin,
  });

  final CommentAuthorInfo author;
  final int level;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TopicLevelBadge(level: level),
        if (author.endlessRank > 0)
          Tooltip(
            message: '无尽模式排名：${author.endlessRank}',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              color: const Color(0xFFE9EBED),
              child: Text.rich(
                TextSpan(children: [
                  const WidgetSpan(child: Icon(Icons.military_tech, size: 14, color: Color(0xFF8B8070))),
                  TextSpan(text: '${author.endlessFloor < 0 ? 0 : author.endlessFloor}层'),
                ]),
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ),
        if (isAdmin)
          const Text('官方', style: TextStyle(color: Colors.lightBlue, fontSize: 12)),
        if (author.userTitle.isNotEmpty)
          Text(author.userTitle, style: const TextStyle(color: _orange, fontSize: 12)),
      ],
    );
  }
}
