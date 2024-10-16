import 'package:cached_network_image/cached_network_image.dart';
import 'package:grfanonymous/models/replyList.dart';
import 'package:grfanonymous/pageRequest/webViewRequest.dart';
import 'package:grfanonymous/utils/htmlUtil.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:oktoast/oktoast.dart';

class WebViewPage extends StatefulWidget {
  final String topicId;
  const WebViewPage({super.key, required this.topicId});

  @override
  State<StatefulWidget> createState() {
    return _WebViewPageState();
  }
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewRequest webViewRequest = WebViewRequest();
  bool isLoading = true;

  @override
  void initState() {
    initTopic();
    super.initState();
  }

  Future initTopic() async {
    await webViewRequest.getWebViewContent(widget.topicId);
    await webViewRequest.getReplyList(widget.topicId);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.star,
                    size: 35,
                    color: webViewRequest.webViewContent.isFavor
                        ? const Color.fromRGBO(242, 108, 28, 1)
                        : Colors.white,
                  ),
                  onPressed: () async {
                    bool result =
                        await webViewRequest.favorTopic(widget.topicId);
                    if (result) {
                      setState(() {
                        webViewRequest.webViewContent.isFavor =
                            !webViewRequest.webViewContent.isFavor;
                        if (webViewRequest.webViewContent.isFavor) {
                          webViewRequest.webViewContent.favorNum++;
                        } else {
                          webViewRequest.webViewContent.favorNum--;
                        }
                      });
                      showToast(webViewRequest.webViewContent.isFavor
                          ? "收藏成功"
                          : "取消收藏");
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.segment,
                    size: 35,
                  ),
                  onPressed: () {},
                )
              ],
              backgroundColor: Colors.black,
              automaticallyImplyLeading: true,
              iconTheme: const IconThemeData(color: Colors.white, size: 35),
            ),
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: _titleBuilder(),
                ),
                SliverToBoxAdapter(
                  child: _contentBuilder(),
                ),
              ],
              body: _replyListBuilder(),
              // EasyRefresh(
              //   triggerAxis: Axis.vertical,
              //   header: const MaterialHeader(),
              //   refreshOnStart: true,
              //   onLoad: () async {},
              //   child: Container(
              //     child: Text("data"),
              //   ),
              // ),
            ),
          );
  }

  Widget _titleBuilder() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                  child: CachedNetworkImage(
                imageUrl: webViewRequest.webViewContent.userAvatar,
                width: 60,
                height: 60,
              )),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          webViewRequest.webViewContent.userNickName,
                          style: const TextStyle(
                            fontSize: 30,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: const Color.fromRGBO(248, 181, 141, 1),
                          ),
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.only(left: 10),
                          child: Text(
                            "lv.${webViewRequest.webViewContent.userLevel}",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color.fromRGBO(242, 108, 86, 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "${webViewRequest.webViewContent.viewNum}阅读  ${webViewRequest.webViewContent.ipLocation}",
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Text(
              webViewRequest.webViewContent.title,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Text(
              "发布于 ${webViewRequest.webViewContent.createTime}",
              style: const TextStyle(
                fontSize: 15,
                color: Color.fromRGBO(153, 153, 153, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentBuilder() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 10).add(
        const EdgeInsets.only(bottom: 10),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: HtmlWidget(
        webViewRequest.webViewContent.content,
        factoryBuilder: () => MyWidgetFactory(),
        customStylesBuilder: (element) {
          if (element.localName == 'p') {
            return {
              'margin': '5px 0',
            };
          }

          final style = element.attributes['style'];
          if (style != null) {
            final styles = style.split(';');
            Map<String, String> styleMap = {};
            for (var s in styles) {
              final keyValue = s.split(':');
              if (keyValue.length == 2) {
                styleMap[keyValue[0].trim()] = keyValue[1].trim();
              }
            }

            // 如果背景颜色是黑色，则将文字颜色设置为白色
            if (styleMap.containsKey('background-color')) {
              String backgroundColor = styleMap['background-color']!;
              if (backgroundColor.contains('rgb(0, 0, 0)') ||
                  backgroundColor == '#000000' ||
                  backgroundColor == 'black') {
                return {
                  'text-decoration': 'line-through',
                  'color': 'white', // 黑色背景时，文字颜色设置为白色
                };
              }
            }

            return {
              if (styleMap.containsKey('font-size'))
                'font-size': styleMap['font-size'] ?? '14px',
              if (styleMap.containsKey('color'))
                'color': styleMap['color'] ?? 'black',
            };
          }
          return null;
        },
        textStyle: const TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _replyListBuilder() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return _replyBuilder(
          webViewRequest.replyList[index],
        );
      },
      itemCount: webViewRequest.replyList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget _replyBuilder(ListElement reply) {
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
          // 第一行：头像 + 用户名 + 时间
          Row(
            children: [
              // 头像
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: reply.userAvatar, // 替换为实际头像URL
                  width: 40,
                  height: 40,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              SizedBox(width: 8),
              // 用户名 + 时间
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        reply.userNickName,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(248, 181, 141, 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          "lv.${reply.userLevel}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color.fromRGBO(242, 108, 28, 1),
                          ),
                        ),
                      ),
                      if (reply.isAuthor)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(248, 181, 141, 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            "作者",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color.fromRGBO(242, 108, 28, 1),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    '${reply.floorNum}L   ${reply.createTime} ${reply.ipLocation}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 正文内容
          Container(
            padding: const EdgeInsets.only(left: 45),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: HtmlWidget(
              reply.content,
              factoryBuilder: () => MyWidgetFactory(),
              customStylesBuilder: (element) {
                if (element.localName == 'p') {
                  return {
                    'margin': '5px 0',
                  };
                }

                final style = element.attributes['style'];
                if (style != null) {
                  final styles = style.split(';');
                  Map<String, String> styleMap = {};
                  for (var s in styles) {
                    final keyValue = s.split(':');
                    if (keyValue.length == 2) {
                      styleMap[keyValue[0].trim()] = keyValue[1].trim();
                    }
                  }

                  // 如果背景颜色是黑色，则将文字颜色设置为白色
                  if (styleMap.containsKey('background-color')) {
                    String backgroundColor = styleMap['background-color']!;
                    if (backgroundColor.contains('rgb(0, 0, 0)') ||
                        backgroundColor == '#000000' ||
                        backgroundColor == 'black') {
                      return {
                        'text-decoration': 'line-through',
                        'color': 'white', // 黑色背景时，文字颜色设置为白色
                      };
                    }
                  }

                  return {
                    if (styleMap.containsKey('font-size'))
                      'font-size': styleMap['font-size'] ?? '14px',
                    if (styleMap.containsKey('color'))
                      'color': styleMap['color'] ?? 'black',
                  };
                }
                return null;
              },
              textStyle: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),

          // 次级回复区域
          _secondaryReplyListBuilder(reply.commentReply),

          SizedBox(height: 8),
          // 点赞、评论按钮区域
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () async {
                  bool result = await webViewRequest.likeComment(
                      widget.topicId, reply.commentId);
                  if (result) {
                    setState(() {
                      reply.isLike = !reply.isLike;
                      if (reply.isLike) {
                        reply.likeNum++;
                      } else {
                        reply.likeNum--;
                      }
                    });
                    showToast(reply.isLike ? "点赞成功" : "取消点赞");
                  }
                },
                child: Image.asset(
                    reply.isLike ? "assets/liked.png" : "assets/likes.png",
                    width: 23,
                    height: 23),
              ),
              SizedBox(width: 4),
              Text(
                reply.likeNum.toString(),
                style: TextStyle(fontSize: 17, color: Colors.grey),
              ),
              SizedBox(width: 16),
              Image.asset("assets/comments.png", width: 23, height: 23),
              SizedBox(width: 4),
              Text(
                reply.replyNum.toString(),
                style: TextStyle(fontSize: 17, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _secondaryReplyListBuilder(List<CommentReply> commentReply) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return _secondaryReplyBuilder(
          commentReply[index],
        );
      },
      itemCount: commentReply.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget _secondaryReplyBuilder(CommentReply reply) {
    return Container(
      margin: const EdgeInsets.only(left: 45),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200], // 灰色背景
        // borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                reply.userNickName,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color.fromRGBO(242, 108, 28, 1),
                ),
              ),
              if (reply.isAuthor)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(242, 108, 28, 1),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    "作者",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color.fromRGBO(242, 108, 28, 1),
                    ),
                  ),
                ),
              if (reply.replyTo != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: const Text("回复",
                      style: TextStyle(
                        fontSize: 13,
                      )),
                ),
              if (reply.replyTo != null)
                Text(
                  reply.replyTo!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color.fromRGBO(242, 108, 28, 1),
                  ),
                ),
              if (reply.isTopicAuthor != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(242, 108, 28, 1),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    "楼主",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color.fromRGBO(242, 108, 28, 1),
                    ),
                  ),
                ),
              const Text(" ："),
            ],
          ),
          Container(
            child: HtmlWidget(
              reply.content,
              factoryBuilder: () => MyWidgetFactory(),
              customStylesBuilder: (element) {
                if (element.localName == 'p') {
                  return {
                    'margin': '5px 0',
                  };
                }

                final style = element.attributes['style'];
                if (style != null) {
                  final styles = style.split(';');
                  Map<String, String> styleMap = {};
                  for (var s in styles) {
                    final keyValue = s.split(':');
                    if (keyValue.length == 2) {
                      styleMap[keyValue[0].trim()] = keyValue[1].trim();
                    }
                  }

                  // 如果背景颜色是黑色，则将文字颜色设置为白色
                  if (styleMap.containsKey('background-color')) {
                    String backgroundColor = styleMap['background-color']!;
                    if (backgroundColor.contains('rgb(0, 0, 0)') ||
                        backgroundColor == '#000000' ||
                        backgroundColor == 'black') {
                      return {
                        'text-decoration': 'line-through',
                        'color': 'white', // 黑色背景时，文字颜色设置为白色
                      };
                    }
                  }

                  return {
                    if (styleMap.containsKey('font-size'))
                      'font-size': styleMap['font-size'] ?? '14px',
                    if (styleMap.containsKey('color'))
                      'color': styleMap['color'] ?? 'black',
                  };
                }
                return null;
              },
              textStyle: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
