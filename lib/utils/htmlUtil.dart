import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:grfanonymous/ui/uiSizeUtil.dart';
import 'package:html/dom.dart' as dom;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

class MyWidgetFactory extends WidgetFactory {
  final BuildContext context;
  final String albumName = "grfa";

  MyWidgetFactory(this.context);

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
    return GestureDetector(
      onLongPress: () async {
        // 显示保存图片的对话框
        await showDialog(
          context: context,
          builder: (context) => Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 40), // 控制对话框的左右边距
            child: Container(
              width: double.infinity, // 占满对话框的宽度
              color: Colors.grey[200], // 设置背景颜色，您可以更换为所需颜色
              child: TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _saveImageToAlbum(url);
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0), // 按钮圆角半径
                  ),
                  backgroundColor: Colors.grey[200], // 按钮背景颜色
                  overlayColor: Colors.blueAccent.withOpacity(0.1), // 点击时的颜色
                ),
                child: const Text(
                  '保存图片',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ), // 调整字体颜色
                ),
              ),
            ),
          ),
        );
      },
      child: CachedNetworkImage(
        imageUrl: url,
        width: _width,
        height: _height,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }

  Future<void> _saveImageToAlbum(String url) async {
    if (!await requestStoragePermission()) {
      showToast("没有存储权限");
      return;
    }

    try {
      // 下载图片并缓存
      final cacheManager = DefaultCacheManager();
      final file = await cacheManager.getSingleFile(url);
      // final Uint8List imageBytes = await file.readAsBytes();

      // 使用 image_gallery_saver 保存文件到 "Downloads" 目录
      final result = await ImageGallerySaverPlus.saveFile(
        file.path,
        name: "grfa_${DateTime.now().millisecondsSinceEpoch}",
        isReturnPathOfIOS: true,
      );

      if (result["isSuccess"] == true) {
        showToast("图片已保存到相册");
      } else {
        showToast("保存图片失败");
      }
    } catch (error) {
      showToast("保存图片出错：$error");
    }
  }

  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
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
