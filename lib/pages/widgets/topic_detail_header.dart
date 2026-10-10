import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:grfanonymous/models/webViewContent.dart';
import 'package:grfanonymous/ui/uiSizeUtil.dart';

class TopicDetailHeader extends StatelessWidget {
  const TopicDetailHeader({
    super.key,
    required this.topic,
    required this.onOpenAuthor,
    required this.onFollow,
  });

  final WebViewContent topic;
  final VoidCallback onOpenAuthor;
  final VoidCallback? onFollow;
  static const _orange = Color(0xFFFF701F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onOpenAuthor,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
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
                                        const Icon(Icons.account_circle),
                                  ),
                                ),
                              ),
                            ),
                            if (topic.avatarFrame.isNotEmpty)
                              Positioned.fill(
                                child: CachedNetworkImage(
                                  imageUrl: topic.avatarFrame,
                                  fit: BoxFit.contain,
                                  errorWidget: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                ),
                              ),
                            if (topic.isAdmin || topic.vip)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Icon(Icons.verified, size: 16,
                                    color: topic.isAdmin
                                        ? const Color(0xFF46C5EF) : _orange),
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
                                Text(topic.userNickName,
                                    style: TextStyle(
                                      fontSize: UiSizeUtil.postUserNameFontSize,
                                      fontWeight: FontWeight.w600,
                                    )),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  color: _orange,
                                  child: Text('lv.${topic.userLevel}',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                ),
                                if (topic.endlessRank > 0)
                                  Tooltip(
                                    message: '无尽模式排名：${topic.endlessRank}',
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 3),
                                      color: const Color(0xFFE9EBED),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.military_tech, size: 14,
                                              color: Color(0xFF8B8070)),
                                          Text('${topic.endlessFloor < 0 ? 0 : topic.endlessFloor}层',
                                              style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (topic.isAdmin || topic.userTitle.isNotEmpty)
                              Wrap(
                                spacing: 4,
                                children: [
                                  if (topic.isAdmin)
                                    const Text('官方', style: TextStyle(
                                        color: Color(0xFF46C5EF), fontSize: 12)),
                                  if (topic.userTitle.isNotEmpty)
                                    Text(topic.userTitle, style: const TextStyle(
                                        color: _orange, fontSize: 12)),
                                ],
                              ),
                            Text('${topic.viewNum}阅读  ${topic.ipLocation.trim()}',
                                style: TextStyle(
                                  fontSize: UiSizeUtil.postTimeFontSize,
                                  color: Colors.grey,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!topic.isAuthor) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onFollow,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: topic.isFollow ? Colors.grey : _orange,
                    side: BorderSide(color: topic.isFollow ? Colors.grey : _orange),
                    minimumSize: const Size(0, 30),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                  ),
                  child: Text(topic.isFollow ? '已关注' : '+ 关注'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(topic.title, style: TextStyle(
            fontSize: UiSizeUtil.postTitleFontSize,
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }
}
