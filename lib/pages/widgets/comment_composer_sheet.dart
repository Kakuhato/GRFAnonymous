import '../../pageRequest/request_failure.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/image_decode_size.dart';
import 'package:flutter/material.dart';

import '../../ui/uiSizeUtil.dart';
import '../../pageRequest/emoji_request.dart';
import 'comment_editing_controller.dart';
import 'official_emoji_picker.dart';

class CommentComposerSheet extends StatefulWidget {
  const CommentComposerSheet({
    super.key,
    required this.replyName,
    required this.replyAvatar,
    required this.controller,
    required this.onSubmit,
  });

  final String replyName;
  final String replyAvatar;
  final CommentEditingController controller;
  final Future<bool> Function(String contentHtml) onSubmit;

  @override
  State<CommentComposerSheet> createState() => _CommentComposerSheetState();
}

class _CommentComposerSheetState extends State<CommentComposerSheet> {
  // 草稿由帖子页面持有，关闭本弹层时不销毁。
  CommentEditingController get _controller => widget.controller;
  final _textFieldKey = GlobalKey();
  final _focus = FocusNode();
  bool _emojiOpen = false;
  bool _focusScheduled = false;
  Animation<double>? _openingAnimation;
  bool _submitting = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_focusScheduled) return;
    _focusScheduled = true;
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.status == AnimationStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusAfterOpening());
    } else {
      _openingAnimation = animation;
      animation.addStatusListener(_onAnimationStatus);
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _openingAnimation?.removeStatusListener(_onAnimationStatus);
    _openingAnimation = null;
    _focusAfterOpening();
  }

  void _focusAfterOpening() {
    if (mounted && !_emojiOpen && ModalRoute.of(context)?.isCurrent == true) {
      _focus.requestFocus();
      _revealCaretAfterLayout();
    }
  }

  void _revealCaretAfterLayout() {
    // 必须等 WidgetSpan 重新计算完行高，才能取得准确的光标坐标。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _emojiOpen || ModalRoute.of(context)?.isCurrent != true) return;
      EditableTextState? editor;
      void findEditor(Element element) {
        if (editor != null) return;
        if (element is StatefulElement && element.state is EditableTextState) {
          editor = element.state as EditableTextState;
        } else {
          element.visitChildElements(findEditor);
        }
      }
      _textFieldKey.currentContext?.visitChildElements(findEditor);
      // 使用实际光标位置，支持在内容中间插入，不能直接滚到末尾。
      editor?.bringIntoView(_controller.draftSelection.extent);
    });
  }

  @override
  void dispose() {
    _openingAnimation?.removeStatusListener(_onAnimationStatus);
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_controller.text.trim().isEmpty) {
      setState(() => _error = '请输入评论内容');
      return;
    }
    setState(() { _submitting = true; _error = null; });
    var success = false;
    try {
      success = await widget.onSubmit(_controller.toHtml());
      if (mounted && !success) setState(() => _error = '提交失败，请检查登录状态后重试');
    } catch (error) {
      final failure = RequestFailure.from(error);
      if (mounted && !failure.isSilent) setState(() => _error =
          failure.isNetwork ? '提交结果未确认，请恢复网络后刷新评论查看，避免重复发送' : failure.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
    if (mounted && success) {
      _controller.clear();
      _close();
    }
  }

  void _close() {
    if (_submitting || ModalRoute.of(context)?.isCurrent != true) return;
    _focus.unfocus();
    Navigator.of(context).pop();
  }

  Future<void> _openEmojis() async {
    if (_emojiOpen || _submitting) return;
    _emojiOpen = true;
    // 键盘收起后 selection 可能失效，先保留用户选择的插入位置。
    final insertionSelection = _controller.draftSelection;
    _focus.unfocus();
    // 表情是输入框之上的独立弹层，返回、蒙版和下滑仅关闭最上层。
    _focus.canRequestFocus = false;
    try {
      final emoji = await showModalBottomSheet<OfficialEmoji>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) => LayoutBuilder(builder: (context, constraints) {
          return SizedBox(
            height: 440.0.clamp(0.0, constraints.maxHeight).toDouble(),
            child: SafeArea(top: false, child: OfficialEmojiPicker(
              onSelected: (emoji) {
                if (ModalRoute.of(sheetContext)?.isCurrent == true) {
                  Navigator.of(sheetContext).pop(emoji);
                }
              },
              onCancel: () {
                if (ModalRoute.of(sheetContext)?.isCurrent == true) {
                  Navigator.of(sheetContext).pop();
                }
              },
            )),
          );
        }),
      );
      if (mounted && emoji != null) {
        final inserted = _controller.insertEmoji(emoji, selection: insertionSelection);
        setState(() => _error = inserted ? null : '该表情暂时无法插入');
        if (inserted) _revealCaretAfterLayout();
      }
    } finally {
      if (mounted) {
        _emojiOpen = false;
        _focus.canRequestFocus = true;
      }
    }
  }

  Widget _editor() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            const Text('回复：', style: TextStyle(color: Colors.grey)),
            if (widget.replyAvatar.isNotEmpty) ...[
              ClipOval(child: CachedNetworkImage(
                imageUrl: widget.replyAvatar, width: 32, height: 32, fit: BoxFit.cover,
                memCacheWidth: ImageDecodeSize.width(context, 32),
                fadeInDuration: Duration.zero,
                errorWidget: (_, __, ___) => const Icon(Icons.person, size: 32),
              )),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(widget.replyName, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: UiSizeUtil.postCommentFontSize))),
            IconButton(tooltip: '关闭', onPressed: _submitting ? null : _close,
              icon: const Icon(Icons.close)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TextField(
                key: _textFieldKey,
                controller: _controller,
                focusNode: _focus,
                // 等弹层展开后再聚焦，避免入场动画和键盘动画同时开始。
                autofocus: false,
                readOnly: _submitting,
                // 随图文内容适度增高，达到上限后在框内滚动。
                minLines: 4,
                maxLines: 6,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: TextStyle(fontSize: UiSizeUtil.postCommentFontSize),
                // 含图片的行使用实际占位高度，其他行维持普通字号。
                strutStyle: StrutStyle.disabled,
                clipBehavior: Clip.hardEdge,
                decoration: InputDecoration(
                  hintText: '请输入你的评论吧~',
                  filled: true,
                  fillColor: const Color(0xFFF4F4F4),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                ),
            ),
          ),
          if (_error != null) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
          Row(children: [
            IconButton(
              tooltip: '官方表情',
              onPressed: _submitting ? null : _openEmojis,
              icon: Image.asset('assets/emoji.png', width: 26, height: 26),
            ),
            const Spacer(),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8033), foregroundColor: Colors.white),
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? '提交中…' : '提交'),
            ),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: Padding(
        // 底部弹层不依赖 Scaffold 的 resize，单独避让软键盘。
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            clipBehavior: Clip.antiAlias,
            // 高度由内容决定；横屏或键盘占据较多空间时才需要滚动。
            child: SafeArea(top: false, child: SingleChildScrollView(child: _editor())),
        ),
      ),
    );
  }
}
