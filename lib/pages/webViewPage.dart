import 'widgets/topic_detail_header.dart';
import 'widgets/topic_detail_metadata.dart';
import 'widgets/comment_cards.dart';
import 'widgets/comment_thread_sheet.dart';
import 'widgets/comment_composer_sheet.dart';
import 'widgets/comment_editing_controller.dart';
import 'package:flutter/services.dart';
import 'package:grfanonymous/models/replyList.dart';
import 'package:grfanonymous/pageRequest/webViewRequest.dart';
import 'package:grfanonymous/utils/htmlUtil.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:oktoast/oktoast.dart';

import '../pageRequest/likeAndFollow.dart';
import '../ui/uiSizeUtil.dart';
import '../utils/globalKey.dart';
import '../utils/routeUtil.dart';
import '../utils/topic_link.dart';
import '../models/webViewContent.dart';
import 'otherUserPage.dart';
import 'theme_detail_page.dart';

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
  bool isLoading = true;
  String? _loadError;
  String? _commentError;
  bool _initializing = false;
  bool _commentsLoading = false;
  bool _retryCommentsFromStart = true;
  bool _isOpeningTopicLink = false;
  final Set<int> _pendingReplyLikes = {};
  bool _isFollowing = false;
  bool _composerOpen = false;
  bool _repliesSheetOpen = false;
  final _commentsStartKey = GlobalKey();
  bool _scrollingToComments = false;
  // 仅当前帖子页面内保留，按一级评论和楼中楼目标区分草稿。
  final _commentDrafts = <(int, int), CommentEditingController>{};
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
    for (final controller in _commentDrafts.values) {
      controller.dispose();
    }
    _commentDrafts.clear();
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

  Future<bool> _openTopicLink(String url, {BuildContext? sourceContext}) async {
    final context = sourceContext ?? this.context;
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
      if (!mounted || !context.mounted || ModalRoute.of(context)?.isCurrent != true) return true;
      await RouteUtils.push(context, WebViewPage(
        topicId: topicId, initialContent: request.webViewContent,
      ));
    } catch (error) {
      if (mounted && context.mounted && ModalRoute.of(context)?.isCurrent == true) {
        showToast(error is TopicRequestException ? error.message : '帖子加载失败，请重试');
      }
    } finally {
      _isOpeningTopicLink = false;
    }
    return true;
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
            // 输入由独立底部弹层避让键盘，帖子正文无需随之重新排版。
            resizeToAvoidBottomInset: false,
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
      key: _commentsStartKey,
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

  Future<void> _onCommentButtonTap() async {
    if (_scrollingToComments) return;
    final anchorContext = _commentsStartKey.currentContext;
    final anchor = anchorContext?.findRenderObject();
    if (anchorContext == null || anchor == null || !anchor.attached) return;
    final scrollable = Scrollable.maybeOf(anchorContext);
    final viewport = RenderAbstractViewport.maybeOf(anchor);
    if (scrollable == null || viewport == null) return;
    final position = scrollable.position;
    if (!position.hasContentDimensions) return;

    // 筛选栏完整进入可视区域，或已经向下滚过它，就视为到达评论区。
    final visibleOffset = viewport.getOffsetToReveal(anchor, 1).offset;
    if (position.pixels >= visibleOffset - 1) {
      await _openCommentComposer();
      return;
    }

    final target = viewport.getOffsetToReveal(anchor, 0).offset
        .clamp(position.minScrollExtent, position.maxScrollExtent).toDouble();
    _scrollingToComments = true;
    try {
      await position.animateTo(target,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
    } finally {
      _scrollingToComments = false;
    }
  }

  Widget _bottomInputBar() {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(children: [
            Expanded(child: InkWell(
              onTap: () => _openCommentComposer(),
              child: Container(
              height: 40,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200], borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('说点什么...', style: TextStyle(color: Colors.grey)),
            ))),
            const SizedBox(width: 10),
            InkWell(
              onTap: _onCommentButtonTap,
              child: SizedBox(
                height: 40,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Image.asset('assets/comments.png',
                    width: UiSizeUtil.postCommentLikeIconSize,
                    height: UiSizeUtil.postCommentLikeIconSize),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text('${webViewRequest.webViewContent.commentNum}',
                      style: TextStyle(fontSize: UiSizeUtil.postCommentLikeFontSize, color: Colors.grey)),
                  ),
                ]),
              ),
            ),
          ]),
      ),
    );
  }

  Future<void> _openCommentComposer({
    BuildContext? sourceContext,
    String? name,
    String? avatar,
    int parentId = 0,
    int subId = 0,
  }) async {
    if (_composerOpen || !mounted) return;
    _composerOpen = true;
    try {
      final controller = _commentDrafts.putIfAbsent(
        (parentId, subId), () => CommentEditingController(),
      );
      controller.restoreSelection();
      await showModalBottomSheet<void>(
        context: sourceContext ?? context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CommentComposerSheet(
          controller: controller,
          replyName: name ?? webViewRequest.webViewContent.userNickName,
          replyAvatar: avatar ?? webViewRequest.webViewContent.userAvatar,
          onSubmit: (contentHtml) => _submitComment(contentHtml, parentId: parentId, subId: subId),
        ),
      );
    } finally {
      _composerOpen = false;
    }
  }

  Future<bool> _submitComment(String contentHtml, {required int parentId, required int subId}) async {
    final submitted = await webViewRequest.submitComment(widget.topicId, contentHtml,
      commentId: parentId, commentSubId: subId);
    if (!submitted) return false;
    if (!mounted) return true;
    // 提交已成功，后续刷新失败也不应提示重新发送，避免重复评论。
    try {
      if (parentId == 0) {
        await onSortOptionChanged('最新');
      } else {
        final result = await webViewRequest.getCommentDetail(widget.topicId, parentId);
        if (!mounted) return true;
        for (final reply in webViewRequest.replyList) {
          if (reply.commentId == parentId) {
            reply.commentReply = result.commentReply;
            reply.replyNum = result.replyNum;
            break;
          }
        }
      }
    } catch (_) {
      if (mounted) showToast('回复已提交，列表更新失败，请刷新查看');
    }
    if (mounted) setState(() {});
    return true;
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
          TopicDetailMetadata(
            topic: topic,
            onOpenTheme: (id, name) => RouteUtils.push(context, ThemeDetailPage(themeId: id, name: name)),
          ),
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
    return CommentCard(
      reply: reply,
      replies: _secondaryReplyListBuilder(reply),
      onTapUrl: (url) => _openTopicLink(url),
      onLike: _pendingReplyLikes.contains(reply.commentId)
          ? null : () => _likeParentReply(reply),
      onReply: () => _openCommentComposer(
        name: reply.userNickName, avatar: reply.userAvatar,
        parentId: reply.commentId,
      ),
    );
  }

  Future<void> _likeParentReply(SingleComment reply) async {
    if (_pendingReplyLikes.contains(reply.commentId)) return;
    setState(() => _pendingReplyLikes.add(reply.commentId));
    try {
      final success = await webViewRequest.likeComment(widget.topicId, reply.commentId);
      if (!mounted) return;
      if (!success) {
        showToast('操作失败，请稍后重试');
        return;
      }
      setState(() {
        reply.isLike = !reply.isLike;
        reply.likeNum = (reply.likeNum + (reply.isLike ? 1 : -1)).clamp(0, 1 << 31).toInt();
      });
    } catch (_) {
      if (mounted) showToast('操作失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _pendingReplyLikes.remove(reply.commentId));
    }
  }

  Widget _secondaryReplyListBuilder(SingleComment parent) {
    final total = parent.replyNum > parent.commentReply.length
        ? parent.replyNum : parent.commentReply.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final reply in parent.commentReply.take(2))
          _secondaryReplyBuilder(reply, parent.commentId),
        if (total > 2)
          Container(
            margin: const EdgeInsets.only(left: 45),
            color: Colors.grey[200],
            child: InkWell(
              onTap: () => _showAllReplies(parent),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text('查看全部$total条', style: TextStyle(
                  color: const Color(0xFFF26C1C),
                  fontSize: UiSizeUtil.secondCommentFontSize,
                )),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showAllReplies(SingleComment parent) async {
    if (_repliesSheetOpen || _pendingReplyLikes.isNotEmpty) return;
    _repliesSheetOpen = true;
    try {
      await showCommentThreadSheet(
        context: context, topicId: widget.topicId, commentId: parent.commentId,
        initialComment: parent,
        topicAuthorId: webViewRequest.webViewContent.userId,
        draftFor: (parentId, subId) => _commentDrafts.putIfAbsent(
          (parentId, subId), CommentEditingController.new),
        onOpenTopic: (context, topicId) => RouteUtils.push(
          context, WebViewPage(topicId: topicId)),
        onChanged: (updated) {
          if (!mounted) return;
          final index = webViewRequest.replyList.indexWhere(
            (item) => item.commentId == updated.commentId);
          if (index >= 0) {
            setState(() => webViewRequest.replyList[index] = updated);
          }
        },
      );
    } finally {
      _repliesSheetOpen = false;
    }
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
    return CommentReplyCard(
      reply: reply,
      topicAuthorId: webViewRequest.webViewContent.userId,
      onTapUrl: (url) => _openTopicLink(url),
      onLike: _pendingReplyLikes.contains(reply.commentId)
          ? null : () => _likeSecondaryReply(reply),
      onReply: () => _openCommentComposer(
        name: reply.userNickName, avatar: reply.userAvatar,
        parentId: replyId, subId: reply.commentId,
      ),
    );
  }
}

