import 'widgets/topic_author_badge.dart';
import 'widgets/topic_detail_header.dart';
import 'widgets/topic_detail_metadata.dart';
import 'widgets/comment_author_header.dart';
import 'package:flutter/services.dart';
import 'package:grfanonymous/models/replyList.dart';
import 'package:grfanonymous/pageRequest/webViewRequest.dart';
import 'package:grfanonymous/utils/htmlUtil.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:oktoast/oktoast.dart';

import '../pageRequest/likeAndFollow.dart';
import '../ui/uiSizeUtil.dart';
import '../utils/globalKey.dart';
import '../utils/routeUtil.dart';
import '../utils/topic_link.dart';
import '../models/webViewContent.dart';
import 'otherUserPage.dart';

class WebViewPage extends StatefulWidget {
  final String topicId;
  final WebViewContent? initialContent;
  const WebViewPage({super.key, required this.topicId, this.initialContent});

  @override
  State<StatefulWidget> createState() {
    return _WebViewPageState();
  }
}

class _WebViewPageState extends State<WebViewPage> {
  LikeAndFollow likeAndFollow = LikeAndFollow();
  WebViewRequest webViewRequest = WebViewRequest();
  final TextEditingController _commentController = TextEditingController();
  bool isLoading = true;
  String? _loadError;
  String? _commentError;
  bool _initializing = false;
  bool _commentsLoading = false;
  bool _retryCommentsFromStart = true;
  bool _isOpeningTopicLink = false;
  final Set<int> _pendingReplyLikes = {};
  bool _isFollowing = false;
  bool isInputActive = false;
  String replyto = "";
  int commentId = 0;
  int commentSubId = 0;
  String selectedOption1 = "所有评论";
  String selectedOption2 = "默认";
  bool isAuther = false;
  int sortType = 0;

