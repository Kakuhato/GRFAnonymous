import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:grfanonymous/ui/uiSizeUtil.dart';
import 'package:html/dom.dart' as dom;

class MyWidgetFactory extends WidgetFactory {
  @override
  Widget? buildImageWidget(BuildTree meta, ImageSource src) {
    final url = src.url;
    if (url == null) return null;

    final classList = meta.element.classes ?? {};

    bool isEmoji = classList.contains("emoji");
    double? _width, _height;

    if (isEmoji) {
      _width = UiSizeUtil.emojiSize;
      _height = UiSizeUtil.emojiSize;
    }

    // 使用 CachedNetworkImage 进行图片缓存
    return CachedNetworkImage(
      imageUrl: url,
      width: _width,
      height: _height,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
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
