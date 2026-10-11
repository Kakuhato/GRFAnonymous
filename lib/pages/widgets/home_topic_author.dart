import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:grfanonymous/models/topicList.dart';
import 'package:grfanonymous/ui/uiSizeUtil.dart';

/// 帖子作者资料，仅展示接口返回的信息，不依赖页面或请求对象。
class HomeTopicAuthor extends StatelessWidget {
  const HomeTopicAuthor({
    super.key,
    required this.topic,
    this.onFollow,
    this.showFollowButton = true,
  });

  final Topic topic;
  final VoidCallback? onFollow;
  final bool showFollowButton;
  static const _orange = Color(0xFFFF701F);
  static const _officialBlue = Color(0xFF46C5EF);

  @override
  Widget build(BuildContext context) {
    final avatarSize = UiSizeUtil.homePageAvatarSize;
    final time = topic.createTime.length >= 16
        ? topic.createTime.substring(0, 16)
        : topic.createTime;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: avatarSize + 8,
          height: avatarSize + 8,
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: topic.userAvatar,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.account_circle, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              if (topic.avatarFrame.isNotEmpty)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: topic.avatarFrame,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              if (topic.isAdmin || topic.vip)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Tooltip(
                    message: topic.isAdmin ? '官方认证' : '认证用户',
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified,
                        size: 16,
                        color: topic.isAdmin ? _officialBlue : _orange,
                      ),
                    ),
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
                runSpacing: 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 110),
                    child: Text(
                      topic.userNickName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: UiSizeUtil.homePageUserNameFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _orange,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'lv.${topic.userLevel}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              // 排名字段可能缺失；与官网一致，仅有有效排名时展示层数。
              if (topic.endlessRank > 0)
                Tooltip(
                  message: '无尽模式排名：${topic.endlessRank}',
                  child: Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EBED),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.military_tech,
                            size: 14, color: Color(0xFF8B8070)),
                        Text(
                          '${topic.endlessFloor < 0 ? 0 : topic.endlessFloor}层',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                ],
              ),
              Wrap(
                spacing: 4,
                children: [
                  if (topic.isAdmin)
                    const Text('官方',
                        style: TextStyle(color: _officialBlue, fontSize: 12)),
                  if (topic.userTitle.isNotEmpty)
                    Text(topic.userTitle,
                        style: const TextStyle(color: _orange, fontSize: 12)),
                  Text(time,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: UiSizeUtil.homePageTimeFontSize,
                      )),
                ],
              ),
            ],
          ),
        ),
        if (showFollowButton && !topic.isAuthor && onFollow != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onFollow,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: topic.isFollow ? Colors.grey : _orange),
              ),
              child: Text(
                topic.isFollow ? '已关注' : '+ 关注',
                style: TextStyle(
                  color: topic.isFollow ? Colors.grey : _orange,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
