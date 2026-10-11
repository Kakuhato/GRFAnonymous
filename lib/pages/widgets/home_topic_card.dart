import 'package:flutter/material.dart';
import 'package:grfanonymous/models/topicList.dart';
import 'package:grfanonymous/ui/uiSizeUtil.dart';
import 'home_topic_author.dart';
import 'home_topic_images.dart';

class HomeTopicCard extends StatelessWidget {
  const HomeTopicCard({
    super.key,
    required this.topic,
    required this.onOpen,
    this.onFollow,
    this.showFollowButton = true,
    required this.onLike,
  });

  final Topic topic;
  final VoidCallback onOpen;
  final VoidCallback? onFollow;
  final bool showFollowButton;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        color: Colors.white,
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeTopicAuthor(
              topic: topic,
              onFollow: onFollow,
              showFollowButton: showFollowButton,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (topic.isAdmin)
                  Container(
                    margin: const EdgeInsets.only(right: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    color: const Color(0xFFFF941F),
                    child: const Text('官',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                Expanded(
                  child: Text(
                    topic.title,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: UiSizeUtil.homePageTitleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              topic.content,
              maxLines: 1,
              style: TextStyle(
                fontSize: UiSizeUtil.homePageContentFontSize,
                color: const Color.fromRGBO(153, 156, 159, 1),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            HomeTopicImages(images: topic.picList),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Wrap(
                    children: [
                      _tag(topic.categoryName),
                      for (final theme in topic.themeInfo)
                        _tag('#${theme.themeName}#', isTheme: true),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Image.asset(
                  'assets/comments.png',
                  width: UiSizeUtil.likeIconSize,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    topic.commentNum.toString(),
                    style: TextStyle(
                      fontSize: UiSizeUtil.likeFontSize,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onLike,
                  child: Row(
                    children: [
                      Image.asset(
                        topic.isLike ? 'assets/liked.png' : 'assets/likes.png',
                        width: UiSizeUtil.likeIconSize,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          topic.likeNum.toString(),
                          style: TextStyle(
                            fontSize: UiSizeUtil.likeFontSize,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label, {bool isTheme = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 6, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromRGBO(234, 234, 234, 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: UiSizeUtil.tagFontSize,
          color: isTheme
              ? const Color(0xFFFF701F)
              : const Color.fromRGBO(153, 156, 159, 1),
        ),
      ),
    );
  }
}

