import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/image_decode_size.dart';
import 'package:flutter/material.dart';

import '../../pageRequest/emoji_request.dart';
import '../../ui/uiSizeUtil.dart';

/// 每个表情在编辑值中占一个 UTF-16 字符，光标和删除操作与普通字符一致。
/// 图片和 HTML 都由同一份映射生成，HTML 不直接进入 TextField。
class CommentEditingController extends TextEditingController {
  CommentEditingController() {
    addListener(_rememberSelection);
  }

  TextSelection _lastSelection = const TextSelection.collapsed(offset: 0);

  // 收起键盘可能将 selection 设为 -1；草稿仍保留最后有效的光标位置。
  TextSelection get draftSelection => _lastSelection.end <= text.length
      ? _lastSelection : TextSelection.collapsed(offset: text.length);

  void _rememberSelection() {
    if (selection.isValid && selection.end <= text.length) {
      _lastSelection = selection;
    }
  }

  void restoreSelection() {
    value = value.copyWith(selection: draftSelection, composing: TextRange.empty);
  }

  final Map<String, OfficialEmoji> _emojis = {};
  final Map<String, String> _tokensByUrl = {};
  int _nextToken = 0xE000;
  static const _escapeText = HtmlEscape(HtmlEscapeMode.element);
  static const _escapeAttribute = HtmlEscape(HtmlEscapeMode.attribute);

  bool insertEmoji(OfficialEmoji emoji, {required TextSelection selection}) {
    final uri = Uri.tryParse(emoji.url);
    if (uri == null || !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) return false;

    var token = _tokensByUrl[emoji.url];
    if (token == null) {
      // 私用区字符不会与普通文字、系统 Unicode 表情冲突。
      // 映射保留到编辑器销毁，保证删除后撤销仍可还原图片。
      while (_nextToken <= 0xF8FF) {
        final candidate = String.fromCharCode(_nextToken++);
        if (!text.contains(candidate)) {
          token = candidate;
          break;
        }
      }
      if (token == null) return false;
      _tokensByUrl[emoji.url] = token;
      _emojis[token] = emoji;
    }
    final validSelection = selection.isValid && selection.end <= text.length;
    final start = validSelection ? selection.start : text.length;
    final end = validSelection ? selection.end : text.length;
    value = TextEditingValue(
      text: text.replaceRange(start, end, token),
      selection: TextSelection.collapsed(offset: start + 1),
      composing: TextRange.empty,
    );
    return true;
  }

  String toHtml() {
    return text.split(RegExp(r'\r\n?|\n')).map((paragraph) {
      final html = StringBuffer('<p>');
      var start = 0;
      for (var index = 0; index < paragraph.length; index++) {
        final emoji = _emojis[paragraph[index]];
        if (emoji == null) continue;
        html.write(_escapeText.convert(paragraph.substring(start, index)));
        html.write('<img class="emoji" src="${_escapeAttribute.convert(emoji.url)}" alt="" data-href=""/>');
        start = index + 1;
      }
      html.write(_escapeText.convert(paragraph.substring(start)));
      html.write('</p>');
      return html.toString();
    }).join();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final composing = value.composing;
    final showComposing = withComposing && value.isComposingRangeValid && !composing.isCollapsed;
    final cuts = <int>{0, text.length};
    if (showComposing) cuts.addAll([composing.start, composing.end]);
    for (var index = 0; index < text.length; index++) {
      if (_emojis.containsKey(text[index])) cuts.addAll([index, index + 1]);
    }
    final offsets = cuts.toList()..sort();
    final spans = <InlineSpan>[];
    for (var index = 0; index < offsets.length - 1; index++) {
      final start = offsets[index];
      final end = offsets[index + 1];
      final segment = text.substring(start, end);
      final emoji = _emojis[segment];
      if (emoji != null) {
        final size = UiSizeUtil.emojiSize;
        final lineExtent = size + 4;
        spans.add(WidgetSpan(
          // 为图片所在行显式预留高度，避免沿普通文字行中心向上下溢出。
          style: TextStyle(fontSize: lineExtent, height: 1),
          alignment: PlaceholderAlignment.aboveBaseline,
          baseline: TextBaseline.alphabetic,
          child: Semantics(
            label: emoji.description,
            image: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: SizedBox(
                width: size,
                height: size,
                child: CachedNetworkImage(
                  imageUrl: emoji.url,
                  fit: BoxFit.contain,
                  memCacheWidth: ImageDecodeSize.width(context, size),
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  placeholder: (_, __) => const Icon(Icons.image_outlined, color: Colors.grey),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.grey),
                ),
              ),
            ),
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: segment,
          style: showComposing && start >= composing.start && end <= composing.end
              ? const TextStyle(decoration: TextDecoration.underline) : null,
        ));
      }
    }
    return TextSpan(style: style, children: spans);
  }
}
