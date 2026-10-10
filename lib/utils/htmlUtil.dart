import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:grfanonymous/ui/image_gallery.dart';
import 'package:grfanonymous/ui/uiSizeUtil.dart';
import 'package:html/dom.dart' as dom;

import 'image_actions.dart';

class MyWidgetFactory extends WidgetFactory {
  final BuildContext context;

  MyWidgetFactory(this.context);

  @override
  Widget? buildImageWidget(BuildTree meta, ImageSource src) {
    final url = src.url;
    if (url == null) return null;
    final isEmoji = meta.element.classes.contains('emoji');
    return GestureDetector(
      onTap: isEmoji ? null : () => _preview(meta.element, url),
      onLongPress: () => ImageActions.showSaveMenu(context, url),
      child: CachedNetworkImage(
        imageUrl: url,
        width: isEmoji ? UiSizeUtil.emojiSize : null,
        height: isEmoji ? UiSizeUtil.emojiSize : null,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (_, __, ___) => const Icon(Icons.error),
      ),
    );
  }

  void _preview(dom.Element clicked, String clickedUrl) {
    // 每份 HTML（正文或单条评论）独立成组，按原文顺序浏览并排除表情。
    dom.Node root = clicked;
    while (root.parentNode != null) {
      root = root.parentNode!;
    }
    final elements = <dom.Element>[];
    void collectImages(dom.Node node) {
      if (node is dom.Element && node.localName == 'img') {
        elements.add(node);
      }
      for (final child in node.nodes) {
        collectImages(child);
      }
    }
    collectImages(root);
    final urls = <String>[];
    var initialIndex = -1;
    for (final element in elements) {
      if (element.classes.contains('emoji')) continue;
      final source = element == clicked
          ? clickedUrl
          : element.attributes['src'];
      if (source == null || source.trim().isEmpty) continue;
      if (element == clicked) initialIndex = urls.length;
      urls.add(source.startsWith('//') ? 'https:$source' : source);
    }
    if (initialIndex < 0) {
      urls.add(clickedUrl);
      initialIndex = urls.length - 1;
    }
    showImageGallery(context, images: urls, initialIndex: initialIndex);
  }
}

class HtmlProcess {
  static Map<String, String>? buildCustomStyles(dom.Element element) {
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
  }
}

