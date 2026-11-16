import '../pageRequest/request_failure.dart';
import 'widgets/request_error_view.dart';
import 'widgets/topic_detail_header.dart';
import 'widgets/topic_hidden_content.dart';
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
import '../utils/theme_link.dart';
import '../utils/user_link.dart';
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
  Object? _loadError;
  String? _commentError;
  bool _initializing = false;
  bool _commentsLoading = false;
  bool _retryCommentsFromStart = true;
  bool _isOpeningTopicLink = false;
  final Set<int> _pendingReplyLikes = {};
  // 数据对象本身可变，用版本通知刷新单个楼层，避免整页 setState。
  final _commentChanges = <int, ValueNotifier<int>>{};
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
  int _loadedSort = 0;
  bool _loadedOnlyAuthor = false;

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
    for (final changes in _commentChanges.values) {
      changes.dispose();
    }
    _commentChanges.clear();
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
          ? RequestFailure(FailureKind.invalidData, error.message) : error);
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
    });
    try {
      await webViewRequest.getReplyList(widget.topicId,
          isInit: isInit, isAuther: isAuther, sort: sortType);
      if (!mounted) return IndicatorResult.fail;
      if (isInit) _resetCommentScroll();
      _loadedSort = sortType;
      _loadedOnlyAuthor = isAuther;
      // 是否继续加载由 hasNext 控制，避免切换评论筛选后残留 noMore 状态。
      return IndicatorResult.success;
    } catch (error) {
      if (mounted) setState(() {
        _commentError = error is TopicRequestException ? error.message : RequestFailure.from(error).message;
        sortType = _loadedSort;
        isAuther = _loadedOnlyAuthor;
        selectedOption1 = isAuther ? '只看楼主' : '所有评论';
        selectedOption2 = ['默认', '最早', '最新'][sortType];
      });
      return IndicatorResult.fail;
    } finally {
      if (mounted) setState(() => _commentsLoading = false);
    }
  }

  Future<bool> _openTopicLink(String url, {BuildContext? sourceContext}) async {
    final context = sourceContext ?? this.context;
    final themeId = ThemeLink.parseHref(url);
    if (themeId != null) {
      if (!mounted || !context.mounted || _isOpeningTopicLink ||
          ModalRoute.of(context)?.isCurrent != true) return true;
      _isOpeningTopicLink = true;
      try {
        await RouteUtils.push(context, ThemeDetailPage(themeId: themeId, name: '话题详情'));
      } finally {
        _isOpeningTopicLink = false;
      }
      return true;
    }
    final uid = UserLink.parseHref(url);
    if (uid != null) {
      if (!mounted || !context.mounted || _isOpeningTopicLink ||
          ModalRoute.of(context)?.isCurrent != true) return true;
      _isOpeningTopicLink = true;
      try {
        await RouteUtils.push(context, OtherUserPage(uid: uid));
      } finally {
        _isOpeningTopicLink = false;
      }
      return true;
    }
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
        if (error is TopicRequestException) showToast(error.message);
        else RequestFailure.notify(error);
      }
    } finally {
      _isOpeningTopicLink = false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // 请求成功前不读取 late 初始化的帖子数据，页眉与底栏保持同一结构。
    final ready = !isLoading && _loadError == null;
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
                      color: !ready ? Colors.white30 : webViewRequest.webViewContent.isFavor
                          ? const Color.fromRGBO(242, 108, 28, 1)
                          : Colors.white,
                    ),
                    onPressed: !ready ? null : () async {
                      bool result =
                          await webViewRequest.favorTopic(widget.topicId);
                      if (result && mounted) {
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
                      color: ready ? Colors.white : Colors.white30,
                    ),
                    onPressed: !ready ? null : () async {
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
                      color: !ready ? Colors.white30 : webViewRequest.webViewContent.isLike
                          ? const Color.fromRGBO(242, 108, 28, 1)
                          : Colors.white,
                      Icons.thumb_up_off_alt,
                      size: UiSizeUtil.topIconSize,
                    ),
                    onPressed: !ready ? null : () async {
                      bool result = await likeAndFollow.like(widget.topicId);
                      if (result && mounted) {
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
            body: _pageBody(),
            bottomNavigationBar: _bottomInputBar(enabled: ready),
          );
  }

  Widget _pageBody() {
    // 只构建当前状态，不让隐藏的正文、图片或评论参与布局。
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (_loadError != null) {
      return RequestErrorView(error: _loadError!, onRetry: initTopic);
    }
    return EasyRefresh(
              triggerAxis: Axis.vertical,
              header: const MaterialHeader(),
              refreshOnStart: true,
              onLoad: webViewRequest.hasNext
                  ? () => _loadComments(isInit: false)
                  : null,
              child: CustomScrollView(
                // 只预建可视区域附近的评论，避免一次布局所有已加载楼层。
                cacheExtent: 300,
                slivers: [
                  SliverToBoxAdapter(child: _titleBuilder()),
                  SliverToBoxAdapter(child: _contentBuilder()),
                  // 独立保留筛选栏锚点，离屏后仍可定位评论区。
                  SliverToBoxAdapter(child: _queryBuilder()),
                  _replySliverBuilder(),
                  SliverToBoxAdapter(child: Column(children: [
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
                  ])),
                ],
              ),
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

  (ScrollPosition, double)? _commentScrollTarget({double alignment = 0}) {
    final anchorContext = _commentsStartKey.currentContext;
    final anchor = anchorContext?.findRenderObject();
    if (anchorContext == null || anchor is! RenderBox ||
        !anchor.attached || !anchor.hasSize) return null;
    final scrollable = Scrollable.maybeOf(anchorContext);
    final viewport = RenderAbstractViewport.maybeOf(anchor);
    if (scrollable == null || viewport == null) return null;
    final position = scrollable.position;
    if (!position.hasContentDimensions) return null;
    return (position, viewport.getOffsetToReveal(anchor, alignment).offset);
  }

  void _resetCommentScroll() {
    final target = _commentScrollTarget();
    if (target == null) return;
    final (position, offset) = target;
    final start = offset.clamp(position.minScrollExtent, position.maxScrollExtent).toDouble();
    // 在正文中阅读时保持位置；清空旧评论前先离开旧列表深处。
    if (position.pixels > start) position.jumpTo(start);
  }

  Future<void> _onCommentButtonTap() async {
    if (_scrollingToComments) return;
    final visibleTarget = _commentScrollTarget(alignment: 1);
    if (visibleTarget == null) return;
    final (position, visibleOffset) = visibleTarget;

    // 筛选栏完整进入可视区域，或已经向下滚过它，就视为到达评论区。
    if (position.pixels >= visibleOffset - 1) {
      await _openCommentComposer();
      return;
    }

    final startTarget = _commentScrollTarget();
    if (startTarget == null) return;
    final target = startTarget.$2
        .clamp(position.minScrollExtent, position.maxScrollExtent).toDouble();
    _scrollingToComments = true;
    try {
      await position.animateTo(target,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
    } finally {
      _scrollingToComments = false;
    }
  }

  Widget _bottomInputBar({required bool enabled}) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(children: [
            Expanded(child: InkWell(
              onTap: enabled ? () => _openCommentComposer() : null,
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
              onTap: enabled ? _onCommentButtonTap : null,
              child: SizedBox(
                height: 40,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Image.asset('assets/comments.png',
                    width: UiSizeUtil.postCommentLikeIconSize,
                    height: UiSizeUtil.postCommentLikeIconSize),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(enabled ? '${webViewRequest.webViewContent.commentNum}' : '—',
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
        _replaceComment(result);
      }
    } catch (_) {
      if (mounted) showToast('回复已提交，列表更新失败，请刷新查看');
    }
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
    } catch (error) {
      if (mounted) RequestFailure.notify(error);
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
    final hiddenById = {for (final item in topic.hideInfo) item.hd: item};
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
              customWidgetBuilder: (element) {
                if (element.localName != 'img' || !element.classes.contains('showFold')) return null;
                final id = element.attributes['alt']?.trim();
                final hidden = hiddenById[id];
                if (hidden == null) return const Text('折叠内容暂不可用', style: TextStyle(color: Colors.grey));
                return TopicHiddenContentView(
                  key: ValueKey('${topic.topicId}:$id'), content: hidden,
                );
              },
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

  Widget _replySliverBuilder() {
    final comments = webViewRequest.replyList;
    final indexById = <int, int>{
      for (var index = 0; index < comments.length; index++)
        comments[index].commentId: index,
    };
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final reply = comments[index];
          return ValueListenableBuilder<int>(
            key: ValueKey(reply.commentId),
            valueListenable: _commentChanges.putIfAbsent(
              reply.commentId, () => ValueNotifier(0)),
            builder: (context, _, __) {
              // 弹层会返回新的评论实例，不能一直捕获旧的 reply。
              final items = webViewRequest.replyList;
              if (index >= items.length || items[index].commentId != reply.commentId) {
                return const SizedBox.shrink();
              }
              return _replyBuilder(items[index]);
            },
          );
        },
        childCount: comments.length,
        findChildIndexCallback: (key) =>
            key is ValueKey<int> ? indexById[key.value] : null,
        // 交互状态与草稿保留在页面中，离屏楼层可释放后重新构建。
        addAutomaticKeepAlives: false,
      ),
    );
  }

  void _notifyComment(int commentId) {
    if (!mounted) return;
    final changes = _commentChanges[commentId];
    if (changes != null) changes.value++;
  }

  void _replaceComment(SingleComment updated) {
    if (!mounted) return;
    final index = webViewRequest.replyList.indexWhere(
      (item) => item.commentId == updated.commentId);
    if (index < 0) return;
    webViewRequest.replyList[index] = updated;
    _notifyComment(updated.commentId);
  }

  Widget _replyBuilder(SingleComment reply) {
    return CommentCard(
      reply: reply,
      replies: _secondaryReplyListBuilder(reply),
      onTapUrl: (url) => _openTopicLink(url),
      isLikeBusy: _pendingReplyLikes.contains(reply.commentId),
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
    _pendingReplyLikes.add(reply.commentId);
    _notifyComment(reply.commentId);
    try {
      final success = await webViewRequest.likeComment(widget.topicId, reply.commentId);
      if (!mounted) return;
      if (!success) {
        showToast('操作失败，请稍后重试');
        return;
      }
      reply.isLike = !reply.isLike;
      reply.likeNum = (reply.likeNum + (reply.isLike ? 1 : -1)).clamp(0, 1 << 31).toInt();
      showToast(reply.isLike ? '点赞成功' : '取消点赞');
    } catch (error) {
      if (mounted) RequestFailure.notify(error);
    } finally {
      _pendingReplyLikes.remove(reply.commentId);
      _notifyComment(reply.commentId);
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
        onChanged: _replaceComment,
      );
    } finally {
      _repliesSheetOpen = false;
    }
  }

  Future<void> _likeSecondaryReply(CommentReply reply, int parentId) async {
    if (!mounted || _pendingReplyLikes.contains(reply.commentId)) return;
    _pendingReplyLikes.add(reply.commentId);
    _notifyComment(parentId);
    try {
      // 点赞的是楼中楼评论自身，不能使用所属楼层的 replyId。
      final success = await webViewRequest.likeComment(widget.topicId, reply.commentId);
      if (!mounted) return;
      if (!success) {
        showToast('操作失败，请稍后重试');
        return;
      }
      reply.isLike = !reply.isLike;
      if (reply.isLike) {
        reply.likeNum++;
      } else if (reply.likeNum > 0) {
        reply.likeNum--;
      }
      showToast(reply.isLike ? '点赞成功' : '取消点赞');
    } catch (error) {
      if (mounted) RequestFailure.notify(error);
    } finally {
      _pendingReplyLikes.remove(reply.commentId);
      _notifyComment(parentId);
    }
  }

  Widget _secondaryReplyBuilder(CommentReply reply, int replyId) {
    return CommentReplyCard(
      reply: reply,
      topicAuthorId: webViewRequest.webViewContent.userId,
      onTapUrl: (url) => _openTopicLink(url),
      isLikeBusy: _pendingReplyLikes.contains(reply.commentId),
      onLike: _pendingReplyLikes.contains(reply.commentId)
          ? null : () => _likeSecondaryReply(reply, replyId),
      onReply: () => _openCommentComposer(
        name: reply.userNickName, avatar: reply.userAvatar,
        parentId: replyId, subId: reply.commentId,
      ),
    );
  }
}

