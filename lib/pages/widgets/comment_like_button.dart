import 'package:flutter/material.dart';

import '../../ui/uiSizeUtil.dart';

/// 底部留白位于点击区域内部，图标尺寸保持不变。
class CommentLikeButton extends StatelessWidget {
  const CommentLikeButton({super.key, required this.isLiked, required this.count,
    required this.onTap, this.busy = false});

  final bool isLiked;
  final int count;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = !busy && onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: busy ? '点赞处理中' : (isLiked ? '取消点赞' : '点赞'),
      value: '$count',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: UiSizeUtil.postCommentLikeIconSize,
              height: UiSizeUtil.postCommentLikeIconSize,
              child: busy
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : Opacity(
                      opacity: enabled ? 1 : 0.45,
                      child: Image.asset(isLiked ? 'assets/liked.png' : 'assets/likes.png'),
                    ),
            ),
            const SizedBox(width: 5),
            Text('$count', style: TextStyle(
              fontSize: UiSizeUtil.postCommentLikeFontSize, color: Colors.grey)),
            ]),
          ),
        ),
      ),
    );
  }
}