  @override
  initState() {
    super.initState();
    initTopic();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> initTopic() async {
    if (_initializing) return;
    _initializing = true;
    setState(() {
      isLoading = true;
      _loadError = null;
    });
    try {
      final initial = widget.initialContent;
      if (initial != null && '${initial.topicId}' == widget.topicId) {
        webViewRequest.webViewContent = initial;
      } else {
        await webViewRequest.getWebViewContent(widget.topicId);
      }
      if (!mounted) return;
      setState(() => isLoading = false);
      await _loadComments();
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error is TopicRequestException
          ? error.message : '帖子加载失败，请重试');
    } finally {
      _initializing = false;
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<IndicatorResult> _loadComments({bool isInit = true}) async {
    if (!mounted || _commentsLoading) return IndicatorResult.fail;
    setState(() {
      _commentsLoading = true;
      _commentError = null;
      _retryCommentsFromStart = isInit;
      if (isInit) {
        webViewRequest.replyList = [];
        webViewRequest.hasNext = false;
      }
    });
    try {
      await webViewRequest.getReplyList(widget.topicId,
          isInit: isInit, isAuther: isAuther, sort: sortType);
      // 是否继续加载由 hasNext 控制，避免切换评论筛选后残留 noMore 状态。
      return IndicatorResult.success;
    } catch (error) {
      if (mounted) setState(() => _commentError = error is TopicRequestException
          ? error.message : '评论加载失败，请重试');
      return IndicatorResult.fail;
    } finally {
      if (mounted) setState(() => _commentsLoading = false);
    }
  }

  Future<bool> _openTopicLink(String url) async {
    final topicId = TopicLink.parseHref(url);
    if (topicId == null) return false;
    // 已识别的社区帖子链接始终由 App 接管，失败也不回退到浏览器。
    if (!mounted || _isOpeningTopicLink) return true;
    if (topicId == widget.topicId) {
      showToast('当前已是该帖子');
      return true;
    }
    _isOpeningTopicLink = true;
    try {
      final request = WebViewRequest();
      await request.getWebViewContent(topicId);
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return true;
      await RouteUtils.push(context, WebViewPage(
        topicId: topicId, initialContent: request.webViewContent,
      ));
    } catch (error) {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        showToast(error is TopicRequestException ? error.message : '帖子加载失败，请重试');
      }
    } finally {
      _isOpeningTopicLink = false;
    }
    return true;
  }

  void clearComment() {
    replyto = "";
    commentId = 0;
    commentSubId = 0;
    isInputActive = false; // 取消激活输入框
    _commentController.clear(); // 清空输入内容
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || _loadError != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Text('帖子详情', style: TextStyle(fontSize: UiSizeUtil.headerFontSize)),
        ),
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_loadError!, textAlign: TextAlign.center),
                    TextButton(onPressed: initTopic, child: const Text('重新加载')),
                    TextButton(onPressed: () => Navigator.maybePop(context), child: const Text('返回')),
                  ]),
                ),
        ),
      );
    }
    return Scaffold(
            backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(UiSizeUtil.headerHeight),
              child: AppBar(
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.star,
                      size: UiSizeUtil.topIconSize,
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
                    icon: Icon(
                      Icons.open_in_new,
                      size: UiSizeUtil.topIconSize,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      final topic = webViewRequest.webViewContent;
                      final textToCopy = TopicLink.shareText(
                        topicId: widget.topicId,
                        author: topic.userNickName,
                        title: topic.title,
                      );
                      bool result = await likeAndFollow.share(widget.topicId);
                      if (result) {
                        await Clipboard.setData(
                            ClipboardData(text: textToCopy));
                        showToast("已复制到剪贴板"); // 可以选择显示提示信息
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      color: webViewRequest.webViewContent.isLike
                          ? const Color.fromRGBO(242, 108, 28, 1)
                          : Colors.white,
                      Icons.thumb_up_off_alt,
                      size: UiSizeUtil.topIconSize,
                    ),
                    onPressed: () async {
                      bool result = await likeAndFollow.like(widget.topicId);
                      if (result) {
                        setState(() {
                          webViewRequest.webViewContent.isLike =
                              !webViewRequest.webViewContent.isLike;
                          homeScaffoldState?.updateLikeState(
                              int.parse(widget.topicId),
                              webViewRequest.webViewContent.isLike);
                        });
                        showToast(webViewRequest.webViewContent.isLike
                            ? "点赞成功"
                            : "取消点赞");
                      }
                    },
                  )
                ],
                backgroundColor: Colors.black,
                automaticallyImplyLeading: true,
                iconTheme: IconThemeData(
                  color: Colors.white,
                  size: UiSizeUtil.topIconSize,
                ),
              ),
            ),
            body: EasyRefresh(
              triggerAxis: Axis.vertical,
              header: const MaterialHeader(),
              refreshOnStart: true,
              onLoad: webViewRequest.hasNext
                  ? () => _loadComments(isInit: false)
                  : null,
              child: SingleChildScrollView(
                // headerSliverBuilder:
                //     (BuildContext context, bool innerBoxIsScrolled) => [
                //   SliverToBoxAdapter(
                //     child: _titleBuilder(),
                //   ),
                //   SliverToBoxAdapter(
                //     child: _contentBuilder(),
                //   ),
                // ],
                child: Column(
                  children: [
                    _titleBuilder(),
                    _contentBuilder(),
                    _queryBuilder(),
                    _replyListBuilder(),
                    if (_commentsLoading)
                      const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                    if (_commentError != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          Text(_commentError!, textAlign: TextAlign.center),
                          TextButton(
                            onPressed: () => _loadComments(isInit: _retryCommentsFromStart),
                            child: const Text('重新加载评论'),
                          ),
                        ]),
                      ),
                    if (!webViewRequest.hasNext && !_commentsLoading && _commentError == null)
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        child: const Text(
                          "没有更多了",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color.fromRGBO(150, 151, 153, 1),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _bottomInputBar(),
          );
  }

  Widget _queryBuilder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          DropdownButton<String>(
            value: selectedOption1,
            underline: Container(),
            dropdownColor: Colors.white,
            items: ["所有评论", "只看楼主"]
                .map(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14.0, // 下拉选项字体大小
                        color: Colors.black87, // 下拉选项字体颜色
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (newValue) async {
              if (_commentsLoading || newValue == null) return;
              if (newValue == "所有评论") {
                isAuther = false;
              } else {
                isAuther = true;
              }
              setState(() => selectedOption1 = newValue);
              await _loadComments();
              // showToast("已选择: $newValue");
            },
          ),
          const Spacer(),
          DropdownButton<String>(
            value: selectedOption2,
            underline: Container(),
            dropdownColor: Colors.white,
            items: ["默认", "最早", "最新"]
                .map(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14.0, // 下拉选项字体大小
                        color: Colors.black87, // 下拉选项字体颜色
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (newValue) async {
              onSortOptionChanged(newValue);
              // showToast("已选择: $newValue");
            },
          ),
        ],
      ),
    );
  }

  Future<void> onSortOptionChanged(String? newValue) async {
    if (_commentsLoading || newValue == null) return;
    if (newValue == "默认") {
      sortType = 0;
    } else if (newValue == "最早") {
      sortType = 1;
    } else {
      sortType = 2;
    }

    setState(() => selectedOption2 = newValue);
    await _loadComments();

    // Optional: showToast if needed
    // showToast("已选择: $newValue");
  }

  Widget _bottomInputBar() {
    return Padding(
      padding: MediaQuery.of(context).viewInsets, // 动态调整键盘间距
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200]!,
              offset: const Offset(0, -1),
              blurRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isInputActive
                ? Container(
                    // margin: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "    回复 @${replyto == "" ? webViewRequest.webViewContent.userNickName : replyto}："),
                        TextField(
                          style: const TextStyle(
                            fontSize: 14.0, // 设置输入字体的大小
                            color: Colors.black, // 设置字体颜色，可选
                          ),
                          controller: _commentController,
                          autofocus: true, // 自动弹出键盘
                          minLines: 1, // 最小行数为1
                          maxLines: null, // 自动扩展高度
                          decoration: const InputDecoration(
                            hintText: "请输入正文",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14.0),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 15.0), // 添加内边距
                          ),
                          onSubmitted: (value) async {
                            await _submitComment();
                          },
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        isInputActive = true; // 激活输入框
                      });
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40.0,
                            alignment: Alignment.centerLeft,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: const Text(
                              "说点什么...",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Image.asset(
                          "assets/comments.png",
                          width: UiSizeUtil.postCommentLikeIconSize,
                          height: UiSizeUtil.postCommentLikeIconSize,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            webViewRequest.webViewContent.commentNum.toString(),
                            style: TextStyle(
                              fontSize: UiSizeUtil.postCommentLikeFontSize,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            if (isInputActive) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end, // 按钮靠右对齐
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        clearComment();
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text("取消"),
                  ),
                  TextButton(
                    onPressed: _submitComment,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0), // 缩小按钮的 padding
                      minimumSize: Size.zero, // 确保按钮大小受 padding 控制
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap, // 收缩按钮点击范围
                    ),
                    child: const Text("提交"),
                  ),
                  // 增加按钮之间的间隔
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submitComment() async {
    // 处理评论提交
    String comment = _commentController.text;

    if (comment.trim().isEmpty) {
      // 如果为空或仅包含空格和换行符，不执行提交操作
      showToast("评论内容不能为空");
      return;
    }

    // 获取输入内容并按自然段分割（空行分隔）
    List<String> paragraphs = _commentController.text.split(RegExp(r'\n'));
    // 将每个自然段转换为 <p> 标签包裹的格式
    String htmlString =
        paragraphs.map((paragraph) => '<p>$paragraph</p>').join();
    // showToast("$commentId + $commentSubId + $replyto");
    if (commentId == 0) {
      await webViewRequest.submitComment(widget.topicId, htmlString);
      selectedOption2 = "最新";
      onSortOptionChanged(selectedOption2);
    } else {
      await webViewRequest.submitComment(widget.topicId, htmlString,
          commentId: commentId, commentSubId: commentSubId);
      SingleComment result =
          await webViewRequest.getCommentDetail(widget.topicId, commentId);
      //将新的回复添加到对应的评论中
      for (int i = 0; i < webViewRequest.replyList.length; i++) {
        if (webViewRequest.replyList[i].commentId == commentId) {
          webViewRequest.replyList[i].commentReply = result.commentReply;
          break;
        }
      }
    }
    clearComment();
    setState(() {});
    // if (comment.isNotEmpty) {
    //   _commentController.clear();
    //   setState(() {
    //     isInputActive = false; // 提交后恢复为未激活状态
    //   });
    // }
  }

  Future<void> _toggleAuthorFollow() async {
    if (_isFollowing) return;
    final topic = webViewRequest.webViewContent;
    setState(() => _isFollowing = true);
    try {
      final success = await likeAndFollow.follow(topic.userId);
      if (!mounted || !success) return;
      setState(() => topic.isFollow = !topic.isFollow);
      homeScaffoldState?.updateFollowState(topic.userId, topic.isFollow);
    } catch (_) {
      if (mounted) showToast('关注操作失败，请重试');
    } finally {
      if (mounted) setState(() => _isFollowing = false);
    }
  }

  Widget _titleBuilder() {
    final topic = webViewRequest.webViewContent;
    return TopicDetailHeader(
      topic: topic,
      onOpenAuthor: () => RouteUtils.push(
        context,
        OtherUserPage(uid: topic.userId.toString()),
      ),
      onFollow: _isFollowing ? null : _toggleAuthorFollow,
    );
  }

  Widget _contentBuilder() {
    final topic = webViewRequest.webViewContent;
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectionArea(
            child: HtmlWidget(
              topic.content,
              factoryBuilder: () => MyWidgetFactory(context),
              onTapUrl: _openTopicLink,
              customStylesBuilder: HtmlProcess.buildCustomStyles,
              textStyle: TextStyle(
                fontSize: UiSizeUtil.postContentFontSize,
                color: Colors.black,
              ),
            ),
          ),
          TopicDetailMetadata(topic: topic),
        ],
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

  Widget _replyBuilder(SingleComment reply) {
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
                onTapUrl: _openTopicLink,
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
          _secondaryReplyListBuilder(reply.commentReply, reply.commentId),

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
                onTap: () async {
                  replyto = reply.userNickName;
                  commentId = reply.commentId;
                  setState(() {
                    isInputActive = true;
                  });
                },
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

  Widget _secondaryReplyListBuilder(
      List<CommentReply> commentReply, int replyId) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return _secondaryReplyBuilder(
          commentReply[index],
          replyId,
        );
      },
      itemCount: commentReply.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Future<void> _likeSecondaryReply(CommentReply reply) async {
    if (!mounted || _pendingReplyLikes.contains(reply.commentId)) return;
    setState(() => _pendingReplyLikes.add(reply.commentId));
    try {
      // 点赞的是楼中楼评论自身，不能使用所属楼层的 replyId。
      final success = await webViewRequest.likeComment(widget.topicId, reply.commentId);
      if (!mounted) return;
      if (!success) {
        showToast('操作失败，请稍后重试');
        return;
      }
      setState(() {
        reply.isLike = !reply.isLike;
        if (reply.isLike) {
          reply.likeNum++;
        } else if (reply.likeNum > 0) {
          reply.likeNum--;
        }
      });
      showToast(reply.isLike ? '点赞成功' : '取消点赞');
    } catch (_) {
      if (mounted) showToast('操作失败，请检查网络或登录状态后重试');
    } finally {
      if (mounted) {
        setState(() => _pendingReplyLikes.remove(reply.commentId));
      }
    }
  }

  Widget _secondaryReplyBuilder(CommentReply reply, int replyId) {
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
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 3,
            children: [
              GestureDetector(
                onTap: () {
                  // showToast(webViewRequest.webViewContent.userId.toString());
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
                    // showToast(webViewRequest.webViewContent.userId.toString());
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
              if (reply.replyToUid == webViewRequest.webViewContent.userId)
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
              onTapUrl: _openTopicLink,
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
                onTap: _pendingReplyLikes.contains(reply.commentId)
                    ? null
                    : () => _likeSecondaryReply(reply),
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
                onTap: () {
                  replyto = reply.userNickName;
                  commentId = replyId;
                  commentSubId = reply.commentId;
                  setState(() {
                    isInputActive = true;
                  });
                },
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

