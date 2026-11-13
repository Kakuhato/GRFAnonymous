import 'package:flutter/material.dart';
import 'app_image_cache.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

/// 复用原有保存流程，供正文长按和图片预览使用。
class ImageActions {
  static Future<void> showSaveMenu(BuildContext context, String url) async {
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('保存图片'),
          ),
        ],
      ),
    );
    if (save == true) await saveImage(url);
  }

  static Future<void> saveImage(String url) async {
    try {
      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        showToast('没有存储权限');
        return;
      }
      final file = await AppImageCache.instance.originalFile(url);
      final result = await ImageGallerySaverPlus.saveFile(
        file.path,
        name: 'grfa_${DateTime.now().millisecondsSinceEpoch}',
        isReturnPathOfIOS: true,
      );
      showToast(result['isSuccess'] == true ? '图片已保存到相册' : '保存图片失败');
    } catch (_) {
      showToast('保存图片失败，请重试');
    }
  }
}
