import '../../pageRequest/request_failure.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import '../../models/replyList.dart';
import '../../pageRequest/webViewRequest.dart';
import '../../utils/topic_link.dart';
import '../../utils/user_link.dart';
import '../../utils/routeUtil.dart';
import '../otherUserPage.dart';
import 'comment_cards.dart';
import 'comment_composer_sheet.dart';
import 'comment_editing_controller.dart';
import 'comment_replies_sheet.dart';

/// 两个入口共用同一面板；导航由调用页面提供。
Future<void> showCommentThreadSheet({
  required BuildContext context,
  required String topicId,
  required int commentId,
  required void Function(BuildContext, String) onOpenTopic,
  SingleComment? initialComment,
  int? topicAuthorId,
  bool showOriginalTopic = false,
  ValueChanged<SingleComment>? onChanged,
  CommentEditingController Function(int, int)? draftFor,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.85,
      child: _CommentThreadSheet(
        topicId: topicId, commentId: commentId,
        initialComment: initialComment, topicAuthorId: topicAuthorId,
        showOriginalTopic: showOriginalTopic,
        onOpenTopic: onOpenTopic, onChanged: onChanged,
        draftFor: draftFor,
      ),
    ),
  );
}

class _CommentThreadSheet extends StatefulWidget {
  const _CommentThreadSheet({required this.topicId, required this.commentId,
    required this.initialComment, required this.topicAuthorId,
    required this.showOriginalTopic, required this.onOpenTopic, this.onChanged,
    this.draftFor});
  final String topicId;
  final int commentId;
  final SingleComment? initialComment;
  final int? topicAuthorId;
  final bool showOriginalTopic;
  final void Function(BuildContext, String) onOpenTopic;
  final ValueChanged<SingleComment>? onChanged;
  final CommentEditingController Function(int, int)? draftFor;

  @override
  State<_CommentThreadSheet> createState() => _CommentThreadSheetState();
}

class _CommentThreadSheetState extends State<_CommentThreadSheet> {
  final _request = WebViewRequest();
  final _changes = ValueNotifier(0);
  final _drafts = <int, CommentEditingController>{};
  final _pendingLikes = <int>{};
  SingleComment? _parent;
  bool _loading = false;
  bool _composerOpen = false;
  bool _openingUser = false;

  @override
  void initState() {
    super.initState();
    _parent = widget.initialComment;
  }

  @override
  void dispose() {
    for (final draft in _drafts.values) {
      draft.dispose();
    }
    _changes.dispose();
    super.dispose();
  }

  void _notify({bool dataChanged = false}) {
    if (!mounted) return;
    _changes.value++;
    final parent = _parent;
    // 等待请求、按钮禁用等状态仅属于弹层；数据改变才同步对应楼层。
    if (dataChanged && parent != null) widget.onChanged?.call(parent);
  }

  Future<void> _load() async {
    _loading = true;
    var dataChanged = false;
    try {
      if (widget.commentId <= 0) {
        throw const TopicRequestException('消息缺少评论信息，请查看原帖');
      }
      final parent = await _request.getCommentDetail(widget.topicId, widget.commentId);
      if (!mounted) return;
      _parent = parent;
      dataChanged = true;
    } finally {
      _loading = false;
      _notify(dataChanged: dataChanged);
    }
  }

  Future<void> _like({CommentReply? reply}) async {
    final parent = _parent;
    if (parent == null || _loading) return;
    final id = reply?.commentId ?? parent.commentId;
    if (!_pendingLikes.add(id)) return;
    _notify();
    var dataChanged = false;
    try {
      final success = await _request.likeComment(widget.topicId, id);
      if (!mounted) return;
      if (!success) {
        showToast('操作失败，请稍后重试');
        return;
      }
      if (reply == null) {
        parent.isLike = !parent.isLike;
        parent.likeNum = (parent.likeNum + (parent.isLike ? 1 : -1)).clamp(0, 1 << 31).toInt();
      } else {
        reply.isLike = !reply.isLike;
        reply.likeNum = (reply.likeNum + (reply.isLike ? 1 : -1)).clamp(0, 1 << 31).toInt();
      }
      dataChanged = true;
      showToast((reply?.isLike ?? parent.isLike) ? '点赞成功' : '取消点赞');
    } catch (error) {
      if (mounted) RequestFailure.notify(error);
    } finally {
      _pendingLikes.remove(id);
      _notify(dataChanged: dataChanged);
    }
  }

