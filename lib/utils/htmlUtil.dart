import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:grfanonymous/ui/uiSizeUtil.dart';

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
