import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../models/replyList.dart';
import '../../ui/uiSizeUtil.dart';
import '../../utils/htmlUtil.dart';
import '../../utils/routeUtil.dart';
import '../otherUserPage.dart';
import 'comment_author_header.dart';
import 'topic_author_badge.dart';

/// 评论展示与请求解耦，供帖子列表和独立回复面板复用。
class CommentCard extends StatelessWidget {
  const CommentCard({super.key, required this.reply, required this.onReply,
    required this.onLike, required this.onTapUrl, this.replies});
  final SingleComment reply;
  final VoidCallback onReply;
  final VoidCallback? onLike;
  final Future<bool> Function(String) onTapUrl;
  final Widget? replies;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(horizontal: 10)
          .add(const EdgeInsets.only(top: 10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommentAuthorHeader(
            comment: reply,
            onOpenAuthor: () => RouteUtils.push(
              context,
              OtherUserPage(uid: reply.userId.toString()),
            ),
          ),
          const SizedBox(height: 8),
          // 正文内容
          Container(
            padding: const EdgeInsets.only(
              left: 45,
              bottom: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectionArea(
              child: HtmlWidget(
                reply.content,
                factoryBuilder: () => MyWidgetFactory(context),
                onTapUrl: onTapUrl,
                customStylesBuilder: (element) {
                  return HtmlProcess.buildCustomStyles(element);
                },
                textStyle: TextStyle(
                  fontSize: UiSizeUtil.postContentFontSize,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // 次级回复区域
          if (replies != null) replies!,

          const SizedBox(height: 8),
          // 点赞、评论按钮区域
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    Image.asset(
                      reply.isLike ? "assets/liked.png" : "assets/likes.png",
                      width: UiSizeUtil.postCommentLikeIconSize,
                      height: UiSizeUtil.postCommentLikeIconSize,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        reply.likeNum.toString(),
                        style: TextStyle(
                          fontSize: UiSizeUtil.postCommentLikeFontSize,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onReply,
                child: Row(
                  children: [
                    Image.asset(
                      "assets/comments.png",
                      width: UiSizeUtil.postCommentLikeIconSize,
                      height: UiSizeUtil.postCommentLikeIconSize,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        reply.replyNum.toString(),
                        style: TextStyle(
                          fontSize: UiSizeUtil.postCommentLikeFontSize,
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
    );
  }
}

class CommentReplyCard extends StatelessWidget {
  const CommentReplyCard({super.key, required this.reply, required this.onReply,
    required this.onLike, required this.onTapUrl, this.inSheet = false,
    this.topicAuthorId});
  final CommentReply reply;
  final VoidCallback onReply;
  final VoidCallback? onLike;
  final Future<bool> Function(String) onTapUrl;
  final bool inSheet;
  final int? topicAuthorId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: inSheet ? 0 : 45),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: inSheet ? Colors.white : Colors.grey[200],
        // borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 3,
            children: [
              GestureDetector(
                onTap: () {
                  RouteUtils.push(
                    context,
                    OtherUserPage(uid: reply.userId.toString()),
                  );
                },
                child: Text(
                  reply.userNickName,
                  style: TextStyle(
                    fontSize: UiSizeUtil.secondCommentUserNameFontSize,
                    color: Color.fromRGBO(242, 108, 28, 1),
                  ),
                ),
              ),
              if (reply.isAuthor)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: TopicAuthorBadge(),
                ),
              if (reply.replyTo != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text("回复",
                      style: TextStyle(
                        fontSize: UiSizeUtil.secondCommentUserNameFontSize,
                      )),
                ),
              if (reply.replyTo != null)
                GestureDetector(
                  onTap: () {
                    RouteUtils.push(
                      context,
                      OtherUserPage(uid: reply.replyToUid.toString()),
                    );
                  },
                  child: Text(
                    reply.replyTo!,
                    style: TextStyle(
                      fontSize: UiSizeUtil.secondCommentUserNameFontSize,
                      color: Color.fromRGBO(242, 108, 28, 1),
                    ),
                  ),
                ),
              if (topicAuthorId != null && reply.replyToUid == topicAuthorId)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: TopicAuthorBadge(),
                ),
              const Text(" ："),
            ],
          ),
          SelectionArea(
            child: HtmlWidget(
              reply.content,
              factoryBuilder: () => MyWidgetFactory(context),
              onTapUrl: onTapUrl,
              customStylesBuilder: (element) {
                return HtmlProcess.buildCustomStyles(element);
              },
              textStyle: TextStyle(
                fontSize: UiSizeUtil.secondCommentFontSize,
                color: Colors.black,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '${reply.createTime}  ${reply.ipLocation.trim()}',
                  style: TextStyle(
                    fontSize: UiSizeUtil.secondCommentTimeFontSize,
                    color: Colors.grey,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onLike,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        reply.isLike ? 'assets/liked.png' : 'assets/likes.png',
                        width: UiSizeUtil.postCommentLikeIconSize,
                        height: UiSizeUtil.postCommentLikeIconSize,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          reply.likeNum.toString(),
                          style: TextStyle(
                            fontSize: UiSizeUtil.postCommentLikeFontSize,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onReply,
                child: Image.asset(
                  "assets/comments.png",
                  width: UiSizeUtil.postCommentLikeIconSize,
                  height: UiSizeUtil.postCommentLikeIconSize,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