  Future<void> _reply({CommentReply? reply}) async {
    final parent = _parent;
    if (parent == null || _composerOpen || _loading || _pendingLikes.isNotEmpty) return;
    _composerOpen = true;
    final subId = reply?.commentId ?? 0;
    final draft = widget.draftFor?.call(parent.commentId, subId)
        ?? _drafts.putIfAbsent(subId, CommentEditingController.new);
    draft.restoreSelection();
    try {
      await showModalBottomSheet<void>(
        context: context, isScrollControlled: true, useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CommentComposerSheet(
          controller: draft,
          replyName: reply?.userNickName ?? parent.userNickName,
          replyAvatar: reply?.userAvatar ?? parent.userAvatar,
          onSubmit: (html) async {
            final success = await _request.submitComment(widget.topicId, html,
              commentId: parent.commentId, commentSubId: subId);
            if (!success || !mounted) return success;
            try {
              await _load();
            } catch (_) {
              if (mounted) showToast('回复已提交，列表更新失败，请重新打开面板');
            }
            return true;
          },
        ),
      );
    } finally {
      _composerOpen = false;
    }
  }

  Future<bool> _openLink(String url) async {
    final uid = UserLink.parseHref(url);
    if (uid != null) {
      if (!mounted || _openingUser || ModalRoute.of(context)?.isCurrent != true) return true;
      _openingUser = true;
      try {
        await RouteUtils.push(context, OtherUserPage(uid: uid));
      } finally {
        _openingUser = false;
      }
      return true;
    }
    final topicId = TopicLink.parseHref(url);
    if (topicId == null) return false;
    _openTopic(topicId);
    return true;
  }

  void _openTopic(String topicId) {
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      widget.onOpenTopic(context, topicId);
    }
  }

  int? get _topicAuthorId {
    if (widget.topicAuthorId != null) return widget.topicAuthorId;
    final parent = _parent;
    if (parent == null) return null;
    if (parent.isAuthor) return parent.userId;
    for (final reply in parent.commentReply) {
      if (reply.isAuthor) return reply.userId;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CommentRepliesSheet(
      changes: _changes,
      loadReplies: _load,
      parentBuilder: (_) {
        final parent = _parent;
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (parent != null)
            CommentCard(
              reply: parent, onTapUrl: _openLink,
              isLikeBusy: _loading || _pendingLikes.contains(parent.commentId),
              onLike: _loading || _pendingLikes.contains(parent.commentId)
                  ? null : () => _like(),
              onReply: () => _reply(),
            ),
          if (widget.showOriginalTopic)
            Align(alignment: Alignment.centerLeft, child: TextButton(
              onPressed: () => _openTopic(widget.topicId),
              child: const Text('查看原帖', style: TextStyle(color: Color(0xFFF26C1C))),
            )),
        ]);
      },
      replyCount: () => _parent?.commentReply.length ?? 0,
      replyBuilder: (_, index) {
        final reply = _parent!.commentReply[index];
        return CommentReplyCard(
          reply: reply, inSheet: true, topicAuthorId: _topicAuthorId,
          onTapUrl: _openLink,
          isLikeBusy: _loading || _pendingLikes.contains(reply.commentId),
          onLike: _loading || _pendingLikes.contains(reply.commentId)
              ? null : () => _like(reply: reply),
          onReply: () => _reply(reply: reply),
        );
      },
    );
  }
}
